/// Advanced Human Resources & Talent Management Models
/// Comprehensive employee management, recruitment, payroll, and performance tracking

// ============================================================================
// Enums (6 total)
// ============================================================================

enum EmploymentStatus {
  active,
  onLeave,
  suspended,
  terminated,
  retired,
  contract;

  String get displayName {
    switch (this) {
      case EmploymentStatus.active:
        return 'Active (在職)';
      case EmploymentStatus.onLeave:
        return 'On Leave (休暇中)';
      case EmploymentStatus.suspended:
        return 'Suspended (停職)';
      case EmploymentStatus.terminated:
        return 'Terminated (解雇)';
      case EmploymentStatus.retired:
        return 'Retired (退職)';
      case EmploymentStatus.contract:
        return 'Contract (契約社員)';
    }
  }
}

enum DepartmentType {
  engineering,
  sales,
  marketing,
  operations,
  humanResources,
  finance,
  legal,
  administration;

  String get displayName {
    switch (this) {
      case DepartmentType.engineering:
        return 'Engineering (エンジニアリング)';
      case DepartmentType.sales:
        return 'Sales (営業)';
      case DepartmentType.marketing:
        return 'Marketing (マーケティング)';
      case DepartmentType.operations:
        return 'Operations (運営)';
      case DepartmentType.humanResources:
        return 'Human Resources (人事)';
      case DepartmentType.finance:
        return 'Finance (財務)';
      case DepartmentType.legal:
        return 'Legal (法務)';
      case DepartmentType.administration:
        return 'Administration (管理)';
    }
  }
}

enum RecruitmentStatus {
  planning,
  openings,
  inProgress,
  screening,
  interviewing,
  offerExtended,
  hired,
  rejected;

  String get displayName {
    switch (this) {
      case RecruitmentStatus.planning:
        return 'Planning (計画中)';
      case RecruitmentStatus.openings:
        return 'Openings (募集中)';
      case RecruitmentStatus.inProgress:
        return 'In Progress (進行中)';
      case RecruitmentStatus.screening:
        return 'Screening (スクリーニング)';
      case RecruitmentStatus.interviewing:
        return 'Interviewing (面接中)';
      case RecruitmentStatus.offerExtended:
        return 'Offer Extended (オファー送付)';
      case RecruitmentStatus.hired:
        return 'Hired (採用)';
      case RecruitmentStatus.rejected:
        return 'Rejected (不採用)';
    }
  }
}

enum LeaveType {
  annual,
  sick,
  personal,
  maternity,
  paternity,
  unpaid,
  sabbatical;

  String get displayName {
    switch (this) {
      case LeaveType.annual:
        return 'Annual (年次休暇)';
      case LeaveType.sick:
        return 'Sick Leave (病気休暇)';
      case LeaveType.personal:
        return 'Personal (個人用)';
      case LeaveType.maternity:
        return 'Maternity (産休)';
      case LeaveType.paternity:
        return 'Paternity (育児休暇)';
      case LeaveType.unpaid:
        return 'Unpaid (無給)';
      case LeaveType.sabbatical:
        return 'Sabbatical (休職)';
    }
  }
}

enum PerformanceRating {
  exceptional,
  exceeds,
  meets,
  needsImprovement,
  unsatisfactory;

  String get displayName {
    switch (this) {
      case PerformanceRating.exceptional:
        return 'Exceptional (優秀)';
      case PerformanceRating.exceeds:
        return 'Exceeds (超過)';
      case PerformanceRating.meets:
        return 'Meets (達成)';
      case PerformanceRating.needsImprovement:
        return 'Needs Improvement (改善必要)';
      case PerformanceRating.unsatisfactory:
        return 'Unsatisfactory (不満足)';
    }
  }
}

enum TrainingStatus {
  planned,
  scheduled,
  inProgress,
  completed,
  certified,
  cancelled;

  String get displayName {
    switch (this) {
      case TrainingStatus.planned:
        return 'Planned (計画中)';
      case TrainingStatus.scheduled:
        return 'Scheduled (予定済)';
      case TrainingStatus.inProgress:
        return 'In Progress (進行中)';
      case TrainingStatus.completed:
        return 'Completed (完了)';
      case TrainingStatus.certified:
        return 'Certified (認定)';
      case TrainingStatus.cancelled:
        return 'Cancelled (キャンセル)';
    }
  }
}

