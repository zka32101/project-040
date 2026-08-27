import * as functions from 'firebase-functions';
import { aggregateAnalyticsEvent } from './analytics/eventAggregator';
import { calculateDailyAnalytics } from './analytics/dailyBatchProcessor';
import { calculateWeeklyAnalytics } from './analytics/weeklyBatchProcessor';
import { calculateMonthlyAnalytics } from './analytics/monthlyBatchProcessor';
import { updateUserMetrics } from './analytics/userMetricsUpdater';
import { detectPassThreshold } from './analytics/passThresholdDetector';

// Firestore triggers - Real-time event aggregation
export const onAnalyticsEventCreated = functions
  .region('asia-northeast1')
  .firestore
  .document('users/{uid}/analyticsEvents/{eventId}')
  .onCreate(aggregateAnalyticsEvent);

// Scheduled functions - Batch processing
// Daily analytics calculation (2 AM JST = 5 PM UTC previous day)
export const dailyAnalyticsBatch = functions
  .region('asia-northeast1')
  .pubsub
  .schedule('0 17 * * *')
  .timeZone('UTC')
  .onRun(calculateDailyAnalytics);

// Weekly analytics calculation (Monday 2 AM JST = Sunday 5 PM UTC)
export const weeklyAnalyticsBatch = functions
  .region('asia-northeast1')
  .pubsub
  .schedule('0 17 * * 0')
  .timeZone('UTC')
  .onRun(calculateWeeklyAnalytics);

// Monthly analytics calculation (1st of month 2 AM JST)
export const monthlyAnalyticsBatch = functions
  .region('asia-northeast1')
  .pubsub
  .schedule('0 17 1 * *')
  .timeZone('UTC')
  .onRun(calculateMonthlyAnalytics);

// User metrics update trigger (on answer log change)
export const onAnswerLogCreated = functions
  .region('asia-northeast1')
  .firestore
  .document('users/{uid}/answerLogs/{logId}')
  .onCreate(updateUserMetrics);

// Pass threshold detector (on prediction score update)
export const onPredictionScoreUpdated = functions
  .region('asia-northeast1')
  .firestore
  .document('users/{uid}/metadata/predictionScore')
  .onUpdate(detectPassThreshold);
