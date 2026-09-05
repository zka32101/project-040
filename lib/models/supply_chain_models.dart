/// Advanced Supply Chain & Logistics Management Models
/// Comprehensive supplier management, inventory, procurement, and shipment tracking

// ============================================================================
// Enums (7 total)
// ============================================================================

enum SupplierStatus {
  active,
  inactive,
  suspended,
  probation,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case SupplierStatus.active:
        return 'Active (有効)';
      case SupplierStatus.inactive:
        return 'Inactive (非有効)';
      case SupplierStatus.suspended:
        return 'Suspended (一時停止)';
      case SupplierStatus.probation:
        return 'Probation (試用)';
      case SupplierStatus.approved:
        return 'Approved (承認)';
      case SupplierStatus.rejected:
        return 'Rejected (却下)';
    }
  }
}

enum InventoryStatus {
  inStock,
  lowStock,
  outOfStock,
  onOrder,
  reserved,
  obsolete;

  String get displayName {
    switch (this) {
      case InventoryStatus.inStock:
        return 'In Stock (在庫あり)';
      case InventoryStatus.lowStock:
        return 'Low Stock (在庫少)';
      case InventoryStatus.outOfStock:
        return 'Out of Stock (品切れ)';
      case InventoryStatus.onOrder:
        return 'On Order (発注中)';
      case InventoryStatus.reserved:
        return 'Reserved (予約済)';
      case InventoryStatus.obsolete:
        return 'Obsolete (廃止品)';
    }
  }
}

enum ProcurementStatus {
  draft,
  submitted,
  approved,
  rejected,
  ordered,
  received,
  cancelled;

  String get displayName {
    switch (this) {
      case ProcurementStatus.draft:
        return 'Draft (下書き)';
      case ProcurementStatus.submitted:
        return 'Submitted (提出)';
      case ProcurementStatus.approved:
        return 'Approved (承認)';
      case ProcurementStatus.rejected:
        return 'Rejected (却下)';
      case ProcurementStatus.ordered:
        return 'Ordered (発注済)';
      case ProcurementStatus.received:
        return 'Received (受取済)';
      case ProcurementStatus.cancelled:
        return 'Cancelled (キャンセル)';
    }
  }
}

enum ShipmentStatus {
  pending,
  processing,
  inTransit,
  delivered,
  delayed,
  failed;

  String get displayName {
    switch (this) {
      case ShipmentStatus.pending:
        return 'Pending (保留中)';
      case ShipmentStatus.processing:
        return 'Processing (処理中)';
      case ShipmentStatus.inTransit:
        return 'In Transit (輸送中)';
      case ShipmentStatus.delivered:
        return 'Delivered (配達済)';
      case ShipmentStatus.delayed:
        return 'Delayed (遅延)';
      case ShipmentStatus.failed:
        return 'Failed (失敗)';
    }
  }
}

enum WarehouseType {
  regional,
  distribution,
  fulfillment,
  crossDock,
  storage,
  coldStorage;

  String get displayName {
    switch (this) {
      case WarehouseType.regional:
        return 'Regional (地域)';
      case WarehouseType.distribution:
        return 'Distribution (流通)';
      case WarehouseType.fulfillment:
        return 'Fulfillment (フルフィルメント)';
      case WarehouseType.crossDock:
        return 'Cross-Dock (クロスドック)';
      case WarehouseType.storage:
        return 'Storage (保管)';
      case WarehouseType.coldStorage:
        return 'Cold Storage (冷蔵)';
    }
  }
}

enum RouteOptimization {
  shortest,
  fastest,
  costEffective,
  safest,
  environmental,
  balanced;

  String get displayName {
    switch (this) {
      case RouteOptimization.shortest:
        return 'Shortest (最短)';
      case RouteOptimization.fastest:
        return 'Fastest (最速)';
      case RouteOptimization.costEffective:
        return 'Cost-Effective (コスト効率)';
      case RouteOptimization.safest:
        return 'Safest (最安全)';
      case RouteOptimization.environmental:
        return 'Environmental (環境配慮)';
      case RouteOptimization.balanced:
        return 'Balanced (バランス)';
    }
  }
}

enum DefectCategory {
  packaging,
  quantity,
  quality,
  damage,
  contamination,
  missingParts;

