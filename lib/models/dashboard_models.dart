/// Dashboard & Visualization Models

enum ChartType { lineChart, barChart, pieChart, areaChart, scatterChart, heatmap }
enum DashboardLayout { grid, flex, custom }
enum WidgetSize { small, medium, large, fullWidth }
enum DataSource { database, api, file, analytics }
enum RefreshInterval { realtime, fiveSeconds, thirtySeconds, oneMinute, fiveMinutes, fifteenMinutes, hourly }
enum ThemeType { light, dark, auto }

class Dashboard {
  final String dashboardId;
  final String name;
  final String description;
  final List<String> widgetIds;
  final DashboardLayout layout;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final bool isPublic;
  final String? owner;

  Dashboard({
    required this.dashboardId,
    required this.name,
    required this.description,
    required this.widgetIds,
    required this.layout,
    required this.createdAt,
    this.lastModifiedAt,
    this.isPublic = false,
    this.owner,
  });

  bool get isRecent => DateTime.now().difference(createdAt).inDays < 30;
  int get widgetCount => widgetIds.length;
  bool get isEmpty => widgetIds.isEmpty;
}

class DashboardWidget {
  final String widgetId;
  final String dashboardId;
  final String title;
  final String description;
  final ChartType chartType;
  final WidgetSize size;
  final Map<String, dynamic> config;
  final DateTime createdAt;
  final bool isActive;

  DashboardWidget({
    required this.widgetId,
    required this.dashboardId,
    required this.title,
    required this.description,
    required this.chartType,
    required this.size,
    required this.config,
    required this.createdAt,
    this.isActive = true,
  });

  bool get isConfigured => config.isNotEmpty;
  int get configSize => config.length;
}

class ChartData {
  final String chartId;
  final List<DataPoint> points;
  final String xAxisLabel;
  final String yAxisLabel;
  final DateTime generatedAt;

  ChartData({
    required this.chartId,
    required this.points,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.generatedAt,
  });

  bool get hasData => points.isNotEmpty;
  int get dataPointCount => points.length;
  double? get minValue => points.isEmpty ? null : points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
  double? get maxValue => points.isEmpty ? null : points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
}

class DataPoint {
  final String label;
  final double value;
  final DateTime? timestamp;
  final Map<String, dynamic>? metadata;

  DataPoint({
    required this.label,
    required this.value,
    this.timestamp,
    this.metadata,
  });

  bool get hasMetadata => metadata != null && metadata!.isNotEmpty;
}

class VisualizationConfig {
  final String configId;
  final String chartType;
  final Map<String, dynamic> styleOptions;
  final Map<String, dynamic> dataOptions;
  final DateTime createdAt;

  VisualizationConfig({
    required this.configId,
    required this.chartType,
    required this.styleOptions,
    required this.dataOptions,
    required this.createdAt,
  });

  bool get isComplete => styleOptions.isNotEmpty && dataOptions.isNotEmpty;
  int get totalOptions => styleOptions.length + dataOptions.length;
}

class DashboardRefresh {
  final String refreshId;
  final String dashboardId;
  final RefreshInterval interval;
  final DateTime lastRefreshAt;
  final DateTime? nextRefreshAt;
  final bool isEnabled;

  DashboardRefresh({
    required this.refreshId,
    required this.dashboardId,
    required this.interval,
    required this.lastRefreshAt,
    this.nextRefreshAt,
    this.isEnabled = true,
  });

  bool get isDueForRefresh => nextRefreshAt != null && DateTime.now().isAfter(nextRefreshAt!);
  int get secondsSinceRefresh => DateTime.now().difference(lastRefreshAt).inSeconds;
}

class DashboardTheme {
  final String themeId;
  final String themeName;
  final ThemeType themeType;
  final Map<String, String> colorScheme;
  final Map<String, dynamic> styleConfig;
  final DateTime createdAt;

  DashboardTheme({
    required this.themeId,
    required this.themeName,
    required this.themeType,
    required this.colorScheme,
    required this.styleConfig,
    required this.createdAt,
  });

  bool get isLight => themeType == ThemeType.light;
  bool get isDark => themeType == ThemeType.dark;
  int get colorCount => colorScheme.length;
}

class DashboardFilter {
  final String filterId;
  final String dashboardId;
  final String filterName;
  final String field;
  final dynamic value;
  final DateTime createdAt;

  DashboardFilter({
    required this.filterId,
    required this.dashboardId,
    required this.filterName,
    required this.field,
    required this.value,
    required this.createdAt,
  });

  bool get isActive => value != null;
}

class DashboardMetadata {
  final String metadataId;
  final String dashboardId;
  final int viewCount;
  final int editCount;
  final DateTime lastViewedAt;
  final DateTime lastEditedAt;
  final List<String> tags;

  DashboardMetadata({
    required this.metadataId,
    required this.dashboardId,
    required this.viewCount,
    required this.editCount,
    required this.lastViewedAt,
    required this.lastEditedAt,
    required this.tags,
  });

  bool get isPopular => viewCount > 100;
  bool get isFrequentlyEdited => editCount > 20;
  bool get hasNotBeenViewed => viewCount == 0;
}

class DashboardPermission {
  final String permissionId;
  final String dashboardId;
  final String userId;
  final String accessLevel;
  final DateTime grantedAt;

  DashboardPermission({
    required this.permissionId,
    required this.dashboardId,
    required this.userId,
    required this.accessLevel,
    required this.grantedAt,
  });

  bool get canView => accessLevel == 'view' || accessLevel == 'edit' || accessLevel == 'admin';
  bool get canEdit => accessLevel == 'edit' || accessLevel == 'admin';
  bool get isAdmin => accessLevel == 'admin';
}

class DashboardSnapshot {
  final String snapshotId;
  final String dashboardId;
  final Map<String, dynamic> dashboardState;
  final DateTime capturedAt;
  final String? description;

  DashboardSnapshot({
    required this.snapshotId,
    required this.dashboardId,
    required this.dashboardState,
    required this.capturedAt,
    this.description,
  });

  bool get isRecent => DateTime.now().difference(capturedAt).inDays < 7;
  int get ageInDays => DateTime.now().difference(capturedAt).inDays;
}

class VisualizationLibrary {
  final String libraryId;
  final String libraryName;
  final List<String> widgetIds;
  final DateTime createdAt;
  final bool isPublic;

  VisualizationLibrary({
    required this.libraryId,
    required this.libraryName,
    required this.widgetIds,
    required this.createdAt,
    this.isPublic = false,
  });

  bool get isEmpty => widgetIds.isEmpty;
  int get widgetCount => widgetIds.length;
}
