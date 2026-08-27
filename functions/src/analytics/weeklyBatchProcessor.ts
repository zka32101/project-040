import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

interface WeeklyStats {
  weekStartDate: string;
  weekEndDate: string;
  totalEvents: number;
  questionsAnswered: number;
  correctAnswers: number;
  accuracy: number;
  sessionsCompleted: number;
  averageAccuracy: number;
  topCategories: Array<{ category: string; accuracy: number; attempts: number }>;
  improvementRate: number; // Compared to previous week
  processedAt: FirebaseFirestore.Timestamp;
}

/**
 * Calculate weekly analytics for all users.
 * Runs every Sunday at 17:00 UTC.
 *
 * This function:
 * 1. Aggregates 7 days of daily stats
 * 2. Calculates weekly metrics
 * 3. Compares to previous week for improvement tracking
 * 4. Stores for progress visualization
 */
export const calculateWeeklyAnalytics = functions
  .region('asia-northeast1')
  .pubsub
  .schedule('0 17 * * 0')
  .timeZone('UTC')
  .onRun(async (context) => {
    const db = admin.firestore();

    try {
      // Calculate week dates (ending yesterday, starting 7 days ago)
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const weekEndDate = yesterday.toISOString().split('T')[0].replace(/-/g, '');

      const weekAgoDate = new Date(yesterday);
      weekAgoDate.setDate(weekAgoDate.getDate() - 6);
      const weekStartDate = weekAgoDate.toISOString().split('T')[0].replace(/-/g, '');

      functions.logger.info('Starting weekly analytics batch', {
        weekStartDate,
        weekEndDate,
      });

      // Get all users
      const usersSnapshot = await db.collection('users').get();
      let processedUsers = 0;

      for (const userDoc of usersSnapshot.docs) {
        const uid = userDoc.id;

        try {
          const weeklyStats = await aggregateWeeklyStats(
            db,
            uid,
            weekStartDate,
            weekEndDate,
          );

          // Compare to previous week
          const prevWeekEndDate = getDateBefore(weekStartDate, 1);
          const prevWeekStartDate = getDateBefore(weekStartDate, 7);

          const prevWeekStats = await aggregateWeeklyStats(
            db,
            uid,
            prevWeekStartDate,
            prevWeekEndDate,
          );

          const improvementRate = calculateImprovement(prevWeekStats.accuracy, weeklyStats.accuracy);

          // Store weekly stats
          const statsToStore: WeeklyStats = {
            weekStartDate,
            weekEndDate,
            totalEvents: weeklyStats.totalEvents,
            questionsAnswered: weeklyStats.questionsAnswered,
            correctAnswers: weeklyStats.correctAnswers,
            accuracy: weeklyStats.accuracy,
            sessionsCompleted: weeklyStats.sessionsCompleted,
            averageAccuracy: weeklyStats.averageAccuracy,
            topCategories: weeklyStats.topCategories,
            improvementRate,
            processedAt: admin.firestore.Timestamp.now(),
          };

          await db.collection('users').doc(uid)
            .collection('analytics')
            .doc(`weekly_${weekEndDate}`)
            .set(statsToStore);

          processedUsers++;
        } catch (error) {
          functions.logger.error('Error processing user weekly analytics', { uid, error });
        }
      }

      functions.logger.info('Weekly analytics batch completed', { processedUsers });
      return { success: true, processedUsers };
    } catch (error) {
      functions.logger.error('Weekly analytics batch failed', { error });
      throw error;
    }
  });

/**
 * Aggregate daily stats for a week
 */
async function aggregateWeeklyStats(
  db: FirebaseFirestore.Firestore,
  uid: string,
  startDate: string,
  endDate: string,
): Promise<Record<string, unknown>> {
  let totalEvents = 0;
  let questionsAnswered = 0;
  let correctAnswers = 0;
  let sessionsCompleted = 0;
  const accuracyValues: number[] = [];
  const categoryStats: Record<string, { attempts: number; correct: number; accuracy: number }> = {};

  // Iterate through each day in the week
  const startNum = parseInt(startDate);
  const endNum = parseInt(endDate);
  const currentDate = new Date(startDate.substring(0, 4) + '-' + startDate.substring(4, 6) + '-' + startDate.substring(6, 8));

  while (parseInt(currentDate.toISOString().split('T')[0].replace(/-/g, '')) <= endNum) {
    const dateStr = currentDate.toISOString().split('T')[0].replace(/-/g, '');

    const dailyRef = await db.collection('users').doc(uid)
      .collection('analytics')
      .doc(`daily_${dateStr}_summary`)
      .get();

    if (dailyRef.exists) {
      const data = dailyRef.data();
      if (data) {
        totalEvents += data.totalEvents || 0;
        questionsAnswered += data.questionsAnswered || 0;
        correctAnswers += data.correctAnswers || 0;
        sessionsCompleted += data.sessionsCompleted || 0;
        accuracyValues.push(data.accuracy || 0);

        // Aggregate top categories
        if (data.topCategories && Array.isArray(data.topCategories)) {
          for (const category of data.topCategories) {
            const cat = categoryStats[category.category] || { attempts: 0, correct: 0, accuracy: 0 };
            cat.attempts += category.attempts || 0;
            cat.correct += (category.accuracy * (category.attempts || 0)) / 100 || 0;
            categoryStats[category.category] = cat;
          }
        }
      }
    }

    currentDate.setDate(currentDate.getDate() + 1);
  }

  // Calculate average accuracy
  const averageAccuracy = accuracyValues.length > 0
    ? Math.round((accuracyValues.reduce((a, b) => a + b, 0) / accuracyValues.length) * 10) / 10
    : 0;

  // Calculate overall accuracy
  const accuracy = questionsAnswered > 0
    ? Math.round((correctAnswers / questionsAnswered) * 100 * 10) / 10
    : 0;

  // Build top categories
  const topCategories = Object.entries(categoryStats)
    .map(([category, stats]) => ({
      category,
      attempts: stats.attempts,
      accuracy: stats.attempts > 0 ? Math.round((stats.correct / stats.attempts) * 100 * 10) / 10 : 0,
    }))
    .sort((a, b) => b.accuracy - a.accuracy)
    .slice(0, 5);

  return {
    totalEvents,
    questionsAnswered,
    correctAnswers,
    accuracy,
    sessionsCompleted,
    averageAccuracy,
    topCategories,
  };
}

/**
 * Get date string for N days before the given date
 */
function getDateBefore(dateStr: string, days: number): string {
  const year = parseInt(dateStr.substring(0, 4));
  const month = parseInt(dateStr.substring(4, 6));
  const day = parseInt(dateStr.substring(6, 8));

  const date = new Date(year, month - 1, day);
  date.setDate(date.getDate() - days);

  return date.toISOString().split('T')[0].replace(/-/g, '');
}

/**
 * Calculate improvement rate between two accuracy values
 */
function calculateImprovement(prevAccuracy: number, currentAccuracy: number): number {
  if (prevAccuracy === 0) {
    return currentAccuracy > 0 ? 100 : 0;
  }
  return Math.round(((currentAccuracy - prevAccuracy) / prevAccuracy) * 1000) / 10;
}
