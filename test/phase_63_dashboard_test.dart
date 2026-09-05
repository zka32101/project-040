import 'package:flutter_test/flutter_test.dart';
import '../lib/models/dashboard_models.dart';
import '../lib/services/dashboard_service.dart';

void main() {
  group('Phase 63: Dashboard & Visualization Tests', () {
    late DashboardFacade facade;
    late MemoryDashboardRepository repository;

    setUp(() {
      repository = MemoryDashboardRepository();
      final dashboardEngine = DashboardEngine(repository: repository);
      final visualizationEngine = VisualizationEngine(repository: repository);
      final manager = DashboardManager(
        repository: repository,
        dashboardEngine: dashboardEngine,
        visualizationEngine: visualizationEngine,
      );
      facade = DashboardFacade(manager: manager);
    });

    group('Enum Tests', () {
      test('ChartType enum has all values', () {
        expect(ChartType.values.length, 6);
        expect(ChartType.values, contains(ChartType.lineChart));
        expect(ChartType.values, contains(ChartType.barChart));
        expect(ChartType.values, contains(ChartType.pieChart));
      });

      test('DashboardLayout enum has all values', () {
        expect(DashboardLayout.values.length, 3);
        expect(DashboardLayout.values, contains(DashboardLayout.grid));
      });

      test('WidgetSize enum has all values', () {
        expect(WidgetSize.values.length, 4);
      });

      test('RefreshInterval enum has all values', () {
        expect(RefreshInterval.values.length, 7);
      });

      test('ThemeType enum has all values', () {
        expect(ThemeType.values.length, 3);
      });
    });

    group('Dashboard Model Tests', () {
      test('Create dashboard', () {
        final dashboard = Dashboard(
          dashboardId: 'dash1',
          name: 'Sales Dashboard',
          description: 'Sales performance dashboard',
          widgetIds: ['widget1', 'widget2'],
          layout: DashboardLayout.grid,
          createdAt: DateTime.now(),
        );
        expect(dashboard.dashboardId, 'dash1');
        expect(dashboard.widgetCount, 2);
        expect(dashboard.isEmpty, false);
      });

      test('Dashboard computed properties', () {
        final dashboard = Dashboard(
          dashboardId: 'dash1',
          name: 'Dashboard',
          description: 'Test',
          widgetIds: [],
          layout: DashboardLayout.grid,
          createdAt: DateTime.now().subtract(Duration(days: 5)),
        );
        expect(dashboard.isRecent, true);
        expect(dashboard.isEmpty, true);
      });

      test('Dashboard isRecent returns false for old dashboards', () {
        final dashboard = Dashboard(
          dashboardId: 'dash1',
          name: 'Dashboard',
          description: 'Test',
          widgetIds: [],
          layout: DashboardLayout.grid,
          createdAt: DateTime.now().subtract(Duration(days: 40)),
        );
        expect(dashboard.isRecent, false);
      });
    });

    group('DashboardWidget Model Tests', () {
      test('Create widget', () {
        final widget = DashboardWidget(
          widgetId: 'widget1',
          dashboardId: 'dash1',
          title: 'Sales Chart',
          description: 'Monthly sales',
          chartType: ChartType.barChart,
          size: WidgetSize.medium,
          config: {'colors': ['red', 'blue']},
          createdAt: DateTime.now(),
        );
        expect(widget.widgetId, 'widget1');
        expect(widget.isConfigured, true);
        expect(widget.configSize, 1);
      });
    });

    group('ChartData Model Tests', () {
      test('Create chart data', () {
        final data = ChartData(
          chartId: 'chart1',
          points: [
            DataPoint(label: 'Jan', value: 100),
            DataPoint(label: 'Feb', value: 150),
          ],
          xAxisLabel: 'Month',
          yAxisLabel: 'Sales',
          generatedAt: DateTime.now(),
        );
        expect(data.chartId, 'chart1');
        expect(data.hasData, true);
        expect(data.dataPointCount, 2);
      });

      test('Chart data min/max values', () {
        final data = ChartData(
          chartId: 'chart1',
          points: [
            DataPoint(label: 'Jan', value: 100),
            DataPoint(label: 'Feb', value: 50),
            DataPoint(label: 'Mar', value: 200),
          ],
          xAxisLabel: 'Month',
          yAxisLabel: 'Sales',
          generatedAt: DateTime.now(),
        );
        expect(data.minValue, 50.0);
        expect(data.maxValue, 200.0);
      });
    });

    group('DataPoint Model Tests', () {
      test('Create data point', () {
        final point = DataPoint(label: 'January', value: 100.5);
        expect(point.label, 'January');
        expect(point.value, 100.5);
        expect(point.hasMetadata, false);
      });

      test('Data point with metadata', () {
        final point = DataPoint(
          label: 'January',
          value: 100.5,
          metadata: {'region': 'North', 'quarter': 'Q1'},
        );
        expect(point.hasMetadata, true);
      });
    });

    group('VisualizationConfig Model Tests', () {
      test('Create visualization config', () {
        final config = VisualizationConfig(
          configId: 'config1',
          chartType: 'barChart',
          styleOptions: {'color': 'blue'},
          dataOptions: {'animated': true},
          createdAt: DateTime.now(),
        );
        expect(config.isComplete, true);
        expect(config.totalOptions, 2);
      });
    });

    group('DashboardRefresh Model Tests', () {
      test('Create refresh schedule', () {
        final refresh = DashboardRefresh(
          refreshId: 'refresh1',
          dashboardId: 'dash1',
          interval: RefreshInterval.fiveMinutes,
          lastRefreshAt: DateTime.now(),
        );
        expect(refresh.refreshId, 'refresh1');
        expect(refresh.isEnabled, true);
      });

      test('DashboardRefresh isDueForRefresh', () {
        final pastTime = DateTime.now().subtract(Duration(minutes: 10));
        final refresh = DashboardRefresh(
          refreshId: 'refresh1',
          dashboardId: 'dash1',
          interval: RefreshInterval.fiveMinutes,
          lastRefreshAt: pastTime,
          nextRefreshAt: DateTime.now().subtract(Duration(minutes: 1)),
        );
        expect(refresh.isDueForRefresh, true);
      });
    });

    group('DashboardTheme Model Tests', () {
      test('Create theme', () {
        final theme = DashboardTheme(
          themeId: 'theme1',
          themeName: 'Dark Mode',
          themeType: ThemeType.dark,
          colorScheme: {'primary': '#000000', 'secondary': '#FFFFFF'},
          styleConfig: {},
          createdAt: DateTime.now(),
        );
        expect(theme.isDark, true);
        expect(theme.isLight, false);
        expect(theme.colorCount, 2);
      });
    });

    group('DashboardFilter Model Tests', () {
      test('Create filter', () {
        final filter = DashboardFilter(
          filterId: 'filter1',
          dashboardId: 'dash1',
          filterName: 'Region',
          field: 'region',
          value: 'North',
          createdAt: DateTime.now(),
        );
        expect(filter.isActive, true);
      });
    });

    group('DashboardMetadata Model Tests', () {
      test('Create metadata', () {
        final metadata = DashboardMetadata(
          metadataId: 'meta1',
          dashboardId: 'dash1',
          viewCount: 150,
          editCount: 25,
          lastViewedAt: DateTime.now(),
          lastEditedAt: DateTime.now(),
          tags: ['sales', 'monthly'],
        );
        expect(metadata.isPopular, true);
        expect(metadata.isFrequentlyEdited, true);
      });

      test('Dashboard not viewed', () {
        final metadata = DashboardMetadata(
          metadataId: 'meta1',
          dashboardId: 'dash1',
          viewCount: 0,
          editCount: 0,
          lastViewedAt: DateTime.now(),
          lastEditedAt: DateTime.now(),
          tags: [],
        );
        expect(metadata.hasNotBeenViewed, true);
      });
    });

    group('DashboardPermission Model Tests', () {
      test('Create permission with view access', () {
        final perm = DashboardPermission(
          permissionId: 'perm1',
          dashboardId: 'dash1',
          userId: 'user1',
          accessLevel: 'view',
          grantedAt: DateTime.now(),
        );
        expect(perm.canView, true);
        expect(perm.canEdit, false);
        expect(perm.isAdmin, false);
      });

      test('Admin permission', () {
        final perm = DashboardPermission(
          permissionId: 'perm1',
          dashboardId: 'dash1',
          userId: 'user1',
          accessLevel: 'admin',
          grantedAt: DateTime.now(),
        );
        expect(perm.isAdmin, true);
        expect(perm.canEdit, true);
      });
    });

    group('DashboardSnapshot Model Tests', () {
      test('Create snapshot', () {
        final snapshot = DashboardSnapshot(
          snapshotId: 'snap1',
          dashboardId: 'dash1',
          dashboardState: {'widgets': [], 'theme': 'dark'},
          capturedAt: DateTime.now(),
        );
        expect(snapshot.isRecent, true);
      });

      test('Snapshot age calculation', () {
        final snapshot = DashboardSnapshot(
          snapshotId: 'snap1',
          dashboardId: 'dash1',
          dashboardState: {},
          capturedAt: DateTime.now().subtract(Duration(days: 10)),
        );
        expect(snapshot.ageInDays, 10);
      });
    });

    group('VisualizationLibrary Model Tests', () {
      test('Create library', () {
        final library = VisualizationLibrary(
          libraryId: 'lib1',
          libraryName: 'Sales Charts',
          widgetIds: ['widget1', 'widget2', 'widget3'],
          createdAt: DateTime.now(),
        );
        expect(library.widgetCount, 3);
        expect(library.isEmpty, false);
      });
    });

    group('Repository Tests', () {
      test('Create and retrieve dashboard', () async {
        final dashboard = Dashboard(
          dashboardId: 'dash1',
          name: 'Test Dashboard',
          description: 'Test',
          widgetIds: [],
          layout: DashboardLayout.grid,
          createdAt: DateTime.now(),
        );
        await repository.createDashboard(dashboard);
        final retrieved = await repository.getDashboard('dash1');
        expect(retrieved?.name, 'Test Dashboard');
      });

      test('Update dashboard', () async {
        final dashboard = Dashboard(
          dashboardId: 'dash1',
          name: 'Original',
          description: 'Test',
          widgetIds: [],
          layout: DashboardLayout.grid,
          createdAt: DateTime.now(),
        );
        await repository.createDashboard(dashboard);
        
        final updated = Dashboard(
          dashboardId: 'dash1',
          name: 'Updated',
          description: 'Test',
          widgetIds: [],
          layout: DashboardLayout.grid,
          createdAt: dashboard.createdAt,
        );
        await repository.updateDashboard(updated);
        
        final retrieved = await repository.getDashboard('dash1');
        expect(retrieved?.name, 'Updated');
      });

      test('Delete dashboard', () async {
        final dashboard = Dashboard(
          dashboardId: 'dash1',
          name: 'Test',
          description: 'Test',
          widgetIds: [],
          layout: DashboardLayout.grid,
          createdAt: DateTime.now(),
        );
        await repository.createDashboard(dashboard);
        await repository.deleteDashboard('dash1');
        final retrieved = await repository.getDashboard('dash1');
        expect(retrieved, isNull);
      });

      test('Create and retrieve widget', () async {
        final widget = DashboardWidget(
          widgetId: 'widget1',
          dashboardId: 'dash1',
          title: 'Chart',
          description: 'Test chart',
          chartType: ChartType.barChart,
          size: WidgetSize.medium,
          config: {},
          createdAt: DateTime.now(),
        );
        await repository.createWidget(widget);
        final retrieved = await repository.getWidget('widget1');
        expect(retrieved?.title, 'Chart');
      });

      test('Get widgets by dashboard', () async {
        await repository.createWidget(DashboardWidget(
          widgetId: 'w1',
          dashboardId: 'dash1',
          title: 'W1',
          description: 'Test',
          chartType: ChartType.barChart,
          size: WidgetSize.small,
          config: {},
          createdAt: DateTime.now(),
        ));
        await repository.createWidget(DashboardWidget(
          widgetId: 'w2',
          dashboardId: 'dash1',
          title: 'W2',
          description: 'Test',
          chartType: ChartType.lineChart,
          size: WidgetSize.medium,
          config: {},
          createdAt: DateTime.now(),
        ));
        final widgets = await repository.getWidgetsByDashboard('dash1');
        expect(widgets.length, 2);
      });

      test('Save and retrieve chart data', () async {
        final chartData = ChartData(
          chartId: 'chart1',
          points: [DataPoint(label: 'Jan', value: 100)],
          xAxisLabel: 'Month',
          yAxisLabel: 'Sales',
          generatedAt: DateTime.now(),
        );
        await repository.saveChartData(chartData);
        final retrieved = await repository.getChartData('chart1');
        expect(retrieved?.dataPointCount, 1);
      });

      test('Save and retrieve visualization config', () async {
        final config = VisualizationConfig(
          configId: 'config1',
          chartType: 'bar',
          styleOptions: {'color': 'blue'},
          dataOptions: {'animated': true},
          createdAt: DateTime.now(),
        );
        await repository.saveVisualizationConfig(config);
        final retrieved = await repository.getVisualizationConfig('config1');
        expect(retrieved?.chartType, 'bar');
      });

      test('Create and retrieve theme', () async {
        final theme = DashboardTheme(
          themeId: 'theme1',
          themeName: 'Light',
          themeType: ThemeType.light,
          colorScheme: {},
          styleConfig: {},
          createdAt: DateTime.now(),
        );
        await repository.createTheme(theme);
        final retrieved = await repository.getTheme('theme1');
        expect(retrieved?.themeName, 'Light');
      });

      test('Create and retrieve filter', () async {
        final filter = DashboardFilter(
          filterId: 'filter1',
          dashboardId: 'dash1',
          filterName: 'Status',
          field: 'status',
          value: 'active',
          createdAt: DateTime.now(),
        );
        await repository.createFilter(filter);
        final retrieved = await repository.getFilter('filter1');
        expect(retrieved?.filterName, 'Status');
      });

      test('Grant and retrieve permissions', () async {
        final perm = DashboardPermission(
          permissionId: 'perm1',
          dashboardId: 'dash1',
          userId: 'user1',
          accessLevel: 'edit',
          grantedAt: DateTime.now(),
        );
        await repository.grantPermission(perm);
        final perms = await repository.getPermissionsByUser('user1');
        expect(perms.isNotEmpty, true);
      });

      test('Capture and retrieve snapshot', () async {
        final snapshot = DashboardSnapshot(
          snapshotId: 'snap1',
          dashboardId: 'dash1',
          dashboardState: {},
          capturedAt: DateTime.now(),
        );
        await repository.captureSnapshot(snapshot);
        final retrieved = await repository.getSnapshot('snap1');
        expect(retrieved?.snapshotId, 'snap1');
      });

      test('Create and retrieve library', () async {
        final library = VisualizationLibrary(
          libraryId: 'lib1',
          libraryName: 'Charts',
          widgetIds: [],
          createdAt: DateTime.now(),
        );
        await repository.createLibrary(library);
        final retrieved = await repository.getLibrary('lib1');
        expect(retrieved?.libraryName, 'Charts');
      });
    });

    group('Dashboard Engine Tests', () {
      test('Create new dashboard', () async {
        final engine = DashboardEngine(repository: repository);
        final dashboard = await engine.createNewDashboard('Sales', 'Sales data');
        expect(dashboard.dashboardId, isNotEmpty);
        expect(dashboard.name, 'Sales');
      });

      test('Add widget to dashboard', () async {
        final engine = DashboardEngine(repository: repository);
        final dashboard = await engine.createNewDashboard('Test', 'Test');
        
        final widget = DashboardWidget(
          widgetId: 'w1',
          dashboardId: dashboard.dashboardId,
          title: 'Chart',
          description: 'Test',
          chartType: ChartType.barChart,
          size: WidgetSize.medium,
          config: {},
          createdAt: DateTime.now(),
        );
        await engine.addWidgetToDashboard(dashboard.dashboardId, widget);
        
        final updated = await repository.getDashboard(dashboard.dashboardId);
        expect(updated?.widgetCount, 1);
      });
    });

    group('Visualization Engine Tests', () {
      test('Generate chart data', () async {
        final engine = VisualizationEngine(repository: repository);
        final data = await engine.generateChartData(
          'chart1',
          [DataPoint(label: 'A', value: 10)],
          'X',
          'Y',
        );
        expect(data.chartId, 'chart1');
      });

      test('Create visualization config', () async {
        final engine = VisualizationEngine(repository: repository);
        final config = await engine.createConfig(
          'bar',
          {'color': 'blue'},
          {'animated': true},
        );
        expect(config.isComplete, true);
      });
    });

    group('Dashboard Facade Integration Tests', () {
      test('Complete dashboard workflow', () async {
        // Create dashboard
        final dashboard = await facade.createDashboard(
          'Sales Dashboard',
          'Monthly sales metrics',
        );
        expect(dashboard.dashboardId, isNotEmpty);

        // Add widget
        final widget = DashboardWidget(
          widgetId: 'widget1',
          dashboardId: dashboard.dashboardId,
          title: 'Revenue Chart',
          description: 'Revenue over time',
          chartType: ChartType.lineChart,
          size: WidgetSize.large,
          config: {'animated': true},
          createdAt: DateTime.now(),
        );
        await facade.addWidgetToDashboard(dashboard.dashboardId, widget);

        // Verify
        final widgets = await facade.getDashboardWidgets(dashboard.dashboardId);
        expect(widgets.length, 1);
      });

      test('Theme management', () async {
        final theme = await facade.createTheme(
          'Night Mode',
          ThemeType.dark,
          {'primary': '#000000'},
          {'borderRadius': 4},
        );
        expect(theme.isDark, true);

        final themes = await facade.listThemes();
        expect(themes.isNotEmpty, true);
      });

      test('Filter functionality', () async {
        final dashboard = await facade.createDashboard('Test', 'Test');
        await facade.addFilterToDashboard(
          dashboard.dashboardId,
          'region',
          'North',
          'Region Filter',
        );

        final filters = await facade.getDashboardFilters(dashboard.dashboardId);
        expect(filters.isNotEmpty, true);
      });

      test('Chart creation', () async {
        final points = [
          DataPoint(label: 'Jan', value: 100),
          DataPoint(label: 'Feb', value: 150),
          DataPoint(label: 'Mar', value: 120),
        ];
        final chart = await facade.createChart('chart1', points, 'Month', 'Sales');
        expect(chart.dataPointCount, 3);
      });

      test('Snapshot capture', () async {
        final dashboard = await facade.createDashboard('Test', 'Test');
        await facade.captureSnapshot(
          dashboard.dashboardId,
          {'version': 1, 'theme': 'light'},
          'Initial snapshot',
        );

        final snapshots = await facade.getDashboardSnapshots(dashboard.dashboardId);
        expect(snapshots.isNotEmpty, true);
      });

      test('Visualization library', () async {
        final library = await facade.createLibrary('My Library', ['w1', 'w2']);
        expect(library.widgetCount, 2);

        final libraries = await facade.listLibraries();
        expect(libraries.isNotEmpty, true);
      });

      test('Auto refresh setup', () async {
        final dashboard = await facade.createDashboard('Live Dashboard', 'Real-time data');
        await facade.enableAutoRefresh(dashboard.dashboardId, RefreshInterval.fiveMinutes);

        final refreshes = await facade.getRefreshSchedules();
        expect(refreshes.isNotEmpty, true);
      });

      test('Permission sharing', () async {
        final dashboard = await facade.createDashboard('Shared Dashboard', 'For team');
        await facade.shareWithUser(dashboard.dashboardId, 'user@example.com', 'view');
        
        // Verify by checking repository
        final perms = await repository.getPermissionsByDashboard(dashboard.dashboardId);
        expect(perms.isNotEmpty, true);
      });

      test('Multiple dashboards', () async {
        await facade.createDashboard('Dashboard 1', 'First');
        await facade.createDashboard('Dashboard 2', 'Second');
        await facade.createDashboard('Dashboard 3', 'Third');

        final all = await facade.listDashboards();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('Complex dashboard setup', () async {
        final dashboard = await facade.createDashboard('Complex Dashboard', 'Full setup');
        
        // Add multiple widgets
        for (int i = 0; i < 5; i++) {
          final widget = DashboardWidget(
            widgetId: 'w$i',
            dashboardId: dashboard.dashboardId,
            title: 'Widget $i',
            description: 'Description $i',
            chartType: ChartType.barChart,
            size: WidgetSize.medium,
            config: {},
            createdAt: DateTime.now(),
          );
          await facade.addWidgetToDashboard(dashboard.dashboardId, widget);
        }

        final widgets = await facade.getDashboardWidgets(dashboard.dashboardId);
        expect(widgets.length, 5);
      });
    });

    group('Edge Cases & Error Handling', () {
      test('Handle missing dashboard', () async {
        final result = await facade.getDashboard('nonexistent');
        expect(result, isNull);
      });

      test('Empty dashboard', () async {
        final dashboard = await facade.createDashboard('Empty', 'No widgets');
        expect(dashboard.isEmpty, true);
      });

      test('Chart data without points', () async {
        final data = ChartData(
          chartId: 'empty_chart',
          points: [],
          xAxisLabel: 'X',
          yAxisLabel: 'Y',
          generatedAt: DateTime.now(),
        );
        expect(data.hasData, false);
        expect(data.minValue, isNull);
      });

      test('Filter with null value', () async {
        final filter = DashboardFilter(
          filterId: 'f1',
          dashboardId: 'dash1',
          filterName: 'Test',
          field: 'test',
          value: null,
          createdAt: DateTime.now(),
        );
        expect(filter.isActive, false);
      });

      test('Permission access levels', () async {
        final viewPerm = DashboardPermission(
          permissionId: 'p1',
          dashboardId: 'd1',
          userId: 'u1',
          accessLevel: 'view',
          grantedAt: DateTime.now(),
        );
        expect(viewPerm.canView, true);
        expect(viewPerm.canEdit, false);

        final editPerm = DashboardPermission(
          permissionId: 'p2',
          dashboardId: 'd1',
          userId: 'u2',
          accessLevel: 'edit',
          grantedAt: DateTime.now(),
        );
        expect(editPerm.canEdit, true);
        expect(editPerm.isAdmin, false);
      });

      test('Large widget configuration', () async {
        final largeConfig = <String, dynamic>{};
        for (int i = 0; i < 100; i++) {
          largeConfig['option_$i'] = 'value_$i';
        }

        final widget = DashboardWidget(
          widgetId: 'large_widget',
          dashboardId: 'dash1',
          title: 'Large Config Widget',
          description: 'Test',
          chartType: ChartType.barChart,
          size: WidgetSize.large,
          config: largeConfig,
          createdAt: DateTime.now(),
        );
        expect(widget.configSize, 100);
      });

      test('Concurrent dashboard operations', () async {
        final futures = List.generate(
          5,
          (i) => facade.createDashboard('Dashboard $i', 'Description $i'),
        );
        final results = await Future.wait(futures);
        expect(results.length, 5);
      });

      test('Special characters in dashboard names', () async {
        final dashboard = await facade.createDashboard(
          'Dashboard @#$% Special',
          'Test with 中文 characters',
        );
        expect(dashboard.name, contains('@'));
      });

      test('Refresh interval calculations', () async {
        final realtime = DashboardRefresh(
          refreshId: 'r1',
          dashboardId: 'd1',
          interval: RefreshInterval.realtime,
          lastRefreshAt: DateTime.now(),
        );
        expect(realtime.secondsSinceRefresh, greaterThanOrEqualTo(0));
      });
    });
  });
}