  String get displayName {
    switch (this) {
      case DefectCategory.packaging:
        return 'Packaging (梱包)';
      case DefectCategory.quantity:
        return 'Quantity (数量)';
      case DefectCategory.quality:
        return 'Quality (品質)';
      case DefectCategory.damage:
        return 'Damage (破損)';
      case DefectCategory.contamination:
        return 'Contamination (汚染)';
      case DefectCategory.missingParts:
        return 'Missing Parts (部品不足)';
    }
  }
}

// ============================================================================
// Model Classes (10 total)
// ============================================================================

class Supplier {
  final String supplierId;
  final String supplierName;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final double rating;
  final SupplierStatus status;
  final int onTimeDeliveryPercent;
  final double qualityScore;
  final DateTime createdDate;
  final bool isPreferred;

  Supplier({
    required this.supplierId,
    required this.supplierName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.rating,
    required this.status,
    required this.onTimeDeliveryPercent,
    required this.qualityScore,
    required this.createdDate,
    required this.isPreferred,
  });

  bool get isActive => status == SupplierStatus.active;
  bool get isReliable => onTimeDeliveryPercent >= 95 && qualityScore >= 4.5;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  Supplier copyWith({
    String? supplierId,
    String? supplierName,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    double? rating,
    SupplierStatus? status,
    int? onTimeDeliveryPercent,
    double? qualityScore,
    DateTime? createdDate,
    bool? isPreferred,
  }) {
    return Supplier(
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      onTimeDeliveryPercent: onTimeDeliveryPercent ?? this.onTimeDeliveryPercent,
      qualityScore: qualityScore ?? this.qualityScore,
      createdDate: createdDate ?? this.createdDate,
      isPreferred: isPreferred ?? this.isPreferred,
    );
  }
}

class InventoryItem {
  final String itemId;
  final String sku;
  final String productName;
  final int quantity;
  final int minimumLevel;
  final int maximumLevel;
  final double unitCost;
  final InventoryStatus status;
  final String warehouseId;
  final DateTime lastUpdated;

  InventoryItem({
    required this.itemId,
    required this.sku,
    required this.productName,
    required this.quantity,
    required this.minimumLevel,
    required this.maximumLevel,
    required this.unitCost,
    required this.status,
    required this.warehouseId,
    required this.lastUpdated,
  });

  bool get isLowStock => quantity <= minimumLevel;
  bool get isOverStock => quantity >= maximumLevel;
  double get totalValue => quantity * unitCost;
  int get daysAgo => DateTime.now().difference(lastUpdated).inDays;

