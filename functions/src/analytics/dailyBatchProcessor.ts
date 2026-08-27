import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

interface DailyStats {
  date: string;
  totalEvents: number;
  questionsAnswered: number;
  correctAnswers: number;
  accuracy: number;
  sessionsCompleted: number;
  totalSessionDuration: number;
  averageSessionDuration: number;
  bikesUnlocked: number;
  eventTypes: Record<string, number>;
  topCategories: Array<{ category: string; accuracy: number; attempts: number }>;
  processedAt: FirebaseFirestore.Timestamp;
}

/**
 * Calculate daily analytics for all users.
 * Runs daily at 17:00 UTC (2:00 AM JST next day).
 *
 * This function:
 * 1. Aggregates daily stats from hourly data
 * 2. Calculates accuracy metrics
 * 3. Identifies top categories
 * 4. Stores for dashboard queries
 */
export const calculateDailyAnalytics = functions
  .region('asia-northeast1')
  .pubsub
  .schedule('0 17 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    const db = admin.firestore();

    try {
      // Get yesterday's date for processing
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const dateStr = yesterday.toISOString().split('T')[0].replace(/-/g, '');

      functions.logger.info('Starting daily analytics batch', { dateStr });

      // Get all users
      const usersSnapshot = await db.collection('users').get();
      let processedUsers = 0;

      for (const userDoc of usersSnapshot.docs) {
        const uid = userDoc.id;

        try {
          // Get hourly data for the day
          const hourlyQuery = await db.collection('users').doc(uid)
            .collection('analytics')
            .where('__name__', '>=', `hourly_${dateStr}_00`)
            .where('__name__', '<=', `hourly_${dateStr}_23`)
            .get();

          if (hourlyQuery.empty) {
            continue; // No data for this user on this day
          }

          // Aggregate hourly stats
          let totalEvents = 0;
          let questionsAnswered = 0;
          let correctAnswers = 0;
          let sessionsCompleted = 0;
          let totalSessionDuration = 0;
          let bikesUnlocked = 0;
          const eventTypes: Record<string, number> = {};
          const categoryStats: Record<string, { attempts: number; correct: number }> = {};

          for (const hourlyDoc of hourlyQuery.docs) {
            const data = hourlyDoc.data();
            totalEvents += data.eventCount || 0;

            // Aggregate event types
            if (data.eventTypes) {
              for (const [type, count] of Object.entries(data.eventTypes)) {
                eventTypes[type] = (eventTypes[type] || 0) + (count as number);
              }
            }
          }

          // Get category-specific stats
          const categoryQuery = await db.collection('users').doc(uid)
            .collection('analytics')
            .where('__name__', '>=', 'category_')
            .get();

          const topCategories = [];
          for (const categoryDoc of categoryQuery.docs) {
            const data = categoryDoc.data();
            if (data.categoryId && data.attempts && data.correctCount !== undefined) {
              const accuracy = (data.correctCount / data.attempts) * 100;
              topCategories.push({
                category: data.categoryId,
                accuracy,
                attempts: data.attempts,
              });
              questionsAnswered += data.attempts;
              correctAnswers += data.correctCount;
            }
          }

          // Sort by accuracy and take top 5
          topCategories.sort((a, b) => b.accuracy - a.accuracy);
          topCategories.splice(5);

          // Get session stats
          const sessionRef = await db.collection('users').doc(uid)
            .collection('analytics')
            .doc('sessionStats')
            .get();

          if (sessionRef.exists) {
            const sessionData = sessionRef.data();
            sessionsCompleted = sessionData?.sessionsCompleted || 0;
            totalSessionDuration = sessionData?.totalDurationSeconds || 0;
          }

          // Calculate average session duration
          const averageSessionDuration = sessionsCompleted > 0
            ? Math.round(totalSessionDuration / sessionsCompleted)
            : 0;

          // Get bike unlock stats
          const bikeQuery = await db.collection('users').doc(uid)
            .collection('analytics')
            .where('__name__', '>=', 'bike_')
            .get();

          bikesUnlocked = bikeQuery.size;

          // Calculate overall accuracy
          const accuracy = questionsAnswered > 0
            ? (correctAnswers / questionsAnswered) * 100
            : 0;

          // Store daily stats
          const dailyStats: DailyStats = {
            date: dateStr,
            totalEvents,
            questionsAnswered,
            correctAnswers,
            accuracy: Math.round(accuracy * 10) / 10,
            sessionsCompleted,
            totalSessionDuration,
            averageSessionDuration,
            bikesUnlocked,
            eventTypes,
            topCategories,
            processedAt: admin.firestore.Timestamp.now(),
          };

          await db.collection('users').doc(uid)
            .collection('analytics')
            .doc(`daily_${dateStr}_summary`)
            .set(dailyStats);

          processedUsers++;
        } catch (error) {
          functions.logger.error('Error processing user daily analytics', { uid, error });
        }
      }

      functions.logger.info('Daily analytics batch completed', {
        dateStr,
        processedUsers,
      });

      return { success: true, processedUsers };
    } catch (error) {
      functions.logger.error('Daily analytics batch failed', { error });
      throw error;
    }
  });
