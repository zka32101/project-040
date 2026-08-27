# Cloud Functions - Firebase Analytics & Aggregation

Complete server-side analytics processing for the Bike License Kore app.

## Overview

This Cloud Functions implementation provides:
- **Real-time event aggregation** via Firestore triggers
- **Daily/Weekly/Monthly batch processing** via Cloud Scheduler
- **User metrics computation** on answer log creation
- **Pass threshold detection** and milestone notifications
- **Comprehensive testing** with 30+ test cases

## Architecture

### Event Flow
```
User Action (answer, unlock, complete)
    ↓
Client-side tracking (Flutter app)
    ↓
Firestore writes (analyticsEvents)
    ↓
Cloud Function triggers (real-time aggregation)
    ↓
Hourly/Daily aggregation documents
    ↓
Scheduled batch processors (daily/weekly/monthly)
    ↓
Dashboard queries & notifications
```

### Firestore Structure

```
users/{uid}/
├── analyticsEvents/          # Raw event stream (auto-cleanup)
│   └── {eventId}/
│       ├── type: string      # Event type (e.g., "questionAnswered")
│       ├── timestamp
│       ├── userId
│       ├── sessionId
│       └── parameters: {}    # Event-specific data
│
├── answerLogs/              # Answers to questions
│   └── {logId}/
│       ├── questionId
│       ├── isCorrect
│       └── answeredAt
│
├── metadata/
│   └── predictionScore/     # User's pass prediction
│       ├── score: 0-100
│       ├── breakdown: {}    # By category
│       └── calculatedAt
│
└── analytics/               # Aggregated analytics
    ├── eventStats/          # Current hour aggregation
    ├── hourly_{YYYYMMDD}_{HH}/
    ├── daily_{YYYYMMDD}/
    ├── daily_{YYYYMMDD}_summary/
    ├── weekly_{YYYYMMDD}/
    ├── monthly_{YYYY}_{MM}/
    ├── category_{categoryId}/
    ├── sessionStats/
    └── userMetrics/
```

## Functions

### Real-time Triggers

#### `onAnalyticsEventCreated`
- **Trigger**: Firestore `users/{uid}/analyticsEvents/{eventId}` onCreate
- **Purpose**: Aggregate events in real-time for fast queries
- **Updates**:
  - Hourly stats (eventCount, eventTypes, sessionIds)
  - Daily stats (similar aggregation)
  - Category-specific stats for question answers
  - Session stats for quiz completion

#### `onAnswerLogCreated`
- **Trigger**: Firestore `users/{uid}/answerLogs/{logId}` onCreate
- **Purpose**: Update user metrics with each answered question
- **Updates**:
  - Overall accuracy and attempt counts
  - Category-specific accuracy
  - Strength/weakness classification

#### `onPredictionScoreUpdated`
- **Trigger**: Firestore `users/{uid}/metadata/predictionScore` onUpdate
- **Purpose**: Detect milestone achievements
- **Actions**:
  - Notify when 50%, 70%, 80%, 90%, 100% thresholds reached
  - Record milestone events
  - Store notifications in Firestore

### Scheduled Batch Functions

#### `dailyAnalyticsBatch`
- **Schedule**: Daily at 17:00 UTC (2:00 AM JST next day)
- **Duration**: ~5-15 seconds (depending on user count)
- **Processing**:
  1. Aggregate hourly data for previous day
  2. Calculate daily statistics
  3. Identify top categories by accuracy
  4. Store daily summary for dashboard
  
- **Metrics**:
  - Total events, questions answered, accuracy
  - Sessions completed, average duration
  - Event type distribution
  - Top 5 categories by accuracy

#### `weeklyAnalyticsBatch`
- **Schedule**: Every Sunday 17:00 UTC
- **Duration**: ~30 seconds
- **Processing**:
  1. Aggregate 7 days of daily stats
  2. Calculate weekly performance metrics
  3. Compare to previous week (improvement rate)
  4. Store weekly summary
  
- **Metrics**:
  - Weekly accuracy, session count
  - Category performance
  - Improvement rate vs previous week

#### `monthlyAnalyticsBatch`
- **Schedule**: 1st of month at 17:00 UTC
- **Duration**: ~1 minute
- **Processing**:
  1. Aggregate all daily stats from previous month
  2. Calculate monthly statistics
  3. Calculate study streak (days with activity)
  4. Compare to previous month
  
- **Metrics**:
  - Monthly accuracy, session count
  - Study consistency (days active / total days)
  - Average session duration
  - Improvement rate vs previous month

## Configuration

### Environment Setup

1. **Create functions directory**:
   ```bash
   firebase functions:config:set \
     app.project_id="your-project-id" \
     app.region="asia-northeast1"
   ```

2. **Install dependencies**:
   ```bash
   cd functions
   npm install
   ```

3. **Build TypeScript**:
   ```bash
   npm run build
   ```

4. **Deploy**:
   ```bash
   npm run deploy
   # or
   firebase deploy --only functions
   ```

