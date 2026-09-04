import '../models/dashboard_models.dart';

abstract class DashboardRepository {
  Future<void> createDashboard(Dashboard dashboard);
  Future<Dashboard?> getDashboard(String dashboardId);
  Future<List<Dashboard>> getAllDashboards();
  Future<void> updateDashboard(Dashboard dashboard);
  Future<void> deleteDashboard(String dashboardId);

  Future<void> createWidget(DashboardWidget widget);
  Future<DashboardWidget?> getWidget(String widgetId);
  Future<List<DashboardWidget>> getWidgetsByDashboard(String dashboardId);
  Future<void> updateWidget(DashboardWidget widget);
  Future<void> deleteWidget(String widgetId);

  Future<void> saveChartData(ChartData chartData);
  Future<ChartData?> getChartData(String chartId);
  Future<List<ChartData>> getChartDataByDashboard(String dashboardId);

  Future<void> saveVisualizationConfig(VisualizationConfig config);
  Future<VisualizationConfig?> getVisualizationConfig(String configId);
  Future<List<VisualizationConfig>> getAllConfigs();

  Future<void> createRefresh(DashboardRefresh refresh);
  Future<DashboardRefresh?> getRefresh(String refreshId);
  Future<List<DashboardRefresh>> getDashboardsNeedingRefresh();
  Future<void> updateRefresh(DashboardRefresh refresh);

  Future<void> createTheme(DashboardTheme theme);
  Future<DashboardTheme?> getTheme(String themeId);
  Future<List<DashboardTheme>> getAllThemes();

  Future<void> createFilter(DashboardFilter filter);
  Future<DashboardFilter?> getFilter(String filterId);
  Future<List<DashboardFilter>> getFiltersByDashboard(String dashboardId);
  Future<void> updateFilter(DashboardFilter filter);

  Future<void> saveMetadata(DashboardMetadata metadata);
  Future<DashboardMetadata?> getMetadata(String metadataId);

  Future<void> grantPermission(DashboardPermission permission);
  Future<List<DashboardPermission>> getPermissionsByDashboard(String dashboardId);
  Future<List<DashboardPermission>> getPermissionsByUser(String userId);

  Future<void> captureSnapshot(DashboardSnapshot snapshot);
  Future<DashboardSnapshot?> getSnapshot(String snapshotId);
  Future<List<DashboardSnapshot>> getSnapshotsByDashboard(String dashboardId);

  Future<void> createLibrary(VisualizationLibrary library);
  Future<VisualizationLibrary?> getLibrary(String libraryId);
  Future<List<VisualizationLibrary>> getAllLibraries();
}

class MemoryDashboardRepository implements DashboardRepository {
  final Map<String, Dashboard> _dashboards = {};
  final Map<String, DashboardWidget> _widgets = {};
  final Map<String, ChartData> _chartData = {};
  final Map<String, VisualizationConfig> _configs = {};
  final Map<String, DashboardRefresh> _refreshes = {};
  final Map<String, DashboardTheme> _themes = {};
  final Map<String, DashboardFilter> _filters = {};
  final Map<String, DashboardMetadata> _metadata = {};
  final Map<String, DashboardPermission> _permissions = {};
  final Map<String, DashboardSnapshot> _snapshots = {};
  final Map<String, VisualizationLibrary> _libraries = {};

  @override
  Future<void> createDashboard(Dashboard dashboard) async => _dashboards[dashboard.dashboardId] = dashboard;

  @override
  Future<Dashboard?> getDashboard(String dashboardId) async => _dashboards[dashboardId];

  @override
  Future<List<Dashboard>> getAllDashboards() async => _dashboards.values.toList();

  @override
  Future<void> updateDashboard(Dashboard dashboard) async => _dashboards[dashboard.dashboardId] = dashboard;

  @override
  Future<void> deleteDashboard(String dashboardId) async => _dashboards.remove(dashboardId);

  @override
  Future<void> createWidget(DashboardWidget widget) async => _widgets[widget.widgetId] = widget;

  @override
  Future<DashboardWidget?> getWidget(String widgetId) async => _widgets[widgetId];

  @override
  Future<List<DashboardWidget>> getWidgetsByDashboard(String dashboardId) async =>
      _widgets.values.where((w) => w.dashboardId == dashboardId).toList();