// ============================================================================
// Model Classes (10 total)
// ============================================================================

class Employee {
  final String employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String department;
  final DepartmentType departmentType;
  final String jobTitle;
  final double salary;
  final EmploymentStatus status;
  final DateTime hireDate;
  final String? managerId;

  const Employee({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.department,
    required this.departmentType,
    required this.jobTitle,
    required this.salary,
    required this.status,
    required this.hireDate,
    this.managerId,
  });

  String get fullName => '$firstName $lastName';
  bool get isActive => status == EmploymentStatus.active;
  int get tenureInDays => DateTime.now().difference(hireDate).inDays;
  int get tenureInYears => (tenureInDays / 365).floor();
  bool get hasManager => managerId != null;

  Employee copyWith({
    String? employeeId,
    String? firstName,
    String? lastName,
    String? email,
    String? department,
    DepartmentType? departmentType,
    String? jobTitle,
    double? salary,
    EmploymentStatus? status,
    DateTime? hireDate,
    String? managerId,
  }) {
    return Employee(
      employeeId: employeeId ?? this.employeeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      department: department ?? this.department,
      departmentType: departmentType ?? this.departmentType,
      jobTitle: jobTitle ?? this.jobTitle,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      hireDate: hireDate ?? this.hireDate,
      managerId: managerId ?? this.managerId,
    );
  }
}

class Department {
  final String departmentId;
  final String departmentName;
  final DepartmentType departmentType;
  final String managerId;
  final double budgetAllocation;
  final List<String> employeeIds;
  final DateTime createdDate;

  const Department({
    required this.departmentId,
    required this.departmentName,
    required this.departmentType,
    required this.managerId,
    required this.budgetAllocation,
    required this.employeeIds,
    required this.createdDate,
  });

  int get headcount => employeeIds.length;
  bool get isBudgetAllocated => budgetAllocation > 0;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;
  double get avgBudgetPerEmployee =>
      headcount > 0 ? budgetAllocation / headcount : 0;