### Local Development

Run emulator locally:
```bash
npm run serve
# or
firebase emulators:start --only functions,firestore
```

Test functions:
```bash
npm test
npm run test:watch
npm run test:coverage
```

## Function Performance

### Execution Time Targets

| Function | Target | Notes |
|----------|--------|-------|
| `onAnalyticsEventCreated` | <100ms | Real-time, must be fast |
| `onAnswerLogCreated` | <100ms | Real-time, called frequently |
| `onPredictionScoreUpdated` | <200ms | Real-time, with notifications |
| `dailyAnalyticsBatch` | <15s | 150-500 users typical |
| `weeklyAnalyticsBatch` | <30s | Aggregate 7 days |
| `monthlyAnalyticsBatch` | <60s | Aggregate 28-31 days |

### Cost Optimization

- **Event aggregation**: Uses Firestore field increments (atomic operations)
- **Batch operations**: Groups writes into minimal batches
- **Query optimization**: Uses document ID prefixes for efficient filtering
- **Cache warming**: Scheduled functions populate frequently-accessed documents
- **Cleanup**: Old analytics events archived/deleted after 30 days (implement via separate function)

## Testing

### Test Coverage

- **Event aggregation**: 15+ tests
- **Batch processors**: 15+ tests
- **User metrics**: 10+ tests
- **Threshold detection**: 8+ tests
- **Total**: 50+ test cases

### Running Tests

```bash
# Run all tests
npm test

# Run in watch mode (for development)
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### Example Test

```typescript
test('should aggregate hourly data into daily summary', () => {
  const hourlyData = [
    { hour: '00', events: 5, correct: 4 },
    { hour: '01', events: 3, correct: 2 },
  ];

  const daily = hourlyData.reduce(
    (acc, hour) => ({
      events: acc.events + hour.events,
      correct: acc.correct + hour.correct,
    }),
    { events: 0, correct: 0 },
  );

  expect(daily.events).toBe(8);
  expect((daily.correct / daily.events) * 100).toBe(75);
});
```

## Monitoring

### Key Metrics to Watch

1. **Execution time** (CloudFunctions metrics)
   - Set alerts if > 2x target time
   - Indicates performance degradation

2. **Error rate**
   - Track failed invocations
   - Monitor for spikes

3. **Data accuracy**
   - Spot-check daily summaries vs hourly aggregations
   - Verify accuracy calculations

4. **Cost**
   - Monitor invocation count
   - Watch for unexpected spikes

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| High latency | Too many users | Optimize queries, consider sharding |
| Batch timeout | Batch too large | Reduce batch size or parallelize |
| Data inconsistency | Race conditions | Use transactions for multi-doc updates |
| Cost overage | Too many invocations | Review trigger logic, add debouncing |

## Deployment Checklist

- [ ] All tests passing locally
- [ ] Code reviewed
- [ ] Function names and triggers match Firestore structure
- [ ] Permissions configured (Firebase rules)
- [ ] Error handling in place
- [ ] Logging configured
- [ ] Performance targets met
- [ ] Cost estimates reviewed
- [ ] Monitoring alerts set up
- [ ] Disaster recovery plan

## Future Enhancements

1. **Event cleanup**: Archive old analytics events to BigQuery
2. **Advanced analytics**: ML-based weak area detection
3. **Real-time dashboard**: WebSocket updates for live stats
4. **Custom reports**: User-defined analytics queries
5. **A/B testing**: Experiment tracking and analysis
6. **Performance optimization**: Parallel batch processing with worktasks

## Support & Debugging

### Enable detailed logging

```typescript
functions.logger.info('Message', { key: value });
functions.logger.error('Error', { error });
functions.logger.debug('Debug', { context });
```

### View logs

```bash
# Recent logs
firebase functions:log

# Specific function
firebase functions:log --function=onAnalyticsEventCreated
```

### Emulator debugging

```bash
firebase emulators:start --only functions,firestore
# Emulator UI runs at http://localhost:4000
```

---

## Files

- `src/index.ts` - Main function exports
- `src/analytics/eventAggregator.ts` - Real-time event aggregation
- `src/analytics/dailyBatchProcessor.ts` - Daily aggregation
- `src/analytics/weeklyBatchProcessor.ts` - Weekly aggregation
- `src/analytics/monthlyBatchProcessor.ts` - Monthly aggregation
- `src/analytics/userMetricsUpdater.ts` - User metrics on answer
- `src/analytics/passThresholdDetector.ts` - Milestone detection
- `src/__tests__/eventAggregator.test.ts` - Event aggregation tests
- `src/__tests__/batchProcessors.test.ts` - Batch processor tests

## Resources

- [Firebase Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [Firestore Triggers](https://firebase.google.com/docs/functions/firestore-events)
- [Cloud Scheduler](https://firebase.google.com/docs/functions/schedule-functions)
- [Firebase Emulator](https://firebase.google.com/docs/emulator-suite)
