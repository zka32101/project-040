import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

interface MonthlyStats {
  year: number;
  month: number;
  totalEvents: number;
  questionsAnswered: number;
  correctAnswers: number;
  accuracy: number;
  sessionsCompleted: number;
  topCategories: Array<{ category: string; accuracy: number; attempts: number }>;
  improvementRate: number; // Compared to previous month
  studyStreak: number; // Days with activity
  averageSessionDuration: number;
  processedAt: FirebaseFirestore.Timestamp;
}

/**
 * Calculate monthly analytics for all users.
 * Runs on the 1st of each month at 17:00 UTC.
 *
 * This function:
 * 1. Aggregates all daily stats from previous month
 * 2. Calculates monthly metrics and study streak
 * 3. Compares to previous month
 * 4. Stores for milestone tracking
 */
export const calculateMonthlyAnalytics = functions
  .region('asia-northeast1')
  .pubsub
  .schedule('0 17 1 * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    const db = admin.firestore();

    try {
      // Get previous month
      const today = new Date();
      const firstDay = new Date(today.getFullYear(), today.getMonth() - 1, 1);
      const lastDay = new Date(today.getFullYear(), today.getMonth(), 0);

      const year = firstDay.getFullYear();
      const month = firstDay.getMonth() + 1;

      functions.logger.info('Starting monthly analytics batch', { year, month });

      // Get all users
      const usersSnapshot = await db.collection('users').get();
      let processedUsers = 0;

      for (const userDoc of usersSnapshot.docs) {
        const uid = userDoc.id;

        try {
          const monthlyStats = await aggregateMonthlyStats(db, uid, year, month);

          // Compare to previous month
          let prevMonth = month - 1;
          let prevYear = year;
          if (prevMonth === 0) {
            prevMonth = 12;
            prevYear = year - 1;
          }

          const prevMonthStats = await aggregateMonthlyStats(db, uid, prevYear, prevMonth);

          const improvementRate = calculateImprovement(prevMonthStats.accuracy, monthlyStats.accuracy);

          // Store monthly stats
          const statsToStore: MonthlyStats = {
            year,
            month,
            totalEvents: monthlyStats.totalEvents,
            questionsAnswered: monthlyStats.questionsAnswered,
            correctAnswers: monthlyStats.correctAnswers,
            accuracy: monthlyStats.accuracy,
            sessionsCompleted: monthlyStats.sessionsCompleted,
            topCategories: monthlyStats.topCategories,
            improvementRate,
            studyStreak: monthlyStats.studyStreak,
            averageSessionDuration: monthlyStats.averageSessionDuration,
            processedAt: admin.firestore.Timestamp.now(),
          };

          await db.collection('users').doc(uid)
            .collection('analytics')
            .doc(`monthly_${String(year)}_${String(month).padStart(2, '0')}`)
            .set(statsToStore);

          processedUsers++;
        } catch (error) {
          functions.logger.error('Error processing user monthly analytics', { uid, error });
        }
      }

      functions.logger.info('Monthly analytics batch completed', { processedUsers, year, month });
      return { success: true, processedUsers, year, month };
    } catch (error) {
      functions.logger.error('Monthly analytics batch failed', { error });
      throw error;
    }
  });

/**
 * Aggregate daily stats for a month
 */
async function aggregateMonthlyStats(
  db: FirebaseFirestore.Firestore,
  uid: string,
  year: number,
  month: number,
): Promise<Record<string, unknown>> {
  let totalEvents = 0;
  let questionsAnswered = 0;
  let correctAnswers = 0;
  let sessionsCompleted = 0;
  let totalSessionDuration = 0;
  const categoryStats: Record<string, { attempts: number; correct: number }> = {};
  const daysWithActivity = new Set<string>();

  // Get first and last day of month
  const firstDay = new Date(year, month - 1, 1);
  const lastDay = new Date(year, month, 0);

  // Iterate through each day in the month
  let currentDate = new Date(firstDay);

  while (currentDate <= lastDay) {
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
        totalSessionDuration += data.totalSessionDuration || 0;
        daysWithActivity.add(dateStr);

        // Aggregate categories
        if (data.topCategories && Array.isArray(data.topCategories)) {
          for (const category of data.topCategories) {
            const cat = categoryStats[category.category] || { attempts: 0, correct: 0 };
            cat.attempts += category.attempts || 0;
            cat.correct += Math.round((category.accuracy * (category.attempts || 0)) / 100);
            categoryStats[category.category] = cat;
          }
        }
      }
    }

    currentDate.setDate(currentDate.getDate() + 1);
  }

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

  // Calculate average session duration
  const averageSessionDuration = sessionsCompleted > 0
    ? Math.round(totalSessionDuration / sessionsCompleted)
    : 0;

  return {
    totalEvents,
    questionsAnswered,
    correctAnswers,
    accuracy,
    sessionsCompleted,
    topCategories,
    studyStreak: daysWithActivity.size,
    averageSessionDuration,
  };
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
