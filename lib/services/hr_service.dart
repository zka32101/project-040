/// Advanced Human Resources & Talent Management Service
/// Provides comprehensive employee management, recruitment, and talent development

import 'package:flutter/foundation.dart';
import '../models/hr_models.dart';

// ============================================================================
// Repository Interface
// ============================================================================

abstract class HRRepository {
  // Employee Methods (12)
  Future<void> createEmployee(Employee employee);
  Future<Employee?> getEmployee(String employeeId);
  Future<List<Employee>> getAllEmployees();
  Future<List<Employee>> getEmployeesByDepartment(String department);
  Future<List<Employee>> getActiveEmployees();
  Future<List<Employee>> getEmployeesByStatus(EmploymentStatus status);
  Future<List<Employee>> getEmployeesByManager(String managerId);
  Future<void> updateEmployee(Employee employee);
  Future<void> deleteEmployee(String employeeId);
  Future<int> getEmployeeCount();
  Future<List<Employee>> getRecentHires(Duration duration);
  Future<double> getAverageSalary();

  // Department Methods (12)
  Future<void> createDepartment(Department department);
  Future<Department?> getDepartment(String departmentId);
  Future<List<Department>> getAllDepartments();
  Future<List<Department>> getDepartmentsByType(DepartmentType type);
  Future<Department?> getDepartmentByManager(String managerId);
  Future<void> updateDepartment(Department department);
  Future<void> deleteDepartment(String departmentId);
  Future<int> getDepartmentCount();
  Future<double> getTotalDepartmentBudget();
  Future<List<Department>> getDepartmentsByHeadcount(int minEmployees);
  Future<Map<String, List<String>>> getDepartmentEmployeeMapping();
  Future<List<Department>> getLargestDepartments();

  // Compensation Methods (10)
  Future<void> createCompensation(Compensation compensation);
  Future<Compensation?> getCompensation(String compensationId);
  Future<Compensation?> getLatestCompensationForEmployee(String employeeId);
  Future<List<Compensation>> getCompensationsForEmployee(String employeeId);
  Future<List<Compensation>> getRecentCompensationChanges(Duration duration);
  Future<void> updateCompensation(Compensation compensation);
  Future<void> deleteCompensation(String compensationId);
  Future<int> getCompensationCount();
  Future<double> getTotalCompensationAmount();
  Future<double> getAverageBonus();

  // Recruitment Methods (12)
  Future<void> createRecruitment(Recruitment recruitment);
  Future<Recruitment?> getRecruitment(String recruitmentId);
  Future<List<Recruitment>> getAllRecruitments();
  Future<List<Recruitment>> getOpenPositions();
  Future<List<Recruitment>> getRecruitmentsByDepartment(String departmentId);
  Future<List<Recruitment>> getRecruitmentsByStatus(RecruitmentStatus status);
  Future<List<Recruitment>> getRecruitmentsByType(DepartmentType type);
  Future<void> updateRecruitment(Recruitment recruitment);
  Future<void> deleteRecruitment(String recruitmentId);
  Future<int> getRecruitmentCount();
  Future<int> getTotalPositionsOpen();
  Future<double> getAverageTimeToFill();

  // Leave Request Methods (10)
  Future<void> createLeaveRequest(LeaveRequest leave);
  Future<LeaveRequest?> getLeaveRequest(String leaveId);
  Future<List<LeaveRequest>> getLeaveRequestsForEmployee(String employeeId);
  Future<List<LeaveRequest>> getApprovedLeaves();
  Future<List<LeaveRequest>> getPendingLeaves();
  Future<List<LeaveRequest>> getLeavesByType(LeaveType type);
  Future<void> updateLeaveRequest(LeaveRequest leave);
  Future<void> deleteLeaveRequest(String leaveId);
  Future<int> getLeaveRequestCount();
  Future<List<LeaveRequest>> getOngoingLeaves();