  Department copyWith({
    String? departmentId,
    String? departmentName,
    DepartmentType? departmentType,
    String? managerId,
    double? budgetAllocation,
    List<String>? employeeIds,
    DateTime? createdDate,
  }) {
    return Department(
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      departmentType: departmentType ?? this.departmentType,
      managerId: managerId ?? this.managerId,
      budgetAllocation: budgetAllocation ?? this.budgetAllocation,
      employeeIds: employeeIds ?? this.employeeIds,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

class Compensation {
  final String compensationId;
  final String employeeId;
  final double baseSalary;
  final double bonus;
  final double benefits;
  final double stocks;
  final DateTime effectiveDate;
  final String? notes;

  const Compensation({
    required this.compensationId,
    required this.employeeId,
    required this.baseSalary,
    required this.bonus,
    required this.benefits,
    required this.stocks,
    required this.effectiveDate,
    this.notes,
  });

  double get totalCompensation => baseSalary + bonus + benefits + stocks;
  double get percentageBonus => (bonus / baseSalary) * 100;
  int get ageInDays => DateTime.now().difference(effectiveDate).inDays;
  bool get isRecent => ageInDays < 30;

  Compensation copyWith({
    String? compensationId,
    String? employeeId,
    double? baseSalary,
    double? bonus,
    double? benefits,
    double? stocks,
    DateTime? effectiveDate,
    String? notes,
  }) {
    return Compensation(
      compensationId: compensationId ?? this.compensationId,
      employeeId: employeeId ?? this.employeeId,
      baseSalary: baseSalary ?? this.baseSalary,
      bonus: bonus ?? this.bonus,
      benefits: benefits ?? this.benefits,
      stocks: stocks ?? this.stocks,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      notes: notes ?? this.notes,
    );
  }
}

class Recruitment {
  final String recruitmentId;
  final String positionTitle;
  final String departmentId;
  final DepartmentType departmentType;
  final RecruitmentStatus status;
  final int targetHires;
  final int applicantsReceived;
  final DateTime openDate;
  final String? targetCloseDate;

  const Recruitment({
    required this.recruitmentId,
    required this.positionTitle,
    required this.departmentId,
    required this.departmentType,
    required this.status,
    required this.targetHires,
    required this.applicantsReceived,
    required this.openDate,
    this.targetCloseDate,
  });

  bool get isOpen => status == RecruitmentStatus.openings ||
      status == RecruitmentStatus.inProgress;
  bool get isHired => status == RecruitmentStatus.hired;
  int get positionsFilled => applicantsReceived > targetHires ? targetHires : applicantsReceived;
  int get positionsRemaining => targetHires - positionsFilled;
  int get ageInDays => DateTime.now().difference(openDate).inDays;

  Recruitment copyWith({
    String? recruitmentId,
    String? positionTitle,
    String? departmentId,
    DepartmentType? departmentType,
    RecruitmentStatus? status,
    int? targetHires,
    int? applicantsReceived,
    DateTime? openDate,
    String? targetCloseDate,
  }) {
    return Recruitment(
      recruitmentId: recruitmentId ?? this.recruitmentId,
      positionTitle: positionTitle ?? this.positionTitle,
      departmentId: departmentId ?? this.departmentId,
      departmentType: departmentType ?? this.departmentType,
      status: status ?? this.status,
      targetHires: targetHires ?? this.targetHires,
      applicantsReceived: applicantsReceived ?? this.applicantsReceived,
      openDate: openDate ?? this.openDate,
      targetCloseDate: targetCloseDate ?? this.targetCloseDate,
    );
  }
}

class LeaveRequest {
  final String leaveId;
  final String employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isApproved;
  final String? reason;

  const LeaveRequest({
    required this.leaveId,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.isApproved = false,
    this.reason,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isPending => !isApproved;

  LeaveRequest copyWith({
    String? leaveId,
    String? employeeId,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isApproved,
    String? reason,
  }) {
    return LeaveRequest(
      leaveId: leaveId ?? this.leaveId,
      employeeId: employeeId ?? this.employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isApproved: isApproved ?? this.isApproved,
      reason: reason ?? this.reason,
    );
  }
}

class PerformanceReview {
  final String reviewId;
  final String employeeId;
  final String reviewerId;
  final PerformanceRating rating;
  final String strengths;
  final String areasForImprovement;
  final String goals;
  final DateTime reviewDate;

  const PerformanceReview({
    required this.reviewId,
    required this.employeeId,
    required this.reviewerId,
    required this.rating,
    required this.strengths,
    required this.areasForImprovement,
    required this.goals,
    required this.reviewDate,
  });

  bool get isPositive => rating == PerformanceRating.exceptional ||
      rating == PerformanceRating.exceeds;
  bool get needsImprovement => rating == PerformanceRating.needsImprovement ||
      rating == PerformanceRating.unsatisfactory;
  int get ageInDays => DateTime.now().difference(reviewDate).inDays;
  bool get isRecent => ageInDays < 30;

  String toMarkdown() {
    return '''# Performance Review
- Employee: $employeeId
- Rating: ${rating.displayName}
- Strengths: $strengths
- Areas for Improvement: $areasForImprovement
- Goals: $goals
- Date: ${reviewDate.toString()}
''';
  }

  PerformanceReview copyWith({
    String? reviewId,
    String? employeeId,
    String? reviewerId,
    PerformanceRating? rating,
    String? strengths,
    String? areasForImprovement,
    String? goals,
    DateTime? reviewDate,
  }) {
    return PerformanceReview(
      reviewId: reviewId ?? this.reviewId,
      employeeId: employeeId ?? this.employeeId,
      reviewerId: reviewerId ?? this.reviewerId,
      rating: rating ?? this.rating,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      goals: goals ?? this.goals,
      reviewDate: reviewDate ?? this.reviewDate,
    );
  }
}

class Training {
  final String trainingId;
  final String employeeId;
  final String trainingName;
  final TrainingStatus status;
  final DateTime startDate;
  final DateTime? completionDate;
  final double cost;
  final String? provider;

  const Training({
    required this.trainingId,
    required this.employeeId,
    required this.trainingName,
    required this.status,
    required this.startDate,
    this.completionDate,
    required this.cost,
    this.provider,
  });

  bool get isCompleted => status == TrainingStatus.completed ||
      status == TrainingStatus.certified;
  bool get isCertified => status == TrainingStatus.certified;
  bool get isOngoing => status == TrainingStatus.inProgress;
  int get durationDays => completionDate != null
      ? completionDate!.difference(startDate).inDays
      : DateTime.now().difference(startDate).inDays;
  int get ageInDays => DateTime.now().difference(startDate).inDays;

  Training copyWith({
    String? trainingId,
    String? employeeId,
    String? trainingName,
    TrainingStatus? status,
    DateTime? startDate,
    DateTime? completionDate,
    double? cost,
    String? provider,
  }) {
    return Training(
      trainingId: trainingId ?? this.trainingId,
      employeeId: employeeId ?? this.employeeId,
      trainingName: trainingName ?? this.trainingName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      cost: cost ?? this.cost,
      provider: provider ?? this.provider,
    );
  }
}

class Payroll {
  final String payrollId;
  final String employeeId;
  final double grossSalary;
  final double taxes;
  final double deductions;
  final double netPay;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final DateTime paymentDate;

  const Payroll({
    required this.payrollId,
    required this.employeeId,
    required this.grossSalary,
    required this.taxes,
    required this.deductions,
    required this.netPay,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.paymentDate,
  });

  double get totalDeductions => taxes + deductions;
  double get effectiveTaxRate => (taxes / grossSalary) * 100;
  bool get isPaid => DateTime.now().isAfter(paymentDate);
  int get ageInDays => DateTime.now().difference(paymentDate).inDays;

  Payroll copyWith({
    String? payrollId,
    String? employeeId,
    double? grossSalary,
    double? taxes,
    double? deductions,
    double? netPay,
    DateTime? payPeriodStart,
    DateTime? payPeriodEnd,
    DateTime? paymentDate,
  }) {
    return Payroll(
      payrollId: payrollId ?? this.payrollId,
      employeeId: employeeId ?? this.employeeId,
      grossSalary: grossSalary ?? this.grossSalary,
      taxes: taxes ?? this.taxes,
      deductions: deductions ?? this.deductions,
      netPay: netPay ?? this.netPay,
      payPeriodStart: payPeriodStart ?? this.payPeriodStart,
      payPeriodEnd: payPeriodEnd ?? this.payPeriodEnd,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }
}

class Attendance {
  final String attendanceId;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? status;
  final String? notes;

  const Attendance({
    required this.attendanceId,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.notes,
  });

  bool get isPresent => checkInTime != null;
  bool get isAbsent => !isPresent;
  int get hoursWorked => checkInTime != null && checkOutTime != null
      ? checkOutTime!.difference(checkInTime!).inHours
      : 0;
  bool get isRecent => DateTime.now().difference(date).inDays < 7;

  Attendance copyWith({
    String? attendanceId,
    String? employeeId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    String? notes,
  }) {
    return Attendance(
      attendanceId: attendanceId ?? this.attendanceId,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class OrgChart {
  final String chartId;
  final String organizationName;
  final Map<String, String> managerReports;
  final List<String> departmentIds;
  final DateTime lastUpdatedDate;

  const OrgChart({
    required this.chartId,
    required this.organizationName,
    required this.managerReports,
    required this.departmentIds,
    required this.lastUpdatedDate,
  });

  int get totalDepartments => departmentIds.length;
  int get totalManagers => managerReports.keys.length;
  bool get isRecent => DateTime.now().difference(lastUpdatedDate).inDays < 30;
  int get ageInDays => DateTime.now().difference(lastUpdatedDate).inDays;

  OrgChart copyWith({
    String? chartId,
    String? organizationName,
    Map<String, String>? managerReports,
    List<String>? departmentIds,
    DateTime? lastUpdatedDate,
  }) {
    return OrgChart(
      chartId: chartId ?? this.chartId,
      organizationName: organizationName ?? this.organizationName,
      managerReports: managerReports ?? this.managerReports,
      departmentIds: departmentIds ?? this.departmentIds,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
    );
  }
}
