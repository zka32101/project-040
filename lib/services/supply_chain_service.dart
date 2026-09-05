/// Advanced Supply Chain & Logistics Management Service
/// Provides comprehensive supplier management, procurement, inventory, and logistics

import 'package:flutter/foundation.dart';
import '../models/supply_chain_models.dart';

// ============================================================================
// Repository Interface
// ============================================================================

abstract class SupplyChainRepository {
  // Supplier Methods (12)
  Future<void> createSupplier(Supplier supplier);
  Future<Supplier?> getSupplier(String supplierId);
  Future<List<Supplier>> getAllSuppliers();
  Future<List<Supplier>> getActiveSuppliers();
  Future<List<Supplier>> getSuppliersByStatus(SupplierStatus status);
  Future<List<Supplier>> getPreferredSuppliers();
  Future<List<Supplier>> getReliableSuppliers();
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(String supplierId);
  Future<int> getSupplierCount();
  Future<double> getAverageSupplierRating();
  Future<List<Supplier>> getSuppliersByRating(double minRating);

  // Inventory Methods (12)
  Future<void> createInventoryItem(InventoryItem item);
  Future<InventoryItem?> getInventoryItem(String itemId);
  Future<List<InventoryItem>> getAllInventoryItems();
  Future<List<InventoryItem>> getInventoryByStatus(InventoryStatus status);
  Future<List<InventoryItem>> getLowStockItems();
  Future<List<InventoryItem>> getOverStockItems();
  Future<void> updateInventoryItem(InventoryItem item);
  Future<void> deleteInventoryItem(String itemId);
  Future<int> getTotalInventoryCount();
  Future<double> getTotalInventoryValue();
  Future<List<InventoryItem>> getInventoryByWarehouse(String warehouseId);
  Future<List<InventoryItem>> getInventoryBySku(String sku);

  // Procurement Methods (12)
  Future<void> createProcurementOrder(ProcurementOrder order);
  Future<ProcurementOrder?> getProcurementOrder(String orderId);
  Future<List<ProcurementOrder>> getAllProcurementOrders();
  Future<List<ProcurementOrder>> getProcurementByStatus(ProcurementStatus status);
  Future<List<ProcurementOrder>> getPendingOrders();
  Future<List<ProcurementOrder>> getApprovedOrders();
  Future<void> updateProcurementOrder(ProcurementOrder order);
  Future<void> deleteProcurementOrder(String orderId);
  Future<int> getProcurementOrderCount();
  Future<double> getTotalProcurementAmount();
  Future<List<ProcurementOrder>> getUrgentOrders();
  Future<List<ProcurementOrder>> getOrdersBySupplier(String supplierId);

  // Shipment Methods (12)
  Future<void> createShipment(Shipment shipment);
  Future<Shipment?> getShipment(String shipmentId);
  Future<List<Shipment>> getAllShipments();
  Future<List<Shipment>> getShipmentsByStatus(ShipmentStatus status);
  Future<List<Shipment>> getInTransitShipments();
  Future<List<Shipment>> getDelayedShipments();
  Future<void> updateShipment(Shipment shipment);
  Future<void> deleteShipment(String shipmentId);
  Future<int> getShipmentCount();
  Future<List<Shipment>> getShipmentsByTrackingNumber(String trackingNumber);
  Future<List<Shipment>> getRecentShipments(Duration duration);
  Future<double> getAverageDeliveryTime();

  // Warehouse Methods (10)
  Future<void> createWarehouse(Warehouse warehouse);
  Future<Warehouse?> getWarehouse(String warehouseId);
  Future<List<Warehouse>> getAllWarehouses();
  Future<List<Warehouse>> getWarehousesByType(WarehouseType type);
  Future<List<Warehouse>> getNearCapacityWarehouses();
  Future<void> updateWarehouse(Warehouse warehouse);
  Future<void> deleteWarehouse(String warehouseId);
  Future<int> getWarehouseCount();
  Future<double> getAverageUtilizationRate();
  Future<Map<String, double>> getWarehouseUtilization();