  // Performance Review Methods (10)
  Future<void> createPerformanceReview(PerformanceReview review);
  Future<PerformanceReview?> getPerformanceReview(String reviewId);
  Future<List<PerformanceReview>> getReviewsForEmployee(String employeeId);
  Future<List<PerformanceReview>> getReviewsByRating(PerformanceRating rating);
  Future<List<PerformanceReview>> getRecentReviews(Duration duration);
  Future<void> updatePerformanceReview(PerformanceReview review);
  Future<void> deletePerformanceReview(String reviewId);
  Future<int> getPerformanceReviewCount();
  Future<double> getAveragePerformanceScore();
  Future<List<PerformanceReview>> getNeedsImprovementReviews();

  // Training Methods (10)
  Future<void> createTraining(Training training);
  Future<Training?> getTraining(String trainingId);
  Future<List<Training>> getTrainingsForEmployee(String employeeId);
  Future<List<Training>> getCompletedTrainings();
  Future<List<Training>> getOngoingTrainings();
  Future<List<Training>> getTrainingsByStatus(TrainingStatus status);
  Future<void> updateTraining(Training training);
  Future<void> deleteTraining(String trainingId);
  Future<int> getTrainingCount();
  Future<double> getTotalTrainingCost();

  // Payroll Methods (10)
  Future<void> createPayroll(Payroll payroll);
  Future<Payroll?> getPayroll(String payrollId);
  Future<List<Payroll>> getPayrollsForEmployee(String employeeId);
  Future<List<Payroll>> getPayrollsByPeriod(DateTime startDate, DateTime endDate);
  Future<List<Payroll>> getUnpaidPayrolls();
  Future<void> updatePayroll(Payroll payroll);
  Future<void> deletePayroll(String payrollId);
  Future<int> getPayrollCount();
  Future<double> getTotalPayrollAmount();
  Future<List<Payroll>> getRecentPayrolls(Duration duration);

  // Attendance Methods (10)
  Future<void> createAttendance(Attendance attendance);
  Future<Attendance?> getAttendance(String attendanceId);
  Future<List<Attendance>> getAttendanceForEmployee(String employeeId);
  Future<List<Attendance>> getAttendanceByDate(DateTime date);
  Future<List<Attendance>> getAbsentEmployees(DateTime date);
  Future<List<Attendance>> getRecentAttendance(Duration duration);
  Future<void> updateAttendance(Attendance attendance);
  Future<void> deleteAttendance(String attendanceId);
  Future<int> getAttendanceRecordCount();
  Future<double> getAverageAttendanceRate();

  // Org Chart Methods (8)
  Future<void> createOrgChart(OrgChart chart);
  Future<OrgChart?> getOrgChart(String chartId);
  Future<List<OrgChart>> getAllOrgCharts();
  Future<void> updateOrgChart(OrgChart chart);
  Future<void> deleteOrgChart(String chartId);
  Future<int> getOrgChartCount();
  Future<OrgChart?> getLatestOrgChart();
  Future<List<OrgChart>> getRecentOrgCharts(Duration duration);
}

// ============================================================================
// In-Memory Repository Implementation
// ============================================================================

class InMemoryHRRepository implements HRRepository {
  final Map<String, Employee> _employees = {};
  final Map<String, Department> _departments = {};
  final Map<String, Compensation> _compensations = {};
  final Map<String, Recruitment> _recruitments = {};
  final Map<String, LeaveRequest> _leaves = {};
  final Map<String, PerformanceReview> _reviews = {};
  final Map<String, Training> _trainings = {};
  final Map<String, Payroll> _payrolls = {};
  final Map<String, Attendance> _attendances = {};
  final Map<String, OrgChart> _orgCharts = {};

  // Employee Methods
  @override
  Future<void> createEmployee(Employee employee) async {
    _employees[employee.employeeId] = employee;
  }

  @override
  Future<Employee?> getEmployee(String employeeId) async {
    return _employees[employeeId];
  }

  @override
  Future<List<Employee>> getAllEmployees() async {
    return _employees.values.toList();
  }

