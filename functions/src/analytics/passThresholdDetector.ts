import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

interface PredictionScore {
  score: number;
  calculatedAt?: FirebaseFirestore.Timestamp;
  breakdown?: Record<string, number>;
}

/**
 * Detect when user reaches pass prediction thresholds.
 * Sends notifications and records milestone events.
 *
 * Milestones:
 * - 50%: Getting started
 * - 70%: Good progress
 * - 80%: Ready to attempt exam
 * - 90%: Near perfect
 * - 100%: Complete mastery
 */
export const detectPassThreshold = functions
  .region('asia-northeast1')
  .firestore
  .document('users/{uid}/metadata/predictionScore')
  .onUpdate(async (change, context) => {
    const uid = context.params.uid;
    const newData = change.after.data() as PredictionScore;
    const oldData = change.before.data() as PredictionScore | undefined;

    const newScore = newData?.score || 0;
    const oldScore = oldData?.score || 0;

    try {
      const db = admin.firestore();

      // Check for threshold crossings
      const thresholds = [50, 70, 80, 90, 100];

      for (const threshold of thresholds) {
        if (oldScore < threshold && newScore >= threshold) {
          // Threshold reached!
          await recordMilestone(db, uid, threshold, newScore);
          await sendMilestoneNotification(db, uid, threshold);
        }
      }

      functions.logger.info('Prediction score analyzed', { uid, oldScore, newScore });
    } catch (error) {
      functions.logger.error('Failed to detect pass threshold', { uid, error });
      // Don't throw - this shouldn't block the write
    }
  });

/**
 * Record milestone achievement
 */
async function recordMilestone(
  db: FirebaseFirestore.Firestore,
  uid: string,
  threshold: number,
  score: number,
): Promise<void> {
  const milestoneRef = db.collection('users').doc(uid)
    .collection('analytics')
    .doc('milestones');

  const milestone = {
    threshold,
    score,
    achievedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await milestoneRef.set({
    [`milestone_${threshold}`]: milestone,
    lastMilestoneAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  // Also add to event history for analytics
  await db.collection('users').doc(uid)
    .collection('analyticsEvents')
    .add({
      type: 'passRateThresholdReached',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      userId: uid,
      parameters: {
        threshold,
        score,
      },
      eventName: 'passRateThresholdReached',
    });
}

/**
 * Send notification for milestone achievement
 */
async function sendMilestoneNotification(
  db: FirebaseFirestore.Firestore,
  uid: string,
  threshold: number,
): Promise<void> {
  const notificationMessages: Record<number, { title: string; body: string }> = {
    50: {
      title: '学習開始！',
      body: '合格予測スコアが50%に到達しました。コツコツ続けましょう！',
    },
    70: {
      title: '順調な進捗！',
      body: '合格予測スコアが70%に到達。あと少しで試験に挑戦できます。',
    },
    80: {
      title: '試験準備完了！',
      body: '合格予測スコアが80%に達しました。本番試験に挑戦してみましょう！',
    },
    90: {
      title: 'ほぼ完ぺき！',
      body: '合格予測スコアが90%に到達。もう一息です！',
    },
    100: {
      title: '完全マスター！',
      body: '合格予測スコアが100%。試験に向けて万全の準備ができました！',
    },
  };

  const message = notificationMessages[threshold];
  if (!message) {
    return;
  }

  // Store notification in Firestore
  await db.collection('users').doc(uid)
    .collection('notifications')
    .add({
      type: 'milestone',
      title: message.title,
      body: message.body,
      threshold,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });

  // In a production app, you'd also send push notifications here
  // using Firebase Cloud Messaging (FCM)
  functions.logger.info('Milestone notification created', {
    uid,
    threshold,
    title: message.title,
  });
}

/**
 * Send FCM notification (to be called when FCM tokens are available)
 */
export async function sendFCMNotification(
  uid: string,
  title: string,
  body: string,
): Promise<void> {
  try {
    const db = admin.firestore();
    const userRef = await db.collection('users').doc(uid).get();

    if (!userRef.exists) {
      return;
    }

    // In a full implementation, retrieve FCM tokens from users/{uid}/fcmTokens
    // and send notifications via admin.messaging().sendMulticast()

    functions.logger.info('FCM notification would be sent', { uid, title });
  } catch (error) {
    functions.logger.error('Failed to send FCM notification', { uid, error });
  }
}