  @override
  Future<void> updateWidget(DashboardWidget widget) async => _widgets[widget.widgetId] = widget;

  @override
  Future<void> deleteWidget(String widgetId) async => _widgets.remove(widgetId);

  @override
  Future<void> saveChartData(ChartData chartData) async => _chartData[chartData.chartId] = chartData;

  @override
  Future<ChartData?> getChartData(String chartId) async => _chartData[chartId];

  @override
  Future<List<ChartData>> getChartDataByDashboard(String dashboardId) async {
    final dashboard = await getDashboard(dashboardId);
    if (dashboard == null) return [];
    return _chartData.values.where((c) => dashboard.widgetIds.contains(c.chartId)).toList();
  }

  @override
  Future<void> saveVisualizationConfig(VisualizationConfig config) async =>
      _configs[config.configId] = config;

  @override
  Future<VisualizationConfig?> getVisualizationConfig(String configId) async => _configs[configId];

  @override
  Future<List<VisualizationConfig>> getAllConfigs() async => _configs.values.toList();

  @override
  Future<void> createRefresh(DashboardRefresh refresh) async => _refreshes[refresh.refreshId] = refresh;

  @override
  Future<DashboardRefresh?> getRefresh(String refreshId) async => _refreshes[refreshId];

  @override
  Future<List<DashboardRefresh>> getDashboardsNeedingRefresh() async =>
      _refreshes.values.where((r) => r.isDueForRefresh && r.isEnabled).toList();

  @override
  Future<void> updateRefresh(DashboardRefresh refresh) async => _refreshes[refresh.refreshId] = refresh;

  @override
  Future<void> createTheme(DashboardTheme theme) async => _themes[theme.themeId] = theme;

  @override
  Future<DashboardTheme?> getTheme(String themeId) async => _themes[themeId];

  @override
  Future<List<DashboardTheme>> getAllThemes() async => _themes.values.toList();

  @override
  Future<void> createFilter(DashboardFilter filter) async => _filters[filter.filterId] = filter;

  @override
  Future<DashboardFilter?> getFilter(String filterId) async => _filters[filterId];

  @override
  Future<List<DashboardFilter>> getFiltersByDashboard(String dashboardId) async =>
      _filters.values.where((f) => f.dashboardId == dashboardId).toList();

  @override
  Future<void> updateFilter(DashboardFilter filter) async => _filters[filter.filterId] = filter;

  @override
  Future<void> saveMetadata(DashboardMetadata metadata) async => _metadata[metadata.metadataId] = metadata;

  @override
  Future<DashboardMetadata?> getMetadata(String metadataId) async => _metadata[metadataId];

  @override
  Future<void> grantPermission(DashboardPermission permission) async =>
      _permissions[permission.permissionId] = permission;

  @override
  Future<List<DashboardPermission>> getPermissionsByDashboard(String dashboardId) async =>
      _permissions.values.where((p) => p.dashboardId == dashboardId).toList();

  @override
  Future<List<DashboardPermission>> getPermissionsByUser(String userId) async =>
      _permissions.values.where((p) => p.userId == userId).toList();

  @override
  Future<void> captureSnapshot(DashboardSnapshot snapshot) async =>
      _snapshots[snapshot.snapshotId] = snapshot;

  @override
  Future<DashboardSnapshot?> getSnapshot(String snapshotId) async => _snapshots[snapshotId];

  @override
  Future<List<DashboardSnapshot>> getSnapshotsByDashboard(String dashboardId) async =>
      _snapshots.values.where((s) => s.dashboardId == dashboardId).toList();

  @override
  Future<void> createLibrary(VisualizationLibrary library) async =>
      _libraries[library.libraryId] = library;

  @override
  Future<VisualizationLibrary?> getLibrary(String libraryId) async => _libraries[libraryId];

  @override
  Future<List<VisualizationLibrary>> getAllLibraries() async => _libraries.values.toList();
}

class DashboardEngine {
  final DashboardRepository repository;

  DashboardEngine({required this.repository});

  Future<Dashboard> createNewDashboard(String name, String description) async {
    final dashboard = Dashboard(
      dashboardId: 'dash_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      widgetIds: [],
      layout: DashboardLayout.grid,
      createdAt: DateTime.now(),
    );
    await repository.createDashboard(dashboard);
    return dashboard;
  }