  // Delivery Route Methods (10)
  Future<void> createDeliveryRoute(DeliveryRoute route);
  Future<DeliveryRoute?> getDeliveryRoute(String routeId);
  Future<List<DeliveryRoute>> getAllDeliveryRoutes();
  Future<List<DeliveryRoute>> getActiveRoutes();
  Future<List<DeliveryRoute>> getRoutesByDriver(String driverId);
  Future<List<DeliveryRoute>> getRoutesByOptimization(RouteOptimization optimization);
  Future<void> updateDeliveryRoute(DeliveryRoute route);
  Future<void> deleteDeliveryRoute(String routeId);
  Future<int> getDeliveryRouteCount();
  Future<double> getAverageRouteCost();

  // Quality Inspection Methods (10)
  Future<void> createQualityInspection(QualityInspection inspection);
  Future<QualityInspection?> getQualityInspection(String inspectionId);
  Future<List<QualityInspection>> getAllInspections();
  Future<List<QualityInspection>> getInspectionsByShipment(String shipmentId);
  Future<List<QualityInspection>> getFailedInspections();
  Future<List<QualityInspection>> getRecentInspections(Duration duration);
  Future<void> updateQualityInspection(QualityInspection inspection);
  Future<void> deleteQualityInspection(String inspectionId);
  Future<int> getInspectionCount();
  Future<double> getAverageDefectRate();

  // Supplier Contract Methods (10)
  Future<void> createSupplierContract(SupplierContract contract);
  Future<SupplierContract?> getSupplierContract(String contractId);
  Future<List<SupplierContract>> getAllContracts();
  Future<List<SupplierContract>> getActiveContracts();
  Future<List<SupplierContract>> getExpiringContracts();
  Future<List<SupplierContract>> getContractsBySupplier(String supplierId);
  Future<void> updateSupplierContract(SupplierContract contract);
  Future<void> deleteSupplierContract(String contractId);
  Future<int> getContractCount();
  Future<double> getTotalContractValue();

  // Logistics Metrics Methods (8)
  Future<void> createLogisticsMetrics(LogisticsMetrics metrics);
  Future<LogisticsMetrics?> getLogisticsMetrics(String metricsId);
  Future<List<LogisticsMetrics>> getAllMetrics();
  Future<LogisticsMetrics?> getLatestMetrics();
  Future<void> updateLogisticsMetrics(LogisticsMetrics metrics);
  Future<void> deleteLogisticsMetrics(String metricsId);
  Future<int> getMetricsCount();
  Future<double> getAverageOnTimeDeliveryRate();
}

// ============================================================================
// In-Memory Repository Implementation
// ============================================================================

class InMemorySupplyChainRepository implements SupplyChainRepository {
  final Map<String, Supplier> _suppliers = {};
  final Map<String, InventoryItem> _inventory = {};
  final Map<String, ProcurementOrder> _procurementOrders = {};
  final Map<String, Shipment> _shipments = {};
  final Map<String, Warehouse> _warehouses = {};
  final Map<String, DeliveryRoute> _deliveryRoutes = {};
  final Map<String, QualityInspection> _inspections = {};
  final Map<String, SupplierContract> _contracts = {};
  final Map<String, LogisticsMetrics> _metrics = {};

  // Supplier Methods
  @override
  Future<void> createSupplier(Supplier supplier) async => _suppliers[supplier.supplierId] = supplier;

  @override
  Future<Supplier?> getSupplier(String supplierId) async => _suppliers[supplierId];

  @override
  Future<List<Supplier>> getAllSuppliers() async => _suppliers.values.toList();

  @override
  Future<List<Supplier>> getActiveSuppliers() async => 
    _suppliers.values.where((s) => s.isActive).toList();

  @override
  Future<List<Supplier>> getSuppliersByStatus(SupplierStatus status) async =>
    _suppliers.values.where((s) => s.status == status).toList();

