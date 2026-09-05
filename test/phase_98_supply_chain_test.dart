import 'package:flutter_test/flutter_test.dart';
import '../lib/models/supply_chain_models.dart';
import '../lib/services/supply_chain_service.dart';

void main() {
  group('Supply Chain Models & Services Tests', () {
    late InMemorySupplyChainRepository repository;
    late SupplyChainManager manager;
    late SupplyChainFacade facade;

    setUp(() {
      repository = InMemorySupplyChainRepository();
      manager = SupplyChainManager(repository);
      facade = SupplyChainFacade(repository);
    });

    // ========================================================================
    // Enum Tests
    // ========================================================================

    group('Enum Tests', () {
      test('SupplierStatus enum has all values', () {
        expect(SupplierStatus.values.length, equals(6));
        expect(SupplierStatus.active.displayName, contains('Active'));
      });

      test('InventoryStatus enum has all values', () {
        expect(InventoryStatus.values.length, equals(6));
        expect(InventoryStatus.inStock.displayName, contains('In Stock'));
      });

      test('ProcurementStatus enum has all values', () {
        expect(ProcurementStatus.values.length, equals(7));
      });

      test('ShipmentStatus enum has all values', () {
        expect(ShipmentStatus.values.length, equals(6));
      });

      test('WarehouseType enum has all values', () {
        expect(WarehouseType.values.length, equals(6));
      });

      test('RouteOptimization enum has all values', () {
        expect(RouteOptimization.values.length, equals(6));
      });

      test('DefectCategory enum has all values', () {
        expect(DefectCategory.values.length, equals(6));
      });
    });

    // ========================================================================
    // Model Tests
    // ========================================================================

    group('Supplier Model Tests', () {
      test('Supplier with active status and high rating is reliable', () {
        final supplier = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Test Supplier',
          contactPerson: 'John Doe',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 Supplier St',
          rating: 4.8,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 98,
          qualityScore: 4.7,
          createdDate: DateTime.now().subtract(Duration(days: 30)),
          isPreferred: true,
        );

        expect(supplier.isActive, true);
        expect(supplier.isReliable, true);
        expect(supplier.ageInDays, 30);
      });

      test('Supplier copyWith creates new instance', () {
        final original = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Original',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.0,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 90,
          qualityScore: 4.0,
          createdDate: DateTime.now(),
          isPreferred: false,
        );

        final updated = original.copyWith(rating: 4.5, isPreferred: true);
        expect(updated.rating, equals(4.5));
        expect(updated.isPreferred, true);
        expect(original.rating, equals(4.0));
      });
    });

    group('InventoryItem Model Tests', () {
      test('Inventory item calculates low stock status', () {
        final item = InventoryItem(
          itemId: 'inv_001',
          sku: 'SKU001',
          productName: 'Product A',
          quantity: 5,
          minimumLevel: 10,
          maximumLevel: 100,
          unitCost: 50,
          status: InventoryStatus.lowStock,
          warehouseId: 'wh_001',
          lastUpdated: DateTime.now(),
        );

        expect(item.isLowStock, true);
        expect(item.isOverStock, false);
        expect(item.totalValue, equals(250));
      });

      test('Inventory item calculates total value correctly', () {
        final item = InventoryItem(
          itemId: 'inv_002',
          sku: 'SKU002',
          productName: 'Product B',
          quantity: 100,
          minimumLevel: 10,
          maximumLevel: 200,
          unitCost: 25.5,
          status: InventoryStatus.inStock,
          warehouseId: 'wh_001',
          lastUpdated: DateTime.now().subtract(Duration(days: 5)),
        );

        expect(item.totalValue, equals(2550));
        expect(item.daysAgo, equals(5));
      });
    });

    group('ProcurementOrder Model Tests', () {
      test('Procurement order tracks pending status', () {
        final order = ProcurementOrder(
          orderId: 'po_001',
          supplierId: 'sup_001',
          orderAmount: 5000,
          status: ProcurementStatus.submitted,
          orderDate: DateTime.now().subtract(Duration(days: 2)),
          dueDate: DateTime.now().add(Duration(days: 10)),
          quantity: 100,
          productName: 'Widget A',
          isUrgent: true,
        );

        expect(order.isPending, true);
        expect(order.isApproved, false);
        expect(order.ageInDays, equals(2));
      });
    });

    group('Shipment Model Tests', () {
      test('Shipment calculates delivery tracking metrics', () {
        final shipment = Shipment(
          shipmentId: 'ship_001',
          orderId: 'po_001',
          origin: 'Warehouse A',
          destination: 'Customer Location',
          status: ShipmentStatus.inTransit,
          shipDate: DateTime.now().subtract(Duration(days: 3)),
          expectedDelivery: DateTime.now().add(Duration(days: 2)),
          actualDelivery: null,
          weight: 50.5,
          trackingNumber: 'TRACK123456',
        );

        expect(shipment.isDelivered, false);
        expect(shipment.daysInTransit, equals(3));
        expect(shipment.daysUntilDelivery, equals(2));
      });
    });

    group('Warehouse Model Tests', () {
      test('Warehouse calculates utilization rate', () {
        final warehouse = Warehouse(
          warehouseId: 'wh_001',
          warehouseName: 'Main Warehouse',
          location: 'Downtown',
          type: WarehouseType.distribution,
          capacitySquareFeet: 10000,
          usedSquareFeet: 8500,
          staffCount: 50,
          createdDate: DateTime.now().subtract(Duration(days: 365)),
        );

        expect(warehouse.isActive, true);
        expect(warehouse.utilizationRate, 85);
        expect(warehouse.isNearCapacity, false);
        expect(warehouse.ageInDays, equals(365));
      });

      test('Warehouse at near capacity triggers alert', () {
        final warehouse = Warehouse(
          warehouseId: 'wh_002',
          warehouseName: 'Secondary Warehouse',
          location: 'Suburbs',
          type: WarehouseType.storage,
          capacitySquareFeet: 5000,
          usedSquareFeet: 4600,
          staffCount: 25,
          createdDate: DateTime.now(),
        );

        expect(warehouse.utilizationRate, 92);
        expect(warehouse.isNearCapacity, true);
      });
    });

    group('DeliveryRoute Model Tests', () {
      test('Delivery route calculates metrics', () {
        final route = DeliveryRoute(
          routeId: 'route_001',
          vehicleId: 'veh_001',
          driverId: 'driver_001',
          stopLocations: ['Stop A', 'Stop B', 'Stop C'],
          optimization: RouteOptimization.costEffective,
          totalDistance: 150,
          startTime: DateTime.now().subtract(Duration(hours: 8)),
          endTime: null,
          fuelCost: 45.0,
        );

        expect(route.isActive, true);
        expect(route.stopCount, equals(3));
        expect(route.durationHours, equals(8));
        expect(route.costPerMile, closeTo(0.3, 0.01));
      });
    });

    group('QualityInspection Model Tests', () {
      test('Quality inspection calculates defect rate', () {
        final inspection = QualityInspection(
          inspectionId: 'insp_001',
          shipmentId: 'ship_001',
          itemsInspected: 100,
          defectsFound: 2,
          primaryDefect: DefectCategory.packaging,
          isPassed: true,
          inspectionDate: DateTime.now(),
          inspectorName: 'Inspector A',
          notes: 'Minor packaging issues',
        );

        expect(inspection.defectRate, equals(2));
        expect(inspection.isRecent, true);
        expect(inspection.ageInDays, equals(0));
      });
    });

    group('SupplierContract Model Tests', () {
      test('Supplier contract tracks expiration', () {
        final contract = SupplierContract(
          contractId: 'cont_001',
          supplierId: 'sup_001',
          startDate: DateTime.now().subtract(Duration(days: 180)),
          endDate: DateTime.now().add(Duration(days: 90)),
          annualValue: 100000,
          minOrderQuantity: 1000,
          leadTimeDays: 14,
          hasAutoRenewal: true,
          terms: 'Net 30',
        );

        expect(contract.isActive, true);
        expect(contract.isExpiring, false);
        expect(contract.daysRemaining, equals(90));
      });

      test('Contract expiration warning', () {
        final contract = SupplierContract(
          contractId: 'cont_002',
          supplierId: 'sup_002',
          startDate: DateTime.now().subtract(Duration(days: 350)),
          endDate: DateTime.now().subtract(Duration(days: 5)),
          annualValue: 50000,
          minOrderQuantity: 500,
          leadTimeDays: 7,
          hasAutoRenewal: false,
          terms: 'Net 15',
        );

        expect(contract.isActive, false);
        expect(contract.isExpiring, true);
      });
    });

    group('LogisticsMetrics Model Tests', () {
      test('Logistics metrics indicate health', () {
        final metrics = LogisticsMetrics(
          metricsId: 'met_001',
          reportDate: DateTime.now(),
          onTimeDeliveryRate: 96,
          inventoryTurnover: 12,
          warehouseEfficiency: 85,
          supplierPerformanceScore: 4.6,
          totalShipmentsProcessed: 500,
          avgDeliveryTime: 2.5,
          costPerUnit: 15.5,
        );

        expect(metrics.isHealthy, true);
        expect(metrics.isRecent, true);
      });
    });

    // ========================================================================
    // Repository Tests
    // ========================================================================

    group('Supplier Repository Tests', () {
      test('Create and retrieve supplier', () async {
        final supplier = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Test Supplier',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.5,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 95,
          qualityScore: 4.5,
          createdDate: DateTime.now(),
          isPreferred: true,
        );

        await repository.createSupplier(supplier);
        final retrieved = await repository.getSupplier('sup_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.supplierName, equals('Test Supplier'));
      });

      test('Get active suppliers only', () async {
        final active = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Active Supplier',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.5,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 95,
          qualityScore: 4.5,
          createdDate: DateTime.now(),
          isPreferred: true,
        );

        final inactive = Supplier(
          supplierId: 'sup_002',
          supplierName: 'Inactive Supplier',
          contactPerson: 'Jane',
          email: 'jane@supplier.com',
          phone: '+0987654321',
          address: '456 St',
          rating: 3.0,
          status: SupplierStatus.inactive,
          onTimeDeliveryPercent: 70,
          qualityScore: 3.0,
          createdDate: DateTime.now(),
          isPreferred: false,
        );

        await repository.createSupplier(active);
        await repository.createSupplier(inactive);
        final activeList = await repository.getActiveSuppliers();

        expect(activeList.length, equals(1));
        expect(activeList.first.supplierId, equals('sup_001'));
      });

      test('Get reliable suppliers', () async {
        final reliable = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Reliable',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.8,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 98,
          qualityScore: 4.8,
          createdDate: DateTime.now(),
          isPreferred: true,
        );

        await repository.createSupplier(reliable);
        final reliableList = await repository.getReliableSuppliers();

        expect(reliableList.length, equals(1));
        expect(reliableList.first.isReliable, true);
      });

      test('Get average supplier rating', () async {
        final sup1 = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Supplier 1',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 5.0,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 100,
          qualityScore: 5.0,
          createdDate: DateTime.now(),
          isPreferred: true,
        );

        final sup2 = Supplier(
          supplierId: 'sup_002',
          supplierName: 'Supplier 2',
          contactPerson: 'Jane',
          email: 'jane@supplier.com',
          phone: '+0987654321',
          address: '456 St',
          rating: 4.0,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 90,
          qualityScore: 4.0,
          createdDate: DateTime.now(),
          isPreferred: false,
        );

        await repository.createSupplier(sup1);
        await repository.createSupplier(sup2);
        final avgRating = await repository.getAverageSupplierRating();

        expect(avgRating, equals(4.5));
      });

      test('Update supplier', () async {
        final supplier = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Original Name',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.0,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 90,
          qualityScore: 4.0,
          createdDate: DateTime.now(),
          isPreferred: false,
        );

        await repository.createSupplier(supplier);
        final updated = supplier.copyWith(supplierName: 'Updated Name', rating: 4.5);
        await repository.updateSupplier(updated);
        final retrieved = await repository.getSupplier('sup_001');

        expect(retrieved!.supplierName, equals('Updated Name'));
        expect(retrieved.rating, equals(4.5));
      });

      test('Delete supplier', () async {
        final supplier = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Test',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.0,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 90,
          qualityScore: 4.0,
          createdDate: DateTime.now(),
          isPreferred: false,
        );

        await repository.createSupplier(supplier);
        await repository.deleteSupplier('sup_001');
        final retrieved = await repository.getSupplier('sup_001');

        expect(retrieved, isNull);
      });

      test('Get supplier count', () async {
        final supplier1 = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Supplier 1',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.0,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 90,
          qualityScore: 4.0,
          createdDate: DateTime.now(),
          isPreferred: false,
        );

        final supplier2 = Supplier(
          supplierId: 'sup_002',
          supplierName: 'Supplier 2',
          contactPerson: 'Jane',
          email: 'jane@supplier.com',
          phone: '+0987654321',
          address: '456 St',
          rating: 4.5,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 95,
          qualityScore: 4.5,
          createdDate: DateTime.now(),
          isPreferred: true,
        );

        await repository.createSupplier(supplier1);
        await repository.createSupplier(supplier2);
        final count = await repository.getSupplierCount();

        expect(count, equals(2));
      });
    });

    group('Inventory Repository Tests', () {
      test('Create and retrieve inventory item', () async {
        final item = InventoryItem(
          itemId: 'inv_001',
          sku: 'SKU001',
          productName: 'Product A',
          quantity: 50,
          minimumLevel: 10,
          maximumLevel: 200,
          unitCost: 25.0,
          status: InventoryStatus.inStock,
          warehouseId: 'wh_001',
          lastUpdated: DateTime.now(),
        );

        await repository.createInventoryItem(item);
        final retrieved = await repository.getInventoryItem('inv_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.productName, equals('Product A'));
      });

      test('Get low stock items', () async {
        final lowStock = InventoryItem(
          itemId: 'inv_001',
          sku: 'SKU001',
          productName: 'Low Stock Item',
          quantity: 5,
          minimumLevel: 10,
          maximumLevel: 100,
          unitCost: 20.0,
          status: InventoryStatus.lowStock,
          warehouseId: 'wh_001',
          lastUpdated: DateTime.now(),
        );

        final normalStock = InventoryItem(
          itemId: 'inv_002',
          sku: 'SKU002',
          productName: 'Normal Stock Item',
          quantity: 50,
          minimumLevel: 10,
          maximumLevel: 100,
          unitCost: 20.0,
          status: InventoryStatus.inStock,
          warehouseId: 'wh_001',
          lastUpdated: DateTime.now(),
        );

        await repository.createInventoryItem(lowStock);
        await repository.createInventoryItem(normalStock);
        final lowStockList = await repository.getLowStockItems();

        expect(lowStockList.length, equals(1));
        expect(lowStockList.first.isLowStock, true);
      });

      test('Get total inventory value', () async {
        final item1 = InventoryItem(
          itemId: 'inv_001',
          sku: 'SKU001',
          productName: 'Item 1',
          quantity: 100,
          minimumLevel: 10,
          maximumLevel: 200,
          unitCost: 50.0,
          status: InventoryStatus.inStock,
          warehouseId: 'wh_001',
          lastUpdated: DateTime.now(),
        );

        final item2 = InventoryItem(
          itemId: 'inv_002',
          sku: 'SKU002',
          productName: 'Item 2',
          quantity: 50,
          minimumLevel: 10,
          maximumLevel: 100,
          unitCost: 30.0,
          status: InventoryStatus.inStock,
          warehouseId: 'wh_001',
          lastUpdated: DateTime.now(),
        );

        await repository.createInventoryItem(item1);
        await repository.createInventoryItem(item2);
        final totalValue = await repository.getTotalInventoryValue();

        expect(totalValue, equals(6500));
      });
    });

    group('Procurement Repository Tests', () {
      test('Create and retrieve procurement order', () async {
        final order = ProcurementOrder(
          orderId: 'po_001',
          supplierId: 'sup_001',
          orderAmount: 10000,
          status: ProcurementStatus.draft,
          orderDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          quantity: 500,
          productName: 'Widget',
          isUrgent: false,
        );

        await repository.createProcurementOrder(order);
        final retrieved = await repository.getProcurementOrder('po_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.orderAmount, equals(10000));
      });

      test('Get pending procurement orders', () async {
        final pending = ProcurementOrder(
          orderId: 'po_001',
          supplierId: 'sup_001',
          orderAmount: 5000,
          status: ProcurementStatus.submitted,
          orderDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 10)),
          quantity: 100,
          productName: 'Widget',
          isUrgent: true,
        );

        final approved = ProcurementOrder(
          orderId: 'po_002',
          supplierId: 'sup_001',
          orderAmount: 3000,
          status: ProcurementStatus.approved,
          orderDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 15)),
          quantity: 50,
          productName: 'Gadget',
          isUrgent: false,
        );

        await repository.createProcurementOrder(pending);
        await repository.createProcurementOrder(approved);
        final pendingList = await repository.getPendingOrders();

        expect(pendingList.length, equals(1));
      });

      test('Get urgent orders', () async {
        final urgent = ProcurementOrder(
          orderId: 'po_001',
          supplierId: 'sup_001',
          orderAmount: 7000,
          status: ProcurementStatus.submitted,
          orderDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 2)),
          quantity: 200,
          productName: 'Emergency Part',
          isUrgent: true,
        );

        await repository.createProcurementOrder(urgent);
        final urgentList = await repository.getUrgentOrders();

        expect(urgentList.length, equals(1));
        expect(urgentList.first.isUrgent, true);
      });

      test('Get total procurement amount', () async {
        final order1 = ProcurementOrder(
          orderId: 'po_001',
          supplierId: 'sup_001',
          orderAmount: 5000,
          status: ProcurementStatus.approved,
          orderDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 10)),
          quantity: 100,
          productName: 'Widget',
          isUrgent: false,
        );

        final order2 = ProcurementOrder(
          orderId: 'po_002',
          supplierId: 'sup_001',
          orderAmount: 3000,
          status: ProcurementStatus.approved,
          orderDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 15)),
          quantity: 50,
          productName: 'Gadget',
          isUrgent: false,
        );

        await repository.createProcurementOrder(order1);
        await repository.createProcurementOrder(order2);
        final totalAmount = await repository.getTotalProcurementAmount();

        expect(totalAmount, equals(8000));
      });
    });

    group('Shipment Repository Tests', () {
      test('Create and retrieve shipment', () async {
        final shipment = Shipment(
          shipmentId: 'ship_001',
          orderId: 'po_001',
          origin: 'Warehouse A',
          destination: 'Customer B',
          status: ShipmentStatus.inTransit,
          shipDate: DateTime.now(),
          expectedDelivery: DateTime.now().add(Duration(days: 5)),
          actualDelivery: null,
          weight: 100.0,
          trackingNumber: 'TRACK123',
        );

        await repository.createShipment(shipment);
        final retrieved = await repository.getShipment('ship_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.trackingNumber, equals('TRACK123'));
      });

      test('Get in-transit shipments', () async {
        final inTransit = Shipment(
          shipmentId: 'ship_001',
          orderId: 'po_001',
          origin: 'Warehouse A',
          destination: 'Customer B',
          status: ShipmentStatus.inTransit,
          shipDate: DateTime.now(),
          expectedDelivery: DateTime.now().add(Duration(days: 3)),
          actualDelivery: null,
          weight: 50.0,
          trackingNumber: 'TRACK001',
        );

        final delivered = Shipment(
          shipmentId: 'ship_002',
          orderId: 'po_002',
          origin: 'Warehouse A',
          destination: 'Customer C',
          status: ShipmentStatus.delivered,
          shipDate: DateTime.now().subtract(Duration(days: 5)),
          expectedDelivery: DateTime.now(),
          actualDelivery: DateTime.now(),
          weight: 30.0,
          trackingNumber: 'TRACK002',
        );

        await repository.createShipment(inTransit);
        await repository.createShipment(delivered);
        final inTransitList = await repository.getInTransitShipments();

        expect(inTransitList.length, equals(1));
      });

      test('Get delayed shipments', () async {
        final delayed = Shipment(
          shipmentId: 'ship_001',
          orderId: 'po_001',
          origin: 'Warehouse A',
          destination: 'Customer B',
          status: ShipmentStatus.delayed,
          shipDate: DateTime.now().subtract(Duration(days: 10)),
          expectedDelivery: DateTime.now().subtract(Duration(days: 2)),
          actualDelivery: null,
          weight: 75.0,
          trackingNumber: 'TRACK123',
        );

        await repository.createShipment(delayed);
        final delayedList = await repository.getDelayedShipments();

        expect(delayedList.length, equals(1));
        expect(delayedList.first.isDelayed, true);
      });
    });

    group('Warehouse Repository Tests', () {
      test('Create and retrieve warehouse', () async {
        final warehouse = Warehouse(
          warehouseId: 'wh_001',
          warehouseName: 'Main Warehouse',
          location: 'Downtown',
          type: WarehouseType.distribution,
          capacitySquareFeet: 10000,
          usedSquareFeet: 7500,
          staffCount: 50,
          createdDate: DateTime.now(),
        );

        await repository.createWarehouse(warehouse);
        final retrieved = await repository.getWarehouse('wh_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.warehouseName, equals('Main Warehouse'));
      });

      test('Get warehouse utilization', () async {
        final warehouse1 = Warehouse(
          warehouseId: 'wh_001',
          warehouseName: 'Warehouse 1',
          location: 'Location 1',
          type: WarehouseType.distribution,
          capacitySquareFeet: 10000,
          usedSquareFeet: 8000,
          staffCount: 40,
          createdDate: DateTime.now(),
        );

        final warehouse2 = Warehouse(
          warehouseId: 'wh_002',
          warehouseName: 'Warehouse 2',
          location: 'Location 2',
          type: WarehouseType.storage,
          capacitySquareFeet: 5000,
          usedSquareFeet: 4000,
          staffCount: 20,
          createdDate: DateTime.now(),
        );

        await repository.createWarehouse(warehouse1);
        await repository.createWarehouse(warehouse2);
        final utilization = await repository.getWarehouseUtilization();

        expect(utilization.length, equals(2));
        expect(utilization['Warehouse 1'], equals(80));
        expect(utilization['Warehouse 2'], equals(80));
      });

      test('Get warehouses near capacity', () async {
        final nearCapacity = Warehouse(
          warehouseId: 'wh_001',
          warehouseName: 'Full Warehouse',
          location: 'Location 1',
          type: WarehouseType.distribution,
          capacitySquareFeet: 1000,
          usedSquareFeet: 950,
          staffCount: 30,
          createdDate: DateTime.now(),
        );

        await repository.createWarehouse(nearCapacity);
        final nearCapacityList = await repository.getNearCapacityWarehouses();

        expect(nearCapacityList.length, equals(1));
        expect(nearCapacityList.first.isNearCapacity, true);
      });
    });

    group('QualityInspection Repository Tests', () {
      test('Create and retrieve inspection', () async {
        final inspection = QualityInspection(
          inspectionId: 'insp_001',
          shipmentId: 'ship_001',
          itemsInspected: 100,
          defectsFound: 1,
          primaryDefect: DefectCategory.packaging,
          isPassed: true,
          inspectionDate: DateTime.now(),
          inspectorName: 'Inspector A',
          notes: 'One package corner slightly bent',
        );

        await repository.createQualityInspection(inspection);
        final retrieved = await repository.getQualityInspection('insp_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.itemsInspected, equals(100));
      });

      test('Get failed inspections', () async {
        final failed = QualityInspection(
          inspectionId: 'insp_001',
          shipmentId: 'ship_001',
          itemsInspected: 50,
          defectsFound: 5,
          primaryDefect: DefectCategory.quality,
          isPassed: false,
          inspectionDate: DateTime.now(),
          inspectorName: 'Inspector A',
          notes: 'Multiple quality issues found',
        );

        final passed = QualityInspection(
          inspectionId: 'insp_002',
          shipmentId: 'ship_002',
          itemsInspected: 100,
          defectsFound: 0,
          primaryDefect: null,
          isPassed: true,
          inspectionDate: DateTime.now(),
          inspectorName: 'Inspector B',
          notes: 'All items passed inspection',
        );

        await repository.createQualityInspection(failed);
        await repository.createQualityInspection(passed);
        final failedList = await repository.getFailedInspections();

        expect(failedList.length, equals(1));
        expect(failedList.first.isPassed, false);
      });

      test('Calculate average defect rate', () async {
        final insp1 = QualityInspection(
          inspectionId: 'insp_001',
          shipmentId: 'ship_001',
          itemsInspected: 100,
          defectsFound: 2,
          primaryDefect: DefectCategory.packaging,
          isPassed: true,
          inspectionDate: DateTime.now(),
          inspectorName: 'Inspector A',
          notes: 'Minor defects',
        );

        final insp2 = QualityInspection(
          inspectionId: 'insp_002',
          shipmentId: 'ship_002',
          itemsInspected: 100,
          defectsFound: 4,
          primaryDefect: DefectCategory.quality,
          isPassed: true,
          inspectionDate: DateTime.now(),
          inspectorName: 'Inspector B',
          notes: 'Moderate defects',
        );

        await repository.createQualityInspection(insp1);
        await repository.createQualityInspection(insp2);
        final avgDefectRate = await repository.getAverageDefectRate();

        expect(avgDefectRate, equals(3));
      });
    });

    group('SupplierContract Repository Tests', () {
      test('Create and retrieve contract', () async {
        final contract = SupplierContract(
          contractId: 'cont_001',
          supplierId: 'sup_001',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 365)),
          annualValue: 100000,
          minOrderQuantity: 1000,
          leadTimeDays: 14,
          hasAutoRenewal: true,
          terms: 'Net 30',
        );

        await repository.createSupplierContract(contract);
        final retrieved = await repository.getSupplierContract('cont_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.annualValue, equals(100000));
      });

      test('Get active contracts', () async {
        final active = SupplierContract(
          contractId: 'cont_001',
          supplierId: 'sup_001',
          startDate: DateTime.now().subtract(Duration(days: 100)),
          endDate: DateTime.now().add(Duration(days: 200)),
          annualValue: 100000,
          minOrderQuantity: 1000,
          leadTimeDays: 14,
          hasAutoRenewal: true,
          terms: 'Net 30',
        );

        final expired = SupplierContract(
          contractId: 'cont_002',
          supplierId: 'sup_002',
          startDate: DateTime.now().subtract(Duration(days: 500)),
          endDate: DateTime.now().subtract(Duration(days: 100)),
          annualValue: 50000,
          minOrderQuantity: 500,
          leadTimeDays: 7,
          hasAutoRenewal: false,
          terms: 'Net 15',
        );

        await repository.createSupplierContract(active);
        await repository.createSupplierContract(expired);
        final activeList = await repository.getActiveContracts();

        expect(activeList.length, equals(1));
        expect(activeList.first.isActive, true);
      });

      test('Get expiring contracts', () async {
        final expiring = SupplierContract(
          contractId: 'cont_001',
          supplierId: 'sup_001',
          startDate: DateTime.now().subtract(Duration(days: 300)),
          endDate: DateTime.now().subtract(Duration(days: 10)),
          annualValue: 75000,
          minOrderQuantity: 800,
          leadTimeDays: 10,
          hasAutoRenewal: false,
          terms: 'Net 20',
        );

        await repository.createSupplierContract(expiring);
        final expiringList = await repository.getExpiringContracts();

        expect(expiringList.length, equals(1));
        expect(expiringList.first.isExpiring, true);
      });
    });

    group('LogisticsMetrics Repository Tests', () {
      test('Create and retrieve metrics', () async {
        final metrics = LogisticsMetrics(
          metricsId: 'met_001',
          reportDate: DateTime.now(),
          onTimeDeliveryRate: 96.5,
          inventoryTurnover: 12,
          warehouseEfficiency: 85,
          supplierPerformanceScore: 4.6,
          totalShipmentsProcessed: 500,
          avgDeliveryTime: 2.5,
          costPerUnit: 15.5,
        );

        await repository.createLogisticsMetrics(metrics);
        final retrieved = await repository.getLogisticsMetrics('met_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.onTimeDeliveryRate, equals(96.5));
      });

      test('Get latest metrics', () async {
        final oldMetrics = LogisticsMetrics(
          metricsId: 'met_001',
          reportDate: DateTime.now().subtract(Duration(days: 7)),
          onTimeDeliveryRate: 94,
          inventoryTurnover: 11,
          warehouseEfficiency: 82,
          supplierPerformanceScore: 4.4,
          totalShipmentsProcessed: 450,
          avgDeliveryTime: 2.7,
          costPerUnit: 16.0,
        );

        final newMetrics = LogisticsMetrics(
          metricsId: 'met_002',
          reportDate: DateTime.now(),
          onTimeDeliveryRate: 96.5,
          inventoryTurnover: 12,
          warehouseEfficiency: 85,
          supplierPerformanceScore: 4.6,
          totalShipmentsProcessed: 500,
          avgDeliveryTime: 2.5,
          costPerUnit: 15.5,
        );

        await repository.createLogisticsMetrics(oldMetrics);
        await repository.createLogisticsMetrics(newMetrics);
        final latest = await repository.getLatestMetrics();

        expect(latest, isNotNull);
        expect(latest!.metricsId, equals('met_002'));
      });
    });

    group('DeliveryRoute Repository Tests', () {
      test('Create and retrieve route', () async {
        final route = DeliveryRoute(
          routeId: 'route_001',
          vehicleId: 'veh_001',
          driverId: 'driver_001',
          stopLocations: ['Stop A', 'Stop B'],
          optimization: RouteOptimization.costEffective,
          totalDistance: 100,
          startTime: DateTime.now(),
          endTime: null,
          fuelCost: 40,
        );

        await repository.createDeliveryRoute(route);
        final retrieved = await repository.getDeliveryRoute('route_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.stopCount, equals(2));
      });

      test('Get active routes', () async {
        final active = DeliveryRoute(
          routeId: 'route_001',
          vehicleId: 'veh_001',
          driverId: 'driver_001',
          stopLocations: ['Stop A'],
          optimization: RouteOptimization.fastest,
          totalDistance: 50,
          startTime: DateTime.now(),
          endTime: null,
          fuelCost: 25,
        );

        await repository.createDeliveryRoute(active);
        final activeList = await repository.getActiveRoutes();

        expect(activeList.length, equals(1));
        expect(activeList.first.isActive, true);
      });
    });

    // ========================================================================
    // Engine Tests
    // ========================================================================

    group('SupplierManagementEngine Tests', () {
      test('Get top suppliers by rating', () async {
        for (int i = 1; i <= 5; i++) {
          final supplier = Supplier(
            supplierId: 'sup_00$i',
            supplierName: 'Supplier $i',
            contactPerson: 'Contact $i',
            email: 'contact$i@supplier.com',
            phone: '+123456789$i',
            address: 'Address $i',
            rating: 3.0 + i,
            status: SupplierStatus.active,
            onTimeDeliveryPercent: 80 + (i * 3),
            qualityScore: 3.5 + i,
            createdDate: DateTime.now(),
            isPreferred: i > 3,
          );
          await repository.createSupplier(supplier);
        }

        final topSuppliers = await manager.supplierEngine.getTopSuppliers(3);

        expect(topSuppliers.length, equals(3));
        expect(topSuppliers.first.rating, equals(8));
      });
    });

    group('InventoryManagementEngine Tests', () {
      test('Get inventory health score', () async {
        final item = InventoryItem(
          itemId: 'inv_001',
          sku: 'SKU001',
          productName: 'Product',
          quantity: 100,
          minimumLevel: 10,
          maximumLevel: 200,
          unitCost: 50,
          status: InventoryStatus.inStock,
          warehouseId: 'wh_001',
          lastUpdated: DateTime.now(),
        );

        await repository.createInventoryItem(item);
        final healthScore = await manager.inventoryEngine.getInventoryHealthScore();

        expect(healthScore, greaterThan(0));
      });
    });

    // ========================================================================
    // Manager Tests
    // ========================================================================

    group('SupplyChainManager Tests', () {
      test('Get supply chain dashboard', () async {
        final supplier = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Test Supplier',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.5,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 95,
          qualityScore: 4.5,
          createdDate: DateTime.now(),
          isPreferred: true,
        );

        await repository.createSupplier(supplier);
        final dashboard = await manager.getSupplyChainDashboard();

        expect(dashboard, contains('totalSuppliers'));
        expect(dashboard['totalSuppliers'], equals(1));
      });
    });

    // ========================================================================
    // Facade Tests
    // ========================================================================

    group('SupplyChainFacade Tests', () {
      test('Add supplier through facade', () async {
        final supplier = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Test Supplier',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.5,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 95,
          qualityScore: 4.5,
          createdDate: DateTime.now(),
          isPreferred: true,
        );

        await facade.addSupplier(supplier);
        final retrieved = await facade.getSupplier('sup_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.supplierName, equals('Test Supplier'));
      });

      test('Get supply chain dashboard through facade', () async {
        final supplier = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Test Supplier',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.5,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 95,
          qualityScore: 4.5,
          createdDate: DateTime.now(),
          isPreferred: true,
        );

        await facade.addSupplier(supplier);
        final dashboard = await facade.getSupplyChainDashboard();

        expect(dashboard, contains('totalSuppliers'));
      });
    });

    // ========================================================================
    // Integration Tests
    // ========================================================================

    group('Integration Tests', () {
      test('Complete procurement workflow', () async {
        // Create supplier
        final supplier = Supplier(
          supplierId: 'sup_001',
          supplierName: 'Test Supplier',
          contactPerson: 'John',
          email: 'john@supplier.com',
          phone: '+1234567890',
          address: '123 St',
          rating: 4.5,
          status: SupplierStatus.active,
          onTimeDeliveryPercent: 95,
          qualityScore: 4.5,
          createdDate: DateTime.now(),
          isPreferred: true,
        );
        await repository.createSupplier(supplier);

        // Create procurement order
        final order = ProcurementOrder(
          orderId: 'po_001',
          supplierId: 'sup_001',
          orderAmount: 10000,
          status: ProcurementStatus.draft,
          orderDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          quantity: 500,
          productName: 'Widget',
          isUrgent: false,
        );
        await repository.createProcurementOrder(order);

        // Update to approved
        final approved = order.copyWith(status: ProcurementStatus.approved);
        await repository.updateProcurementOrder(approved);

        // Create shipment
        final shipment = Shipment(
          shipmentId: 'ship_001',
          orderId: 'po_001',
          origin: 'Supplier Warehouse',
          destination: 'Our Warehouse',
          status: ShipmentStatus.inTransit,
          shipDate: DateTime.now(),
          expectedDelivery: DateTime.now().add(Duration(days: 5)),
          actualDelivery: null,
          weight: 500,
          trackingNumber: 'TRACK123456',
        );
        await repository.createShipment(shipment);

        // Quality inspection
        final inspection = QualityInspection(
          inspectionId: 'insp_001',
          shipmentId: 'ship_001',
          itemsInspected: 500,
          defectsFound: 1,
          primaryDefect: DefectCategory.packaging,
          isPassed: true,
          inspectionDate: DateTime.now().add(Duration(days: 5)),
          inspectorName: 'Inspector A',
          notes: 'One minor packaging issue',
        );
        await repository.createQualityInspection(inspection);

        // Verify workflow completed
        final finalOrder = await repository.getProcurementOrder('po_001');
        final finalShipment = await repository.getShipment('ship_001');
        final finalInspection = await repository.getQualityInspection('insp_001');

        expect(finalOrder!.isApproved, true);
        expect(finalShipment!.status, ShipmentStatus.inTransit);
        expect(finalInspection!.isPassed, true);
      });

      test('Complete inventory management workflow', () async {
        // Create inventory item
        final item = InventoryItem(
          itemId: 'inv_001',
          sku: 'SKU001',
          productName: 'Widget A',
          quantity: 100,
          minimumLevel: 20,
          maximumLevel: 200,
          unitCost: 50,
          status: InventoryStatus.inStock,
          warehouseId: 'wh_001',
          lastUpdated: DateTime.now(),
        );
        await repository.createInventoryItem(item);

        // Check low stock items (should be empty)
        var lowStockList = await repository.getLowStockItems();
        expect(lowStockList.length, equals(0));

        // Update to low stock
        final lowStocked = item.copyWith(
          quantity: 15,
          status: InventoryStatus.lowStock,
        );
        await repository.updateInventoryItem(lowStocked);

        // Check low stock items again
        lowStockList = await repository.getLowStockItems();
        expect(lowStockList.length, equals(1));
        expect(lowStockList.first.isLowStock, true);
      });

      test('Complete supplier evaluation workflow', () async {
        // Create multiple suppliers
        for (int i = 1; i <= 3; i++) {
          final supplier = Supplier(
            supplierId: 'sup_00$i',
            supplierName: 'Supplier $i',
            contactPerson: 'Contact $i',
            email: 'contact$i@supplier.com',
            phone: '+123456789$i',
            address: 'Address $i',
            rating: 3.5 + (i * 0.5),
            status: i == 1 ? SupplierStatus.active : SupplierStatus.probation,
            onTimeDeliveryPercent: 85 + (i * 5),
            qualityScore: 3.8 + (i * 0.3),
            createdDate: DateTime.now().subtract(Duration(days: i * 10)),
            isPreferred: i == 1,
          );
          await repository.createSupplier(supplier);
        }

        // Get active suppliers
        final activeSuppliers = await repository.getActiveSuppliers();
        expect(activeSuppliers.length, equals(1));

        // Get reliable suppliers
        final reliableSuppliers = await repository.getReliableSuppliers();
        expect(reliableSuppliers.isNotEmpty, true);

        // Get average rating
        final avgRating = await repository.getAverageSupplierRating();
        expect(avgRating, greaterThan(0));
      });
    });
  });
}