  Future<void> addWidgetToDashboard(String dashboardId, DashboardWidget widget) async {
    final dashboard = await repository.getDashboard(dashboardId);
    if (dashboard == null) throw Exception('Dashboard not found');
    
    await repository.createWidget(widget);
    final updatedDashboard = Dashboard(
      dashboardId: dashboard.dashboardId,
      name: dashboard.name,
      description: dashboard.description,
      widgetIds: [...dashboard.widgetIds, widget.widgetId],
      layout: dashboard.layout,
      createdAt: dashboard.createdAt,
      lastModifiedAt: DateTime.now(),
      isPublic: dashboard.isPublic,
      owner: dashboard.owner,
    );
    await repository.updateDashboard(updatedDashboard);
  }

  Future<void> setupAutoRefresh(String dashboardId, RefreshInterval interval) async {
    final refresh = DashboardRefresh(
      refreshId: 'refresh_${DateTime.now().millisecondsSinceEpoch}',
      dashboardId: dashboardId,
      interval: interval,
      lastRefreshAt: DateTime.now(),
      nextRefreshAt: _calculateNextRefreshTime(interval),
    );
    await repository.createRefresh(refresh);
  }

  DateTime _calculateNextRefreshTime(RefreshInterval interval) {
    final now = DateTime.now();
    switch (interval) {
      case RefreshInterval.realtime:
        return now.add(Duration(milliseconds: 100));
      case RefreshInterval.fiveSeconds:
        return now.add(Duration(seconds: 5));
      case RefreshInterval.thirtySeconds:
        return now.add(Duration(seconds: 30));
      case RefreshInterval.oneMinute:
        return now.add(Duration(minutes: 1));
      case RefreshInterval.fiveMinutes:
        return now.add(Duration(minutes: 5));
      case RefreshInterval.fifteenMinutes:
        return now.add(Duration(minutes: 15));
      case RefreshInterval.hourly:
        return now.add(Duration(hours: 1));
    }
  }
}

class VisualizationEngine {
  final DashboardRepository repository;

  VisualizationEngine({required this.repository});

  Future<ChartData> generateChartData(String chartId, List<DataPoint> points,
      String xLabel, String yLabel) async {
    final chartData = ChartData(
      chartId: chartId,
      points: points,
      xAxisLabel: xLabel,
      yAxisLabel: yLabel,
      generatedAt: DateTime.now(),
    );
    await repository.saveChartData(chartData);
    return chartData;
  }

  Future<VisualizationConfig> createConfig(String chartType,
      Map<String, dynamic> styleOptions, Map<String, dynamic> dataOptions) async {
    final config = VisualizationConfig(
      configId: 'vconfig_${DateTime.now().millisecondsSinceEpoch}',
      chartType: chartType,
      styleOptions: styleOptions,
      dataOptions: dataOptions,
      createdAt: DateTime.now(),
    );
    await repository.saveVisualizationConfig(config);
    return config;
  }
}

class DashboardManager {
  final DashboardRepository repository;
  final DashboardEngine dashboardEngine;
  final VisualizationEngine visualizationEngine;

  DashboardManager({
    required this.repository,
    required this.dashboardEngine,
    required this.visualizationEngine,
  });

  Future<Dashboard> initializeDashboard(String name, String description) async {
    return await dashboardEngine.createNewDashboard(name, description);
  }

  Future<void> addWidget(String dashboardId, DashboardWidget widget) async {
    await dashboardEngine.addWidgetToDashboard(dashboardId, widget);
  }

  Future<void> setupRefresh(String dashboardId, RefreshInterval interval) async {
    await dashboardEngine.setupAutoRefresh(dashboardId, interval);
  }

  Future<void> grantAccess(String dashboardId, String userId, String accessLevel) async {
    final permission = DashboardPermission(
      permissionId: 'perm_${DateTime.now().millisecondsSinceEpoch}',
      dashboardId: dashboardId,
      userId: userId,
      accessLevel: accessLevel,
      grantedAt: DateTime.now(),
    );
    await repository.grantPermission(permission);
  }