  @override
  Future<List<Supplier>> getPreferredSuppliers() async =>
    _suppliers.values.where((s) => s.isPreferred).toList();

  @override
  Future<List<Supplier>> getReliableSuppliers() async =>
    _suppliers.values.where((s) => s.isReliable).toList();

  @override
  Future<void> updateSupplier(Supplier supplier) async => _suppliers[supplier.supplierId] = supplier;

  @override
  Future<void> deleteSupplier(String supplierId) async => _suppliers.remove(supplierId);

  @override
  Future<int> getSupplierCount() async => _suppliers.length;

  @override
  Future<double> getAverageSupplierRating() async {
    if (_suppliers.isEmpty) return 0;
    final total = _suppliers.values.fold<double>(0, (sum, s) => sum + s.rating);
    return total / _suppliers.length;
  }

  @override
  Future<List<Supplier>> getSuppliersByRating(double minRating) async =>
    _suppliers.values.where((s) => s.rating >= minRating).toList();

  // Inventory Methods
  @override
  Future<void> createInventoryItem(InventoryItem item) async => _inventory[item.itemId] = item;

  @override
  Future<InventoryItem?> getInventoryItem(String itemId) async => _inventory[itemId];

  @override
  Future<List<InventoryItem>> getAllInventoryItems() async => _inventory.values.toList();

  @override
  Future<List<InventoryItem>> getInventoryByStatus(InventoryStatus status) async =>
    _inventory.values.where((i) => i.status == status).toList();

  @override
  Future<List<InventoryItem>> getLowStockItems() async =>
    _inventory.values.where((i) => i.isLowStock).toList();

  @override
  Future<List<InventoryItem>> getOverStockItems() async =>
    _inventory.values.where((i) => i.isOverStock).toList();

  @override
  Future<void> updateInventoryItem(InventoryItem item) async => _inventory[item.itemId] = item;

  @override
  Future<void> deleteInventoryItem(String itemId) async => _inventory.remove(itemId);

  @override
  Future<int> getTotalInventoryCount() async => _inventory.values.fold<int>(0, (sum, i) => sum + i.quantity);

  @override
  Future<double> getTotalInventoryValue() async => _inventory.values.fold<double>(0, (sum, i) => sum + i.totalValue);

  @override
  Future<List<InventoryItem>> getInventoryByWarehouse(String warehouseId) async =>
    _inventory.values.where((i) => i.warehouseId == warehouseId).toList();

  @override
  Future<List<InventoryItem>> getInventoryBySku(String sku) async =>
    _inventory.values.where((i) => i.sku == sku).toList();

  // Procurement Methods
  @override
  Future<void> createProcurementOrder(ProcurementOrder order) async => _procurementOrders[order.orderId] = order;

  @override
  Future<ProcurementOrder?> getProcurementOrder(String orderId) async => _procurementOrders[orderId];

  @override
  Future<List<ProcurementOrder>> getAllProcurementOrders() async => _procurementOrders.values.toList();

  @override
  Future<List<ProcurementOrder>> getProcurementByStatus(ProcurementStatus status) async =>
    _procurementOrders.values.where((p) => p.status == status).toList();

  @override
  Future<List<ProcurementOrder>> getPendingOrders() async =>
    _procurementOrders.values.where((p) => p.isPending).toList();

  @override
  Future<List<ProcurementOrder>> getApprovedOrders() async =>
    _procurementOrders.values.where((p) => p.isApproved).toList();

  @override
  Future<void> updateProcurementOrder(ProcurementOrder order) async => _procurementOrders[order.orderId] = order;

  @override
  Future<void> deleteProcurementOrder(String orderId) async => _procurementOrders.remove(orderId);

  @override
  Future<int> getProcurementOrderCount() async => _procurementOrders.length;

  @override
  Future<double> getTotalProcurementAmount() async =>
    _procurementOrders.values.fold<double>(0, (sum, p) => sum + p.orderAmount);

  @override
  Future<List<ProcurementOrder>> getUrgentOrders() async =>
    _procurementOrders.values.where((p) => p.isUrgent).toList();