  InventoryItem copyWith({
    String? itemId,
    String? sku,
    String? productName,
    int? quantity,
    int? minimumLevel,
    int? maximumLevel,
    double? unitCost,
    InventoryStatus? status,
    String? warehouseId,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      itemId: itemId ?? this.itemId,
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      minimumLevel: minimumLevel ?? this.minimumLevel,
      maximumLevel: maximumLevel ?? this.maximumLevel,
      unitCost: unitCost ?? this.unitCost,
      status: status ?? this.status,
      warehouseId: warehouseId ?? this.warehouseId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ProcurementOrder {
  final String orderId;
  final String supplierId;
  final double orderAmount;
  final ProcurementStatus status;
  final DateTime orderDate;
  final DateTime dueDate;
  final int quantity;
  final String productName;
  final bool isUrgent;

  ProcurementOrder({
    required this.orderId,
    required this.supplierId,
    required this.orderAmount,
    required this.status,
    required this.orderDate,
    required this.dueDate,
    required this.quantity,
    required this.productName,
    required this.isUrgent,
  });

  bool get isPending => status == ProcurementStatus.draft || status == ProcurementStatus.submitted;
  bool get isApproved => status == ProcurementStatus.approved;
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  int get ageInDays => DateTime.now().difference(orderDate).inDays;

  ProcurementOrder copyWith({
    String? orderId,
    String? supplierId,
    double? orderAmount,
    ProcurementStatus? status,
    DateTime? orderDate,
    DateTime? dueDate,
    int? quantity,
    String? productName,
    bool? isUrgent,
  }) {
    return ProcurementOrder(
      orderId: orderId ?? this.orderId,
      supplierId: supplierId ?? this.supplierId,
      orderAmount: orderAmount ?? this.orderAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      dueDate: dueDate ?? this.dueDate,
      quantity: quantity ?? this.quantity,
      productName: productName ?? this.productName,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }
}

class Shipment {
  final String shipmentId;
  final String orderId;
  final String origin;
  final String destination;
  final ShipmentStatus status;
  final DateTime shipDate;
  final DateTime? expectedDelivery;
  final DateTime? actualDelivery;
  final double weight;
  final String trackingNumber;

  Shipment({
    required this.shipmentId,
    required this.orderId,
    required this.origin,
    required this.destination,
    required this.status,
    required this.shipDate,
    required this.expectedDelivery,
    required this.actualDelivery,
    required this.weight,
    required this.trackingNumber,
  });

  bool get isDelivered => status == ShipmentStatus.delivered;
  bool get isDelayed => status == ShipmentStatus.delayed;
  int get daysInTransit => DateTime.now().difference(shipDate).inDays;
  int get daysUntilDelivery => expectedDelivery?.difference(DateTime.now()).inDays ?? 0;

  Shipment copyWith({
    String? shipmentId,
    String? orderId,
    String? origin,
    String? destination,
    ShipmentStatus? status,
    DateTime? shipDate,
    DateTime? expectedDelivery,
    DateTime? actualDelivery,
    double? weight,
    String? trackingNumber,
  }) {
    return Shipment(
      shipmentId: shipmentId ?? this.shipmentId,
      orderId: orderId ?? this.orderId,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      status: status ?? this.status,
      shipDate: shipDate ?? this.shipDate,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      weight: weight ?? this.weight,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }
}

class Warehouse {
  final String warehouseId;
  final String warehouseName;
  final String location;
  final WarehouseType type;
  final double capacitySquareFeet;
  final double usedSquareFeet;
  final int staffCount;
  final DateTime createdDate;

  Warehouse({
    required this.warehouseId,
    required this.warehouseName,
    required this.location,
    required this.type,
    required this.capacitySquareFeet,
    required this.usedSquareFeet,
    required this.staffCount,
    required this.createdDate,
  });

  bool get isActive => usedSquareFeet > 0;
  double get utilizationRate => (usedSquareFeet / capacitySquareFeet) * 100;
  bool get isNearCapacity => utilizationRate >= 90;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  Warehouse copyWith({
    String? warehouseId,
    String? warehouseName,
    String? location,
    WarehouseType? type,
    double? capacitySquareFeet,
    double? usedSquareFeet,
    int? staffCount,
    DateTime? createdDate,
  }) {
    return Warehouse(
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      location: location ?? this.location,
      type: type ?? this.type,
      capacitySquareFeet: capacitySquareFeet ?? this.capacitySquareFeet,
      usedSquareFeet: usedSquareFeet ?? this.usedSquareFeet,
      staffCount: staffCount ?? this.staffCount,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

class DeliveryRoute {
  final String routeId;
  final String vehicleId;
  final String driverId;
  final List<String> stopLocations;
  final RouteOptimization optimization;
  final double totalDistance;
  final DateTime startTime;
  final DateTime? endTime;
  final double fuelCost;

  DeliveryRoute({
    required this.routeId,
    required this.vehicleId,
    required this.driverId,
    required this.stopLocations,
    required this.optimization,
    required this.totalDistance,
    required this.startTime,
    required this.endTime,
    required this.fuelCost,
  });

  bool get isActive => endTime == null;
  int get stopCount => stopLocations.length;
  int get durationHours => (endTime ?? DateTime.now()).difference(startTime).inHours;
  double get costPerMile => fuelCost / totalDistance;

  DeliveryRoute copyWith({
    String? routeId,
    String? vehicleId,
    String? driverId,
    List<String>? stopLocations,
    RouteOptimization? optimization,
    double? totalDistance,
    DateTime? startTime,
    DateTime? endTime,
    double? fuelCost,
  }) {
    return DeliveryRoute(
      routeId: routeId ?? this.routeId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      stopLocations: stopLocations ?? this.stopLocations,
      optimization: optimization ?? this.optimization,
      totalDistance: totalDistance ?? this.totalDistance,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      fuelCost: fuelCost ?? this.fuelCost,
    );
  }
}

class QualityInspection {
  final String inspectionId;
  final String shipmentId;
  final int itemsInspected;
  final int defectsFound;
  final DefectCategory? primaryDefect;
  final bool isPassed;
  final DateTime inspectionDate;
  final String inspectorName;
  final String notes;

  QualityInspection({
    required this.inspectionId,
    required this.shipmentId,
    required this.itemsInspected,
    required this.defectsFound,
    required this.primaryDefect,
    required this.isPassed,
    required this.inspectionDate,
    required this.inspectorName,
    required this.notes,
  });

  double get defectRate => (defectsFound / itemsInspected) * 100;
  bool get isRecent => DateTime.now().difference(inspectionDate).inDays <= 7;
  int get ageInDays => DateTime.now().difference(inspectionDate).inDays;

  QualityInspection copyWith({
    String? inspectionId,
    String? shipmentId,
    int? itemsInspected,
    int? defectsFound,
    DefectCategory? primaryDefect,
    bool? isPassed,
    DateTime? inspectionDate,
    String? inspectorName,
    String? notes,
  }) {
    return QualityInspection(
      inspectionId: inspectionId ?? this.inspectionId,
      shipmentId: shipmentId ?? this.shipmentId,
      itemsInspected: itemsInspected ?? this.itemsInspected,
      defectsFound: defectsFound ?? this.defectsFound,
      primaryDefect: primaryDefect ?? this.primaryDefect,
      isPassed: isPassed ?? this.isPassed,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      inspectorName: inspectorName ?? this.inspectorName,
      notes: notes ?? this.notes,
    );
  }
}

class SupplierContract {
  final String contractId;
  final String supplierId;
  final DateTime startDate;
  final DateTime endDate;
  final double annualValue;
  final int minOrderQuantity;
  final int leadTimeDays;
  final bool hasAutoRenewal;
  final String terms;

  SupplierContract({
    required this.contractId,
    required this.supplierId,
    required this.startDate,
    required this.endDate,
    required this.annualValue,
    required this.minOrderQuantity,
    required this.leadTimeDays,
    required this.hasAutoRenewal,
    required this.terms,
  });

  bool get isActive => DateTime.now().isBefore(endDate);
  bool get isExpiring => !isActive && DateTime.now().difference(endDate).inDays <= 30;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  int get ageInDays => DateTime.now().difference(startDate).inDays;

  SupplierContract copyWith({
    String? contractId,
    String? supplierId,
    DateTime? startDate,
    DateTime? endDate,
    double? annualValue,
    int? minOrderQuantity,
    int? leadTimeDays,
    bool? hasAutoRenewal,
    String? terms,
  }) {
    return SupplierContract(
      contractId: contractId ?? this.contractId,
      supplierId: supplierId ?? this.supplierId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      annualValue: annualValue ?? this.annualValue,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      hasAutoRenewal: hasAutoRenewal ?? this.hasAutoRenewal,
      terms: terms ?? this.terms,
    );
  }
}

class LogisticsMetrics {
  final String metricsId;
  final DateTime reportDate;
  final double onTimeDeliveryRate;
  final double inventoryTurnover;
  final double warehouseEfficiency;
  final double supplierPerformanceScore;
  final int totalShipmentsProcessed;
  final double avgDeliveryTime;
  final double costPerUnit;

  LogisticsMetrics({
    required this.metricsId,
    required this.reportDate,
    required this.onTimeDeliveryRate,
    required this.inventoryTurnover,
    required this.warehouseEfficiency,
    required this.supplierPerformanceScore,
    required this.totalShipmentsProcessed,
    required this.avgDeliveryTime,
    required this.costPerUnit,
  });

  bool get isHealthy => onTimeDeliveryRate >= 95 && supplierPerformanceScore >= 4.0;
  bool get isRecent => DateTime.now().difference(reportDate).inDays <= 30;
  int get ageInDays => DateTime.now().difference(reportDate).inDays;

  LogisticsMetrics copyWith({
    String? metricsId,
    DateTime? reportDate,
    double? onTimeDeliveryRate,
    double? inventoryTurnover,
    double? warehouseEfficiency,
    double? supplierPerformanceScore,
    int? totalShipmentsProcessed,
    double? avgDeliveryTime,
    double? costPerUnit,
  }) {
    return LogisticsMetrics(
      metricsId: metricsId ?? this.metricsId,
      reportDate: reportDate ?? this.reportDate,
      onTimeDeliveryRate: onTimeDeliveryRate ?? this.onTimeDeliveryRate,
      inventoryTurnover: inventoryTurnover ?? this.inventoryTurnover,
      warehouseEfficiency: warehouseEfficiency ?? this.warehouseEfficiency,
      supplierPerformanceScore: supplierPerformanceScore ?? this.supplierPerformanceScore,
      totalShipmentsProcessed: totalShipmentsProcessed ?? this.totalShipmentsProcessed,
      avgDeliveryTime: avgDeliveryTime ?? this.avgDeliveryTime,
      costPerUnit: costPerUnit ?? this.costPerUnit,
    );
  }
}