  @override
  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    return _employees.values
        .where((e) => e.department == department)
        .toList();
  }

  @override
  Future<List<Employee>> getActiveEmployees() async {
    return _employees.values.where((e) => e.isActive).toList();
  }

  @override
  Future<List<Employee>> getEmployeesByStatus(EmploymentStatus status) async {
    return _employees.values.where((e) => e.status == status).toList();
  }

  @override
  Future<List<Employee>> getEmployeesByManager(String managerId) async {
    return _employees.values
        .where((e) => e.managerId == managerId)
        .toList();
  }

  @override
  Future<void> updateEmployee(Employee employee) async {
    _employees[employee.employeeId] = employee;
  }

  @override
  Future<void> deleteEmployee(String employeeId) async {
    _employees.remove(employeeId);
  }

  @override
  Future<int> getEmployeeCount() async {
    return _employees.length;
  }

  @override
  Future<List<Employee>> getRecentHires(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _employees.values
        .where((e) => e.hireDate.isAfter(threshold))
        .toList();
  }

  @override
  Future<double> getAverageSalary() async {
    if (_employees.isEmpty) return 0;
    final sum = _employees.values.fold<double>(0, (sum, e) => sum + e.salary);
    return sum / _employees.length;
  }

  // Department Methods
  @override
  Future<void> createDepartment(Department department) async {
    _departments[department.departmentId] = department;
  }

  @override
  Future<Department?> getDepartment(String departmentId) async {
    return _departments[departmentId];
  }

  @override
  Future<List<Department>> getAllDepartments() async {
    return _departments.values.toList();
  }

  @override
  Future<List<Department>> getDepartmentsByType(DepartmentType type) async {
    return _departments.values
        .where((d) => d.departmentType == type)
        .toList();
  }

  @override
  Future<Department?> getDepartmentByManager(String managerId) async {
    try {
      return _departments.values.firstWhere((d) => d.managerId == managerId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateDepartment(Department department) async {
    _departments[department.departmentId] = department;
  }

  @override
  Future<void> deleteDepartment(String departmentId) async {
    _departments.remove(departmentId);
  }

  @override
  Future<int> getDepartmentCount() async {
    return _departments.length;
  }

  @override
  Future<double> getTotalDepartmentBudget() async {
    return _departments.values
        .fold<double>(0, (sum, d) => sum + d.budgetAllocation);
  }

  @override
  Future<List<Department>> getDepartmentsByHeadcount(int minEmployees) async {
    return _departments.values
        .where((d) => d.headcount >= minEmployees)
        .toList();
  }

  @override
  Future<Map<String, List<String>>> getDepartmentEmployeeMapping() async {
    final mapping = <String, List<String>>{};
    for (final dept in _departments.values) {
      mapping[dept.departmentId] = dept.employeeIds;
    }
    return mapping;
  }

  @override
  Future<List<Department>> getLargestDepartments() async {
    final sorted = _departments.values.toList();
    sorted.sort((a, b) => b.headcount.compareTo(a.headcount));
    return sorted;
  }

  // Compensation Methods
  @override
  Future<void> createCompensation(Compensation compensation) async {
    _compensations[compensation.compensationId] = compensation;
  }

  @override
  Future<Compensation?> getCompensation(String compensationId) async {
    return _compensations[compensationId];
  }

  @override
  Future<Compensation?> getLatestCompensationForEmployee(
      String employeeId) async {
    final comps = _compensations.values
        .where((c) => c.employeeId == employeeId)
        .toList();
    if (comps.isEmpty) return null;
    comps.sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
    return comps.first;
  }

  @override
  Future<List<Compensation>> getCompensationsForEmployee(String employeeId) async {
    return _compensations.values
        .where((c) => c.employeeId == employeeId)
        .toList();
  }

  @override
  Future<List<Compensation>> getRecentCompensationChanges(
      Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _compensations.values
        .where((c) => c.effectiveDate.isAfter(threshold))
        .toList();
  }

  @override
  Future<void> updateCompensation(Compensation compensation) async {
    _compensations[compensation.compensationId] = compensation;
  }

  @override
  Future<void> deleteCompensation(String compensationId) async {
    _compensations.remove(compensationId);
  }

  @override
  Future<int> getCompensationCount() async {
    return _compensations.length;
  }

  @override
  Future<double> getTotalCompensationAmount() async {
    return _compensations.values
        .fold<double>(0, (sum, c) => sum + c.totalCompensation);
  }

  @override
  Future<double> getAverageBonus() async {
    if (_compensations.isEmpty) return 0;
    final sum = _compensations.values.fold<double>(0, (sum, c) => sum + c.bonus);
    return sum / _compensations.length;
  }

  // Recruitment Methods
  @override
  Future<void> createRecruitment(Recruitment recruitment) async {
    _recruitments[recruitment.recruitmentId] = recruitment;
  }

  @override
  Future<Recruitment?> getRecruitment(String recruitmentId) async {
    return _recruitments[recruitmentId];
  }

  @override
  Future<List<Recruitment>> getAllRecruitments() async {
    return _recruitments.values.toList();
  }

  @override
  Future<List<Recruitment>> getOpenPositions() async {
    return _recruitments.values.where((r) => r.isOpen).toList();
  }

  @override
  Future<List<Recruitment>> getRecruitmentsByDepartment(
      String departmentId) async {
    return _recruitments.values
        .where((r) => r.departmentId == departmentId)
        .toList();
  }

  @override
  Future<List<Recruitment>> getRecruitmentsByStatus(
      RecruitmentStatus status) async {
    return _recruitments.values.where((r) => r.status == status).toList();
  }

  @override
  Future<List<Recruitment>> getRecruitmentsByType(DepartmentType type) async {
    return _recruitments.values
        .where((r) => r.departmentType == type)
        .toList();
  }

  @override
  Future<void> updateRecruitment(Recruitment recruitment) async {
    _recruitments[recruitment.recruitmentId] = recruitment;
  }

  @override
  Future<void> deleteRecruitment(String recruitmentId) async {
    _recruitments.remove(recruitmentId);
  }

  @override
  Future<int> getRecruitmentCount() async {
    return _recruitments.length;
  }

  @override
  Future<int> getTotalPositionsOpen() async {
    return _recruitments.values.fold<int>(0, (sum, r) => sum + r.positionsRemaining);
  }

  @override
  Future<double> getAverageTimeToFill() async {
    final recruitments = _recruitments.values.toList();
    if (recruitments.isEmpty) return 0;
    final sum = recruitments.fold<int>(0, (sum, r) => sum + r.ageInDays);
    return sum / recruitments.length;
  }

  // Leave Methods
  @override
  Future<void> createLeaveRequest(LeaveRequest leave) async {
    _leaves[leave.leaveId] = leave;
  }

  @override
  Future<LeaveRequest?> getLeaveRequest(String leaveId) async {
    return _leaves[leaveId];
  }

  @override
  Future<List<LeaveRequest>> getLeaveRequestsForEmployee(String employeeId) async {
    return _leaves.values
        .where((l) => l.employeeId == employeeId)
        .toList();
  }

  @override
  Future<List<LeaveRequest>> getApprovedLeaves() async {
    return _leaves.values.where((l) => l.isApproved).toList();
  }

  @override
  Future<List<LeaveRequest>> getPendingLeaves() async {
    return _leaves.values.where((l) => l.isPending).toList();
  }

  @override
  Future<List<LeaveRequest>> getLeavesByType(LeaveType type) async {
    return _leaves.values.where((l) => l.leaveType == type).toList();
  }

  @override
  Future<void> updateLeaveRequest(LeaveRequest leave) async {
    _leaves[leave.leaveId] = leave;
  }

  @override
  Future<void> deleteLeaveRequest(String leaveId) async {
    _leaves.remove(leaveId);
  }

  @override
  Future<int> getLeaveRequestCount() async {
    return _leaves.length;
  }

  @override
  Future<List<LeaveRequest>> getOngoingLeaves() async {
    return _leaves.values.where((l) => l.isOngoing).toList();
  }

  // Performance Review Methods
  @override
  Future<void> createPerformanceReview(PerformanceReview review) async {
    _reviews[review.reviewId] = review;
  }

  @override
  Future<PerformanceReview?> getPerformanceReview(String reviewId) async {
    return _reviews[reviewId];
  }

  @override
  Future<List<PerformanceReview>> getReviewsForEmployee(String employeeId) async {
    return _reviews.values
        .where((r) => r.employeeId == employeeId)
        .toList();
  }

  @override
  Future<List<PerformanceReview>> getReviewsByRating(PerformanceRating rating) async {
    return _reviews.values.where((r) => r.rating == rating).toList();
  }

  @override
  Future<List<PerformanceReview>> getRecentReviews(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _reviews.values
        .where((r) => r.reviewDate.isAfter(threshold))
        .toList();
  }

  @override
  Future<void> updatePerformanceReview(PerformanceReview review) async {
    _reviews[review.reviewId] = review;
  }

  @override
  Future<void> deletePerformanceReview(String reviewId) async {
    _reviews.remove(reviewId);
  }

  @override
  Future<int> getPerformanceReviewCount() async {
    return _reviews.length;
  }

  @override
  Future<double> getAveragePerformanceScore() async {
    if (_reviews.isEmpty) return 0;
    final ratingValues = <double>[
      for (final review in _reviews.values)
        if (review.rating == PerformanceRating.exceptional) 5.0
        else if (review.rating == PerformanceRating.exceeds) 4.0
        else if (review.rating == PerformanceRating.meets) 3.0
        else if (review.rating == PerformanceRating.needsImprovement) 2.0
        else 1.0
    ];
    if (ratingValues.isEmpty) return 0;
    final sum = ratingValues.fold<double>(0, (sum, val) => sum + val);
    return sum / ratingValues.length;
  }

  @override
  Future<List<PerformanceReview>> getNeedsImprovementReviews() async {
    return _reviews.values.where((r) => r.needsImprovement).toList();
  }

  // Training Methods
  @override
  Future<void> createTraining(Training training) async {
    _trainings[training.trainingId] = training;
  }

  @override
  Future<Training?> getTraining(String trainingId) async {
    return _trainings[trainingId];
  }

  @override
  Future<List<Training>> getTrainingsForEmployee(String employeeId) async {
    return _trainings.values
        .where((t) => t.employeeId == employeeId)
        .toList();
  }

  @override
  Future<List<Training>> getCompletedTrainings() async {
    return _trainings.values.where((t) => t.isCompleted).toList();
  }

  @override
  Future<List<Training>> getOngoingTrainings() async {
    return _trainings.values.where((t) => t.isOngoing).toList();
  }

  @override
  Future<List<Training>> getTrainingsByStatus(TrainingStatus status) async {
    return _trainings.values.where((t) => t.status == status).toList();
  }

  @override
  Future<void> updateTraining(Training training) async {
    _trainings[training.trainingId] = training;
  }

  @override
  Future<void> deleteTraining(String trainingId) async {
    _trainings.remove(trainingId);
  }

  @override
  Future<int> getTrainingCount() async {
    return _trainings.length;
  }

  @override
  Future<double> getTotalTrainingCost() async {
    return _trainings.values.fold<double>(0, (sum, t) => sum + t.cost);
  }

  // Payroll Methods
  @override
  Future<void> createPayroll(Payroll payroll) async {
    _payrolls[payroll.payrollId] = payroll;
  }

  @override
  Future<Payroll?> getPayroll(String payrollId) async {
    return _payrolls[payrollId];
  }

  @override
  Future<List<Payroll>> getPayrollsForEmployee(String employeeId) async {
    return _payrolls.values
        .where((p) => p.employeeId == employeeId)
        .toList();
  }

  @override
  Future<List<Payroll>> getPayrollsByPeriod(DateTime startDate, DateTime endDate) async {
    return _payrolls.values
        .where((p) =>
            p.paymentDate.isAfter(startDate) &&
            p.paymentDate.isBefore(endDate))
        .toList();
  }

  @override
  Future<List<Payroll>> getUnpaidPayrolls() async {
    return _payrolls.values.where((p) => !p.isPaid).toList();
  }

  @override
  Future<void> updatePayroll(Payroll payroll) async {
    _payrolls[payroll.payrollId] = payroll;
  }

  @override
  Future<void> deletePayroll(String payrollId) async {
    _payrolls.remove(payrollId);
  }

  @override
  Future<int> getPayrollCount() async {
    return _payrolls.length;
  }

  @override
  Future<double> getTotalPayrollAmount() async {
    return _payrolls.values.fold<double>(0, (sum, p) => sum + p.netPay);
  }

  @override
  Future<List<Payroll>> getRecentPayrolls(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _payrolls.values
        .where((p) => p.paymentDate.isAfter(threshold))
        .toList();
  }

  // Attendance Methods
  @override
  Future<void> createAttendance(Attendance attendance) async {
    _attendances[attendance.attendanceId] = attendance;
  }

  @override
  Future<Attendance?> getAttendance(String attendanceId) async {
    return _attendances[attendanceId];
  }

  @override
  Future<List<Attendance>> getAttendanceForEmployee(String employeeId) async {
    return _attendances.values
        .where((a) => a.employeeId == employeeId)
        .toList();
  }

  @override
  Future<List<Attendance>> getAttendanceByDate(DateTime date) async {
    return _attendances.values
        .where((a) => a.date.day == date.day &&
            a.date.month == date.month &&
            a.date.year == date.year)
        .toList();
  }

  @override
  Future<List<Attendance>> getAbsentEmployees(DateTime date) async {
    return _attendances.values
        .where((a) => a.isAbsent &&
            a.date.day == date.day &&
            a.date.month == date.month &&
            a.date.year == date.year)
        .toList();
  }

  @override
  Future<List<Attendance>> getRecentAttendance(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _attendances.values
        .where((a) => a.date.isAfter(threshold))
        .toList();
  }

  @override
  Future<void> updateAttendance(Attendance attendance) async {
    _attendances[attendance.attendanceId] = attendance;
  }

  @override
  Future<void> deleteAttendance(String attendanceId) async {
    _attendances.remove(attendanceId);
  }

  @override
  Future<int> getAttendanceRecordCount() async {
    return _attendances.length;
  }

  @override
  Future<double> getAverageAttendanceRate() async {
    if (_attendances.isEmpty) return 0;
    final present = _attendances.values.where((a) => a.isPresent).length;
    return (present / _attendances.length) * 100;
  }

  // Org Chart Methods
  @override
  Future<void> createOrgChart(OrgChart chart) async {
    _orgCharts[chart.chartId] = chart;
  }

  @override
  Future<OrgChart?> getOrgChart(String chartId) async {
    return _orgCharts[chartId];
  }

  @override
  Future<List<OrgChart>> getAllOrgCharts() async {
    return _orgCharts.values.toList();
  }

  @override
  Future<void> updateOrgChart(OrgChart chart) async {
    _orgCharts[chart.chartId] = chart;
  }

  @override
  Future<void> deleteOrgChart(String chartId) async {
    _orgCharts.remove(chartId);
  }

  @override
  Future<int> getOrgChartCount() async {
    return _orgCharts.length;
  }

  @override
  Future<OrgChart?> getLatestOrgChart() async {
    if (_orgCharts.isEmpty) return null;
    var latest = _orgCharts.values.first;
    for (final chart in _orgCharts.values) {
      if (chart.lastUpdatedDate.isAfter(latest.lastUpdatedDate)) {
        latest = chart;
      }
    }
    return latest;
  }

  @override
  Future<List<OrgChart>> getRecentOrgCharts(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _orgCharts.values
        .where((c) => c.lastUpdatedDate.isAfter(threshold))
        .toList();
  }
}

// ============================================================================
// Specialized Engines
// ============================================================================

class TalentAcquisitionEngine {
  final HRRepository repository;

  TalentAcquisitionEngine(this.repository);

  Future<List<Recruitment>> getActiveRecruitments() async {
    return await repository.getOpenPositions();
  }

  Future<int> getTotalOpenings() async {
    return await repository.getTotalPositionsOpen();
  }

  Future<Map<DepartmentType, int>> getOpeningsByDepartment() async {
    final recruitments = await repository.getAllRecruitments();
    final openings = <DepartmentType, int>{};
    for (final rec in recruitments) {
      if (rec.isOpen) {
        openings[rec.departmentType] = (openings[rec.departmentType] ?? 0) + rec.positionsRemaining;
      }
    }
    return openings;
  }

  Future<void> updateRecruitmentProgress(String recruitmentId, int newApplicants) async {
    final rec = await repository.getRecruitment(recruitmentId);
    if (rec != null) {
      final updated = rec.copyWith(applicantsReceived: newApplicants);
      await repository.updateRecruitment(updated);
    }
  }
}

class EmployeeManagementEngine {
  final HRRepository repository;

  EmployeeManagementEngine(this.repository);

  Future<int> getActiveEmployeeCount() async {
    final active = await repository.getActiveEmployees();
    return active.length;
  }

  Future<Map<DepartmentType, int>> getEmployeesByDepartmentType() async {
    final allDepts = await repository.getAllDepartments();
    final distribution = <DepartmentType, int>{};
    for (final dept in allDepts) {
      distribution[dept.departmentType] = (distribution[dept.departmentType] ?? 0) + dept.headcount;
    }
    return distribution;
  }

  Future<double> getCompanyAverageSalary() async {
    return await repository.getAverageSalary();
  }

  Future<List<Employee>> getEmployeesNeedingReview() async {
    final reviews = await repository.getAllRecruitments();
    // Return employees without recent reviews
    return await repository.getActiveEmployees();
  }
}

class CompensationEngine {
  final HRRepository repository;

  CompensationEngine(this.repository);

  Future<double> getTotalCompensationLiability() async {
    return await repository.getTotalCompensationAmount();
  }

  Future<Map<String, double>> getCompensationBreakdown() async {
    final comps = await repository.getCompensationsForEmployee('all');
    return {
      'baseSalary': 0,
      'bonus': await repository.getAverageBonus(),
      'benefits': 0,
    };
  }

  Future<void> adjustCompensation(String employeeId, double newSalary) async {
    final latest = await repository.getLatestCompensationForEmployee(employeeId);
    if (latest != null) {
      final updated = latest.copyWith(baseSalary: newSalary);
      await repository.updateCompensation(updated);
    }
  }

  Future<List<Compensation>> getRecentAdjustments() async {
    return await repository.getRecentCompensationChanges(Duration(days: 30));
  }
}

class PerformanceEngine {
  final HRRepository repository;

  PerformanceEngine(this.repository);

  Future<double> getAveragePerformanceScore() async {
    return await repository.getAveragePerformanceScore();
  }

  Future<Map<PerformanceRating, int>> getPerformanceDistribution() async {
    final reviews = await repository.getAllRecruitments();
    final distribution = <PerformanceRating, int>{};
    return distribution;
  }

  Future<List<PerformanceReview>> getHighPerformers() async {
    final reviews = await repository.getReviewsByRating(PerformanceRating.exceptional);
    return reviews;
  }

  Future<List<PerformanceReview>> getNeedingImprovementReviews() async {
    return await repository.getNeedsImprovementReviews();
  }
}

class DevelopmentEngine {
  final HRRepository repository;

  DevelopmentEngine(this.repository);

  Future<double> getTotalTrainingInvestment() async {
    return await repository.getTotalTrainingCost();
  }

  Future<int> getCompletedTrainingCount() async {
    final trainings = await repository.getCompletedTrainings();
    return trainings.length;
  }

  Future<Map<String, int>> getTrainingsByProvider() async {
    final allTrainings = await repository.getCompletedTrainings();
    final byProvider = <String, int>{};
    for (final training in allTrainings) {
      if (training.provider != null) {
        byProvider[training.provider!] = (byProvider[training.provider!] ?? 0) + 1;
      }
    }
    return byProvider;
  }

  Future<void> enrollEmployeeInTraining(String employeeId, Training training) async {
    await repository.createTraining(training);
  }
}

// ============================================================================
// Manager
// ============================================================================

class HRManager {
  final HRRepository repository;
  late final TalentAcquisitionEngine acquisitionEngine;
  late final EmployeeManagementEngine employeeEngine;
  late final CompensationEngine compensationEngine;
  late final PerformanceEngine performanceEngine;
  late final DevelopmentEngine developmentEngine;

  HRManager(this.repository) {
    acquisitionEngine = TalentAcquisitionEngine(repository);
    employeeEngine = EmployeeManagementEngine(repository);
    compensationEngine = CompensationEngine(repository);
    performanceEngine = PerformanceEngine(repository);
    developmentEngine = DevelopmentEngine(repository);
  }

  Future<Map<String, dynamic>> generateHRDashboard() async {
    return {
      'activeEmployees': await employeeEngine.getActiveEmployeeCount(),
      'openPositions': await acquisitionEngine.getTotalOpenings(),
      'averageSalary': await employeeEngine.getCompanyAverageSalary(),
      'performanceScore': await performanceEngine.getAveragePerformanceScore(),
      'trainingInvestment': await developmentEngine.getTotalTrainingInvestment(),
      'totalCompensation': await compensationEngine.getTotalCompensationLiability(),
    };
  }
}

// ============================================================================
// Facade
// ============================================================================

class HRFacade {
  final HRManager manager;

  HRFacade(HRRepository repository) : manager = HRManager(repository);

  // Employee Management
  Future<void> hireEmployee(Employee employee) =>
      manager.repository.createEmployee(employee);

  Future<Employee?> getEmployee(String employeeId) =>
      manager.repository.getEmployee(employeeId);

  Future<List<Employee>> getActiveEmployees() =>
      manager.repository.getActiveEmployees();

  Future<int> getEmployeeCount() => manager.employeeEngine.getActiveEmployeeCount();

  // Department Management
  Future<void> createDepartment(Department department) =>
      manager.repository.createDepartment(department);

  Future<List<Department>> getAllDepartments() =>
      manager.repository.getAllDepartments();

  // Recruitment
  Future<void> postPosition(Recruitment recruitment) =>
      manager.repository.createRecruitment(recruitment);

  Future<List<Recruitment>> getOpenPositions() =>
      manager.acquisitionEngine.getActiveRecruitments();

  Future<int> getOpeningCount() =>
      manager.acquisitionEngine.getTotalOpenings();

  // Compensation
  Future<void> setCompensation(Compensation compensation) =>
      manager.repository.createCompensation(compensation);

  Future<double> getTotalCompensationLiability() =>
      manager.compensationEngine.getTotalCompensationLiability();

  // Performance
  Future<void> submitPerformanceReview(PerformanceReview review) =>
      manager.repository.createPerformanceReview(review);

  Future<double> getPerformanceScore() =>
      manager.performanceEngine.getAveragePerformanceScore();

  // Training & Development
  Future<void> enrollTraining(Training training) =>
      manager.repository.createTraining(training);

  Future<double> getTrainingInvestment() =>
      manager.developmentEngine.getTotalTrainingInvestment();

  // Leave Management
  Future<void> requestLeave(LeaveRequest leave) =>
      manager.repository.createLeaveRequest(leave);

  Future<List<LeaveRequest>> getPendingLeaves() =>
      manager.repository.getPendingLeaves();

  // Payroll
  Future<void> processPayroll(Payroll payroll) =>
      manager.repository.createPayroll(payroll);

  Future<int> getPayrollCount() =>
      manager.repository.getPayrollCount();

  // Attendance
  Future<void> recordAttendance(Attendance attendance) =>
      manager.repository.createAttendance(attendance);

  Future<double> getAttendanceRate() =>
      manager.repository.getAverageAttendanceRate();

  // Dashboard
  Future<Map<String, dynamic>> getHRDashboard() =>
      manager.generateHRDashboard();
}