  @override
  Future<List<ProcurementOrder>> getOrdersBySupplier(String supplierId) async =>
    _procurementOrders.values.where((p) => p.supplierId == supplierId).toList();

  // Shipment Methods
  @override
  Future<void> createShipment(Shipment shipment) async => _shipments[shipment.shipmentId] = shipment;

  @override
  Future<Shipment?> getShipment(String shipmentId) async => _shipments[shipmentId];

  @override
  Future<List<Shipment>> getAllShipments() async => _shipments.values.toList();

  @override
  Future<List<Shipment>> getShipmentsByStatus(ShipmentStatus status) async =>
    _shipments.values.where((s) => s.status == status).toList();

  @override
  Future<List<Shipment>> getInTransitShipments() async =>
    _shipments.values.where((s) => s.status == ShipmentStatus.inTransit).toList();

  @override
  Future<List<Shipment>> getDelayedShipments() async =>
    _shipments.values.where((s) => s.isDelayed).toList();

  @override
  Future<void> updateShipment(Shipment shipment) async => _shipments[shipment.shipmentId] = shipment;

  @override
  Future<void> deleteShipment(String shipmentId) async => _shipments.remove(shipmentId);

  @override
  Future<int> getShipmentCount() async => _shipments.length;

  @override
  Future<List<Shipment>> getShipmentsByTrackingNumber(String trackingNumber) async =>
    _shipments.values.where((s) => s.trackingNumber == trackingNumber).toList();

  @override
  Future<List<Shipment>> getRecentShipments(Duration duration) async =>
    _shipments.values.where((s) => DateTime.now().difference(s.shipDate) <= duration).toList();

  @override
  Future<double> getAverageDeliveryTime() async {
    final delivered = _shipments.values.where((s) => s.isDelivered).toList();
    if (delivered.isEmpty) return 0;
    final totalDays = delivered.fold<int>(0, (sum, s) => sum + s.daysInTransit);
    return totalDays / delivered.length;
  }

  // Warehouse Methods
  @override
  Future<void> createWarehouse(Warehouse warehouse) async => _warehouses[warehouse.warehouseId] = warehouse;

  @override
  Future<Warehouse?> getWarehouse(String warehouseId) async => _warehouses[warehouseId];

  @override
  Future<List<Warehouse>> getAllWarehouses() async => _warehouses.values.toList();

  @override
  Future<List<Warehouse>> getWarehousesByType(WarehouseType type) async =>
    _warehouses.values.where((w) => w.type == type).toList();

  @override
  Future<List<Warehouse>> getNearCapacityWarehouses() async =>
    _warehouses.values.where((w) => w.isNearCapacity).toList();

  @override
  Future<void> updateWarehouse(Warehouse warehouse) async => _warehouses[warehouse.warehouseId] = warehouse;

  @override
  Future<void> deleteWarehouse(String warehouseId) async => _warehouses.remove(warehouseId);

  @override
  Future<int> getWarehouseCount() async => _warehouses.length;

  @override
  Future<double> getAverageUtilizationRate() async {
    if (_warehouses.isEmpty) return 0;
    final total = _warehouses.values.fold<double>(0, (sum, w) => sum + w.utilizationRate);
    return total / _warehouses.length;
  }

  @override
  Future<Map<String, double>> getWarehouseUtilization() async {
    return {for (final w in _warehouses.values) w.warehouseName: w.utilizationRate};
  }

  // Delivery Route Methods
  @override
  Future<void> createDeliveryRoute(DeliveryRoute route) async => _deliveryRoutes[route.routeId] = route;

  @override
  Future<DeliveryRoute?> getDeliveryRoute(String routeId) async => _deliveryRoutes[routeId];

  @override
  Future<List<DeliveryRoute>> getAllDeliveryRoutes() async => _deliveryRoutes.values.toList();

  @override
  Future<List<DeliveryRoute>> getActiveRoutes() async =>
    _deliveryRoutes.values.where((r) => r.isActive).toList();

