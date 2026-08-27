import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

interface UserAnswerLog {
  id?: string;
  uid: string;
  questionId: string;
  selectedAnswer: number;
  isCorrect: boolean;
  answeredAt?: FirebaseFirestore.Timestamp;
}

/**
 * Update user metrics when answer logs are created.
 * Calculates real-time accuracy and learning progress.
 *
 * Updates:
 * - users/{uid}/analytics/userMetrics (overall stats)
 * - users/{uid}/analytics/category_{categoryId} (category-specific)
 */
export const updateUserMetrics = functions
  .region('asia-northeast1')
  .firestore
  .document('users/{uid}/answerLogs/{logId}')
  .onCreate(async (snap, context) => {
    const uid = context.params.uid;
    const log = snap.data() as UserAnswerLog;

    if (!log || !log.questionId) {
      functions.logger.warn('Invalid answer log', { uid, log });
      return;
    }

    try {
      const db = admin.firestore();

      // Update overall user metrics
      await updateOverallMetrics(db, uid, log);

      // Get category from question and update category metrics
      const category = await getCategoryForQuestion(db, log.questionId);
      if (category) {
        await updateCategoryMetrics(db, uid, category, log);
      }

      functions.logger.info('User metrics updated', {
        uid,
        questionId: log.questionId,
        isCorrect: log.isCorrect,
      });
    } catch (error) {
      functions.logger.error('Failed to update user metrics', { uid, error });
      throw error;
    }
  });

/**
 * Update overall user metrics
 */
async function updateOverallMetrics(
  db: FirebaseFirestore.Firestore,
  uid: string,
  log: UserAnswerLog,
): Promise<void> {
  const metricsRef = db.collection('users').doc(uid)
    .collection('analytics')
    .doc('userMetrics');

  // Get current metrics to calculate running average
  const metricsSnap = await metricsRef.get();
  const current = metricsSnap.data() || { totalAttempts: 0, correctCount: 0 };

  const totalAttempts = (current.totalAttempts || 0) + 1;
  const correctCount = (current.correctCount || 0) + (log.isCorrect ? 1 : 0);
  const accuracy = totalAttempts > 0 ? (correctCount / totalAttempts) * 100 : 0;

  await metricsRef.set({
    totalAttempts,
    correctCount,
    accuracy: Math.round(accuracy * 10) / 10,
    successRate: log.isCorrect, // Latest answer result
    lastAnsweredAt: log.answeredAt || admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
}

/**
 * Update category-specific metrics
 */
async function updateCategoryMetrics(
  db: FirebaseFirestore.Firestore,
  uid: string,
  category: string,
  log: UserAnswerLog,
): Promise<void> {
  const categoryRef = db.collection('users').doc(uid)
    .collection('analytics')
    .doc(`category_${category}`);

  const categorySnap = await categoryRef.get();
  const current = categorySnap.data() || { attempts: 0, correctCount: 0 };

  const attempts = (current.attempts || 0) + 1;
  const correctCount = (current.correctCount || 0) + (log.isCorrect ? 1 : 0);
  const accuracy = attempts > 0 ? (correctCount / attempts) * 100 : 0;

  await categoryRef.set({
    categoryId: category,
    attempts,
    correctCount,
    accuracy: Math.round(accuracy * 10) / 10,
    lastAnsweredAt: log.answeredAt || admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  // Calculate strength/weakness indicator
  if (accuracy < 60) {
    await categoryRef.update({
      status: 'weak', // Needs improvement
    });
  } else if (accuracy < 80) {
    await categoryRef.update({
      status: 'medium', // Good progress
    });
  } else {
    await categoryRef.update({
      status: 'strong', // Mastered
    });
  }
}

/**
 * Get category for a question from the questions collection
 */
async function getCategoryForQuestion(
  db: FirebaseFirestore.Firestore,
  questionId: string,
): Promise<string | null> {
  try {
    // Search in all category collections
    const categories = ['gentsuki', 'normal', 'middium', 'big', 'large'];

    for (const category of categories) {
      const questionRef = await db.collection('questions')
        .doc(category)
        .collection('questionList')
        .doc(questionId)
        .get();

      if (questionRef.exists) {
        return category;
      }
    }

    return null;
  } catch (error) {
    functions.logger.warn('Error getting category for question', { questionId, error });
    return null;
  }
}
