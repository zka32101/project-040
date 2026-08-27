import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

interface AnalyticsEvent {
  type: string;
  timestamp: FirebaseFirestore.Timestamp;
  userId?: string;
  sessionId?: string;
  parameters?: Record<string, unknown>;
  eventName?: string;
}

interface AggregatedStats {
  eventCount: number;
  lastEventAt: FirebaseFirestore.Timestamp;
  eventTypes: Record<string, number>;
  sessionIds: Record<string, number>;
}

/**
 * Aggregates analytics events in real-time as they are created.
 * Updates hourly and daily statistics for fast dashboard queries.
 *
 * Firestore structure:
 * users/{uid}/analyticsEvents/{eventId} -> triggers this function
 * users/{uid}/analytics/eventStats -> hourly aggregation
 * users/{uid}/analytics/daily{YYYYMMDD} -> daily aggregation
 */
export const aggregateAnalyticsEvent = functions
  .region('asia-northeast1')
  .firestore
  .document('users/{uid}/analyticsEvents/{eventId}')
  .onCreate(async (snap, context) => {
    const uid = context.params.uid;
    const event = snap.data() as AnalyticsEvent;

    if (!event || !event.timestamp) {
      functions.logger.warn('Invalid analytics event', { uid, event });
      return;
    }

    try {
      const db = admin.firestore();

      // Get event date for daily aggregation
      const eventDate = new Date(event.timestamp.toDate());
      const dateStr = eventDate.toISOString().split('T')[0].replace(/-/g, '');
      const hourStr = String(eventDate.getHours()).padStart(2, '0');

      // Update hourly stats
      const hourlyRef = db.collection('users').doc(uid)
        .collection('analytics')
        .doc(`hourly_${dateStr}_${hourStr}`);

      await hourlyRef.set({
        eventCount: admin.firestore.FieldValue.increment(1),
        lastEventAt: event.timestamp,
        [`eventTypes.${event.type}`]: admin.firestore.FieldValue.increment(1),
        [`sessionIds.${event.sessionId || 'unknown'}`]: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // Update daily stats
      const dailyRef = db.collection('users').doc(uid)
        .collection('analytics')
        .doc(`daily_${dateStr}`);

      await dailyRef.set({
        eventCount: admin.firestore.FieldValue.increment(1),
        lastEventAt: event.timestamp,
        [`eventTypes.${event.type}`]: admin.firestore.FieldValue.increment(1),
        [`sessionIds.${event.sessionId || 'unknown'}`]: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // Track specific event types for quick access
      if (event.type === 'questionAnswered') {
        await trackQuestionAnswered(db, uid, event);
      } else if (event.type === 'quizSessionCompleted') {
        await trackQuizSessionCompleted(db, uid, event);
      } else if (event.type === 'bikeUnlocked') {
        await trackBikeUnlocked(db, uid, event);
      }

      functions.logger.info('Event aggregated successfully', { uid, eventType: event.type });
    } catch (error) {
      functions.logger.error('Failed to aggregate analytics event', { uid, error });
      throw error;
    }
  });

/**
 * Track question answered events specifically for accuracy calculations
 */
async function trackQuestionAnswered(
  db: FirebaseFirestore.Firestore,
  uid: string,
  event: AnalyticsEvent,
): Promise<void> {
  const params = event.parameters as Record<string, unknown>;
  const isCorrect = params?.isCorrect === true;
  const category = params?.category as string || 'unknown';

  const categoryRef = db.collection('users').doc(uid)
    .collection('analytics')
    .doc(`category_${category}`);

  await categoryRef.set({
    categoryId: category,
    attempts: admin.firestore.FieldValue.increment(1),
    correctCount: isCorrect ? admin.firestore.FieldValue.increment(1) : 0,
    lastAnsweredAt: event.timestamp,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
}

/**
 * Track quiz session completion events
 */
async function trackQuizSessionCompleted(
  db: FirebaseFirestore.Firestore,
  uid: string,
  event: AnalyticsEvent,
): Promise<void> {
  const params = event.parameters as Record<string, unknown>;
  const totalQuestions = params?.totalQuestions as number || 0;
  const correctAnswers = params?.correctAnswers as number || 0;
  const durationSeconds = params?.durationSeconds as number || 0;

  const sessionRef = db.collection('users').doc(uid)
    .collection('analytics')
    .doc('sessionStats');

  const accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  await sessionRef.set({
    sessionsCompleted: admin.firestore.FieldValue.increment(1),
    totalQuestionsAnswered: admin.firestore.FieldValue.increment(totalQuestions),
    totalCorrectAnswers: admin.firestore.FieldValue.increment(correctAnswers),
    totalDurationSeconds: admin.firestore.FieldValue.increment(durationSeconds),
    lastSessionAt: event.timestamp,
    recentAccuracies: admin.firestore.FieldValue.arrayUnion([accuracy]),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
}

/**
 * Track bike unlock events
 */
async function trackBikeUnlocked(
  db: FirebaseFirestore.Firestore,
  uid: string,
  event: AnalyticsEvent,
): Promise<void> {
  const params = event.parameters as Record<string, unknown>;
  const bikeCategory = params?.bikeCategory as string || 'unknown';

  const bikeRef = db.collection('users').doc(uid)
    .collection('analytics')
    .doc(`bike_${bikeCategory}`);

  await bikeRef.set({
    bikeCategory,
    unlockedAt: event.timestamp,
    unlockedPercentage: params?.unlockedPercentage || 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
}