  @override
  Future<List<DeliveryRoute>> getRoutesByDriver(String driverId) async =>
    _deliveryRoutes.values.where((r) => r.driverId == driverId).toList();

  @override
  Future<List<DeliveryRoute>> getRoutesByOptimization(RouteOptimization optimization) async =>
    _deliveryRoutes.values.where((r) => r.optimization == optimization).toList();

  @override
  Future<void> updateDeliveryRoute(DeliveryRoute route) async => _deliveryRoutes[route.routeId] = route;

  @override
  Future<void> deleteDeliveryRoute(String routeId) async => _deliveryRoutes.remove(routeId);

  @override
  Future<int> getDeliveryRouteCount() async => _deliveryRoutes.length;

  @override
  Future<double> getAverageRouteCost() async {
    if (_deliveryRoutes.isEmpty) return 0;
    final total = _deliveryRoutes.values.fold<double>(0, (sum, r) => sum + r.fuelCost);
    return total / _deliveryRoutes.length;
  }

  // Quality Inspection Methods
  @override
  Future<void> createQualityInspection(QualityInspection inspection) async => 
    _inspections[inspection.inspectionId] = inspection;

  @override
  Future<QualityInspection?> getQualityInspection(String inspectionId) async => 
    _inspections[inspectionId];

  @override
  Future<List<QualityInspection>> getAllInspections() async => _inspections.values.toList();

  @override
  Future<List<QualityInspection>> getInspectionsByShipment(String shipmentId) async =>
    _inspections.values.where((i) => i.shipmentId == shipmentId).toList();

  @override
  Future<List<QualityInspection>> getFailedInspections() async =>
    _inspections.values.where((i) => !i.isPassed).toList();

  @override
  Future<List<QualityInspection>> getRecentInspections(Duration duration) async =>
    _inspections.values.where((i) => DateTime.now().difference(i.inspectionDate) <= duration).toList();

  @override
  Future<void> updateQualityInspection(QualityInspection inspection) async => 
    _inspections[inspection.inspectionId] = inspection;

  @override
  Future<void> deleteQualityInspection(String inspectionId) async => 
    _inspections.remove(inspectionId);

  @override
  Future<int> getInspectionCount() async => _inspections.length;

  @override
  Future<double> getAverageDefectRate() async {
    if (_inspections.isEmpty) return 0;
    final total = _inspections.values.fold<double>(0, (sum, i) => sum + i.defectRate);
    return total / _inspections.length;
  }

  // Supplier Contract Methods
  @override
  Future<void> createSupplierContract(SupplierContract contract) async => 
    _contracts[contract.contractId] = contract;

  @override
  Future<SupplierContract?> getSupplierContract(String contractId) async => 
    _contracts[contractId];

  @override
  Future<List<SupplierContract>> getAllContracts() async => _contracts.values.toList();

  @override
  Future<List<SupplierContract>> getActiveContracts() async =>
    _contracts.values.where((c) => c.isActive).toList();

  @override
  Future<List<SupplierContract>> getExpiringContracts() async =>
    _contracts.values.where((c) => c.isExpiring).toList();

  @override
  Future<List<SupplierContract>> getContractsBySupplier(String supplierId) async =>
    _contracts.values.where((c) => c.supplierId == supplierId).toList();

  @override
  Future<void> updateSupplierContract(SupplierContract contract) async => 
    _contracts[contract.contractId] = contract;

  @override
  Future<void> deleteSupplierContract(String contractId) async => 
    _contracts.remove(contractId);

  @override
  Future<int> getContractCount() async => _contracts.length;

  @override
  Future<double> getTotalContractValue() async =>
    _contracts.values.fold<double>(0, (sum, c) => sum + c.annualValue);

  // Logistics Metrics Methods
  @override
  Future<void> createLogisticsMetrics(LogisticsMetrics metrics) async => 
    _metrics[metrics.metricsId] = metrics;

  @override
  Future<LogisticsMetrics?> getLogisticsMetrics(String metricsId) async => 
    _metrics[metricsId];