  Future<ChartData> createChart(String chartId, List<DataPoint> points,
      String xLabel, String yLabel) async {
    return await visualizationEngine.generateChartData(chartId, points, xLabel, yLabel);
  }

  Future<List<DashboardWidget>> getDashboardWidgets(String dashboardId) async {
    return await repository.getWidgetsByDashboard(dashboardId);
  }
}

class DashboardFacade {
  final DashboardManager manager;

  DashboardFacade({required DashboardManager? manager})
      : manager = manager ??
            DashboardManager(
              repository: MemoryDashboardRepository(),
              dashboardEngine: DashboardEngine(repository: MemoryDashboardRepository()),
              visualizationEngine: VisualizationEngine(repository: MemoryDashboardRepository()),
            );

  Future<Dashboard> createDashboard(String name, String description) async {
    return await manager.initializeDashboard(name, description);
  }

  Future<Dashboard?> getDashboard(String dashboardId) async {
    return await manager.repository.getDashboard(dashboardId);
  }

  Future<List<Dashboard>> listDashboards() async {
    return await manager.repository.getAllDashboards();
  }

  Future<void> addWidgetToDashboard(String dashboardId, DashboardWidget widget) async {
    await manager.addWidget(dashboardId, widget);
  }

  Future<List<DashboardWidget>> getDashboardWidgets(String dashboardId) async {
    return await manager.getDashboardWidgets(dashboardId);
  }

  Future<void> enableAutoRefresh(String dashboardId, RefreshInterval interval) async {
    await manager.setupRefresh(dashboardId, interval);
  }

  Future<void> shareWithUser(String dashboardId, String userId, String accessLevel) async {
    await manager.grantAccess(dashboardId, userId, accessLevel);
  }

  Future<ChartData> createChart(String chartId, List<DataPoint> points,
      String xLabel, String yLabel) async {
    return await manager.createChart(chartId, points, xLabel, yLabel);
  }

  Future<DashboardTheme> createTheme(String name, ThemeType type,
      Map<String, String> colors, Map<String, dynamic> styles) async {
    final theme = DashboardTheme(
      themeId: 'theme_${DateTime.now().millisecondsSinceEpoch}',
      themeName: name,
      themeType: type,
      colorScheme: colors,
      styleConfig: styles,
      createdAt: DateTime.now(),
    );
    await manager.repository.createTheme(theme);
    return theme;
  }

  Future<List<DashboardTheme>> listThemes() async {
    return await manager.repository.getAllThemes();
  }

  Future<void> addFilterToDashboard(String dashboardId, String field,
      dynamic value, String filterName) async {
    final filter = DashboardFilter(
      filterId: 'filter_${DateTime.now().millisecondsSinceEpoch}',
      dashboardId: dashboardId,
      filterName: filterName,
      field: field,
      value: value,
      createdAt: DateTime.now(),
    );
    await manager.repository.createFilter(filter);
  }

  Future<List<DashboardFilter>> getDashboardFilters(String dashboardId) async {
    return await manager.repository.getFiltersByDashboard(dashboardId);
  }

  Future<void> captureSnapshot(String dashboardId, Map<String, dynamic> state,
      String? description) async {
    final snapshot = DashboardSnapshot(
      snapshotId: 'snap_${DateTime.now().millisecondsSinceEpoch}',
      dashboardId: dashboardId,
      dashboardState: state,
      capturedAt: DateTime.now(),
      description: description,
    );
    await manager.repository.captureSnapshot(snapshot);
  }

  Future<List<DashboardSnapshot>> getDashboardSnapshots(String dashboardId) async {
    return await manager.repository.getSnapshotsByDashboard(dashboardId);
  }

  Future<VisualizationLibrary> createLibrary(String name, List<String> widgetIds) async {
    final library = VisualizationLibrary(
      libraryId: 'lib_${DateTime.now().millisecondsSinceEpoch}',
      libraryName: name,
      widgetIds: widgetIds,
      createdAt: DateTime.now(),
    );
    await manager.repository.createLibrary(library);
    return library;
  }

  Future<List<VisualizationLibrary>> listLibraries() async {
    return await manager.repository.getAllLibraries();
  }

  Future<List<DashboardRefresh>> getRefreshSchedules() async {
    return await manager.repository.getDashboardsNeedingRefresh();
  }
}