  @override
  Future<List<LogisticsMetrics>> getAllMetrics() async => _metrics.values.toList();

  @override
  Future<LogisticsMetrics?> getLatestMetrics() async {
    if (_metrics.isEmpty) return null;
    return _metrics.values.reduce((a, b) => a.reportDate.isAfter(b.reportDate) ? a : b);
  }

  @override
  Future<void> updateLogisticsMetrics(LogisticsMetrics metrics) async => 
    _metrics[metrics.metricsId] = metrics;

  @override
  Future<void> deleteLogisticsMetrics(String metricsId) async => 
    _metrics.remove(metricsId);

  @override
  Future<int> getMetricsCount() async => _metrics.length;

  @override
  Future<double> getAverageOnTimeDeliveryRate() async {
    if (_metrics.isEmpty) return 0;
    final total = _metrics.values.fold<double>(0, (sum, m) => sum + m.onTimeDeliveryRate);
    return total / _metrics.length;
  }
}

// ============================================================================
// Specialized Engines
// ============================================================================

class SupplierManagementEngine {
  final SupplyChainRepository repository;

  SupplierManagementEngine(this.repository);

  Future<List<Supplier>> getTopSuppliers(int count) async {
    final suppliers = await repository.getAllSuppliers();
    suppliers.sort((a, b) => b.rating.compareTo(a.rating));
    return suppliers.take(count).toList();
  }

  Future<double> getSupplierPerformanceScore() async {
    final suppliers = await repository.getActiveSuppliers();
    if (suppliers.isEmpty) return 0;
    return suppliers.fold<double>(0, (sum, s) => sum + (s.rating * 0.5 + s.onTimeDeliveryPercent * 0.5)) / suppliers.length;
  }
}

class InventoryManagementEngine {
  final SupplyChainRepository repository;

  InventoryManagementEngine(this.repository);

  Future<Map<String, int>> getInventoryStatus() async {
    final items = await repository.getAllInventoryItems();
    return {
      'inStock': items.where((i) => i.status == InventoryStatus.inStock).length,
      'lowStock': items.where((i) => i.isLowStock).length,
      'outOfStock': items.where((i) => i.status == InventoryStatus.outOfStock).length,
    };
  }

  Future<double> getInventoryHealthScore() async {
    final value = await repository.getTotalInventoryValue();
    final turnover = (await repository.getTotalInventoryCount()).toDouble();
    return turnover > 0 ? (value / turnover) / 100 : 0;
  }
}

class ProcurementEngine {
  final SupplyChainRepository repository;

  ProcurementEngine(this.repository);

  Future<List<ProcurementOrder>> getOrdersNeedingApproval() async =>
    await repository.getProcurementByStatus(ProcurementStatus.submitted);

  Future<double> getProcurementEfficiency() async {
    final total = await repository.getProcurementOrderCount();
    final approved = (await repository.getApprovedOrders()).length;
    return total > 0 ? (approved / total) * 100 : 0;
  }
}

class ShipmentTrackingEngine {
  final SupplyChainRepository repository;

  ShipmentTrackingEngine(this.repository);

  Future<int> getDelayedShipmentCount() async =>
    (await repository.getDelayedShipments()).length;

  Future<double> getOnTimeDeliveryRate() async {
    final all = await repository.getAllShipments();
    if (all.isEmpty) return 0;
    final delivered = all.where((s) => s.isDelivered).length;
    return (delivered / all.length) * 100;
  }
}

class QualityAssuranceEngine {
  final SupplyChainRepository repository;

  QualityAssuranceEngine(this.repository);

  Future<List<QualityInspection>> getFailedInspections() async =>
    await repository.getFailedInspections();

  Future<double> getQualityScore() async {
    final all = await repository.getAllInspections();
    if (all.isEmpty) return 100;
    final passed = all.where((i) => i.isPassed).length;
    return (passed / all.length) * 100;
  }
}

// ============================================================================
// Manager
// ============================================================================

class SupplyChainManager {
  final SupplyChainRepository repository;
  late final SupplierManagementEngine supplierEngine;
  late final InventoryManagementEngine inventoryEngine;
  late final ProcurementEngine procurementEngine;
  late final ShipmentTrackingEngine shipmentEngine;
  late final QualityAssuranceEngine qualityEngine;

  SupplyChainManager(this.repository) {
    supplierEngine = SupplierManagementEngine(repository);
    inventoryEngine = InventoryManagementEngine(repository);
    procurementEngine = ProcurementEngine(repository);
    shipmentEngine = ShipmentTrackingEngine(repository);
    qualityEngine = QualityAssuranceEngine(repository);
  }

  Future<Map<String, dynamic>> getSupplyChainDashboard() async {
    return {
      'totalSuppliers': await repository.getSupplierCount(),
      'activeSuppliers': (await repository.getActiveSuppliers()).length,
      'inventoryValue': await repository.getTotalInventoryValue(),
      'lowStockItems': (await repository.getLowStockItems()).length,
      'pendingOrders': (await repository.getPendingOrders()).length,
      'inTransitShipments': (await repository.getInTransitShipments()).length,
      'delayedShipments': await shipmentEngine.getDelayedShipmentCount(),
      'qualityScore': await qualityEngine.getQualityScore(),
      'onTimeDeliveryRate': await shipmentEngine.getOnTimeDeliveryRate(),
      'supplierPerformance': await supplierEngine.getSupplierPerformanceScore(),
    };
  }
}

// ============================================================================
// Facade
// ============================================================================

class SupplyChainFacade {
  final SupplyChainRepository _repository;
  late final SupplyChainManager _manager;

  SupplyChainFacade(this._repository) {
    _manager = SupplyChainManager(_repository);
  }

  Future<void> addSupplier(Supplier supplier) => _repository.createSupplier(supplier);
  Future<Supplier?> getSupplier(String id) => _repository.getSupplier(id);
  Future<List<Supplier>> getActiveSuppliers() => _repository.getActiveSuppliers();
  Future<List<Supplier>> getTopSuppliers() => _manager.supplierEngine.getTopSuppliers(5);

  Future<void> addInventoryItem(InventoryItem item) => _repository.createInventoryItem(item);
  Future<List<InventoryItem>> getLowStockItems() => _repository.getLowStockItems();
  Future<double> getTotalInventoryValue() => _repository.getTotalInventoryValue();

  Future<void> createProcurementOrder(ProcurementOrder order) => 
    _repository.createProcurementOrder(order);
  Future<List<ProcurementOrder>> getPendingOrders() => _repository.getPendingOrders();
  Future<List<ProcurementOrder>> getUrgentOrders() => _repository.getUrgentOrders();

  Future<void> recordShipment(Shipment shipment) => _repository.createShipment(shipment);
  Future<List<Shipment>> getInTransitShipments() => _repository.getInTransitShipments();
  Future<List<Shipment>> getDelayedShipments() => _repository.getDelayedShipments();

  Future<void> addWarehouse(Warehouse warehouse) => _repository.createWarehouse(warehouse);
  Future<List<Warehouse>> getNearCapacityWarehouses() => _repository.getNearCapacityWarehouses();

  Future<void> createDeliveryRoute(DeliveryRoute route) => _repository.createDeliveryRoute(route);
  Future<List<DeliveryRoute>> getActiveRoutes() => _repository.getActiveRoutes();

  Future<void> recordInspection(QualityInspection inspection) => 
    _repository.createQualityInspection(inspection);
  Future<List<QualityInspection>> getFailedInspections() => _repository.getFailedInspections();

  Future<void> createContract(SupplierContract contract) => 
    _repository.createSupplierContract(contract);
  Future<List<SupplierContract>> getExpiringContracts() => _repository.getExpiringContracts();

  Future<Map<String, dynamic>> getSupplyChainDashboard() => 
    _manager.getSupplyChainDashboard();
}
