/// Comprehensive test suite for Phase 97: Advanced Human Resources & Talent Management
/// Tests all models, enums, repository operations, engines, managers, and facades

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/hr_models.dart';
import 'package:project_040/services/hr_service.dart';

void main() {
  group('Phase 97: Human Resources & Talent Management Tests', () {
    late HRFacade facade;
    late HRRepository repository;

    setUp(() {
      repository = InMemoryHRRepository();
      facade = HRFacade(repository);
    });

    // ========================================================================
    // Enum Tests (6 enums)
    // ========================================================================

    group('Enum Tests', () {
      test('EmploymentStatus has all values', () {
        expect(EmploymentStatus.values.length, 6);
        expect(EmploymentStatus.values, contains(EmploymentStatus.active));
        expect(EmploymentStatus.values, contains(EmploymentStatus.terminated));
      });

      test('EmploymentStatus display names', () {
        expect(EmploymentStatus.active.displayName, 'Active (在職)');
        expect(EmploymentStatus.onLeave.displayName, 'On Leave (休暇中)');
      });

      test('DepartmentType has all values', () {
        expect(DepartmentType.values.length, 8);
        expect(DepartmentType.values, contains(DepartmentType.engineering));
        expect(DepartmentType.values, contains(DepartmentType.humanResources));
      });

      test('RecruitmentStatus has all values', () {
        expect(RecruitmentStatus.values.length, 8);
        expect(RecruitmentStatus.values, contains(RecruitmentStatus.planning));
        expect(RecruitmentStatus.values, contains(RecruitmentStatus.hired));
      });

      test('LeaveType has all values', () {
        expect(LeaveType.values.length, 7);
        expect(LeaveType.values, contains(LeaveType.annual));
        expect(LeaveType.values, contains(LeaveType.sabbatical));
      });

      test('PerformanceRating has all values', () {
        expect(PerformanceRating.values.length, 5);
        expect(PerformanceRating.values, contains(PerformanceRating.exceptional));
        expect(PerformanceRating.values, contains(PerformanceRating.unsatisfactory));
      });

      test('TrainingStatus has all values', () {
        expect(TrainingStatus.values.length, 6);
        expect(TrainingStatus.values, contains(TrainingStatus.planned));
        expect(TrainingStatus.values, contains(TrainingStatus.certified));
      });
    });

    // ========================================================================
    // Model Tests (10 models)
    // ========================================================================

    group('Model Tests', () {
      test('Employee properties', () {
        final emp = Employee(
          employeeId: 'emp_001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          department: 'Engineering',
          departmentType: DepartmentType.engineering,
          jobTitle: 'Software Engineer',
          salary: 100000,
          status: EmploymentStatus.active,
          hireDate: DateTime(2020, 1, 1),
        );
        expect(emp.fullName, 'John Doe');
        expect(emp.isActive, true);
        expect(emp.tenureInYears, greaterThan(0));
      });

      test('Department properties', () {
        final dept = Department(
          departmentId: 'dept_001',
          departmentName: 'Engineering',
          departmentType: DepartmentType.engineering,
          managerId: 'emp_001',
          budgetAllocation: 500000,
          employeeIds: ['emp_001', 'emp_002', 'emp_003'],
          createdDate: DateTime.now(),
        );
        expect(dept.headcount, 3);
        expect(dept.isBudgetAllocated, true);
        expect(dept.avgBudgetPerEmployee, greaterThan(0));
      });

      test('Compensation properties', () {
        final comp = Compensation(
          compensationId: 'comp_001',
          employeeId: 'emp_001',
          baseSalary: 100000,
          bonus: 20000,
          benefits: 10000,
          stocks: 5000,
          effectiveDate: DateTime.now(),
        );
        expect(comp.totalCompensation, 135000);
        expect(comp.percentageBonus, 20);
        expect(comp.isRecent, true);
      });

      test('Recruitment properties', () {
        final rec = Recruitment(
          recruitmentId: 'rec_001',
          positionTitle: 'Engineer',
          departmentId: 'dept_001',
          departmentType: DepartmentType.engineering,
          status: RecruitmentStatus.openings,
          targetHires: 5,
          applicantsReceived: 30,
          openDate: DateTime.now(),
        );
        expect(rec.isOpen, true);
        expect(rec.positionsFilled, 5);
        expect(rec.positionsRemaining, 0);
      });

      test('LeaveRequest properties', () {
        final leave = LeaveRequest(
          leaveId: 'leave_001',
          employeeId: 'emp_001',
          leaveType: LeaveType.annual,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 5)),
          isApproved: true,
        );
        expect(leave.durationDays, 6);
        expect(leave.isUpcoming, false);
        expect(leave.isPending, false);
      });

      test('PerformanceReview properties', () {
        final review = PerformanceReview(
          reviewId: 'rev_001',
          employeeId: 'emp_001',
          reviewerId: 'mgr_001',
          rating: PerformanceRating.exceeds,
          strengths: 'Good communication',
          areasForImprovement: 'Time management',
          goals: 'Lead project',
          reviewDate: DateTime.now(),
        );
        expect(review.isPositive, true);
        expect(review.needsImprovement, false);
      });

      test('Training properties', () {
        final training = Training(
          trainingId: 'train_001',
          employeeId: 'emp_001',
          trainingName: 'Leadership',
          status: TrainingStatus.inProgress,
          startDate: DateTime.now().subtract(Duration(days: 7)),
          cost: 5000,
          provider: 'Udemy',
        );
        expect(training.isOngoing, true);
        expect(training.isCompleted, false);
      });

      test('Payroll properties', () {
        final payroll = Payroll(
          payrollId: 'pay_001',
          employeeId: 'emp_001',
          grossSalary: 10000,
          taxes: 2000,
          deductions: 500,
          netPay: 7500,
          payPeriodStart: DateTime.now().subtract(Duration(days: 14)),
          payPeriodEnd: DateTime.now(),
          paymentDate: DateTime.now(),
        );
        expect(payroll.totalDeductions, 2500);
        expect(payroll.effectiveTaxRate, 20);
      });

      test('Attendance properties', () {
        final att = Attendance(
          attendanceId: 'att_001',
          employeeId: 'emp_001',
          date: DateTime.now(),
          checkInTime: DateTime.now(),
          checkOutTime: DateTime.now().add(Duration(hours: 8)),
        );
        expect(att.isPresent, true);
        expect(att.hoursWorked, 8);
      });

      test('OrgChart properties', () {
        final chart = OrgChart(
          chartId: 'chart_001',
          organizationName: 'Tech Corp',
          managerReports: {'mgr_001': 'emp_001', 'mgr_002': 'emp_002'},
          departmentIds: ['dept_001', 'dept_002'],
          lastUpdatedDate: DateTime.now(),
        );
        expect(chart.totalDepartments, 2);
        expect(chart.totalManagers, 2);
        expect(chart.isRecent, true);
      });
    });

    // ========================================================================
    // Repository Tests
    // ========================================================================

    group('Repository Tests - Employees', () {
      test('Create and retrieve employee', () async {
        final emp = Employee(
          employeeId: 'emp_001',
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane@example.com',
          department: 'Sales',
          departmentType: DepartmentType.sales,
          jobTitle: 'Sales Manager',
          salary: 80000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        await repository.createEmployee(emp);
        final retrieved = await repository.getEmployee('emp_001');
        expect(retrieved?.firstName, 'Jane');
      });

      test('Get active employees', () async {
        final emp = Employee(
          employeeId: 'emp_001',
          firstName: 'Active',
          lastName: 'Employee',
          email: 'active@example.com',
          department: 'Engineering',
          departmentType: DepartmentType.engineering,
          jobTitle: 'Engineer',
          salary: 100000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        await repository.createEmployee(emp);
        final active = await repository.getActiveEmployees();
        expect(active.length, greaterThan(0));
      });

      test('Get average salary', () async {
        final emp1 = Employee(
          employeeId: 'emp_001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          department: 'Engineering',
          departmentType: DepartmentType.engineering,
          jobTitle: 'Engineer',
          salary: 100000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        final emp2 = Employee(
          employeeId: 'emp_002',
          firstName: 'Jane',
          lastName: 'Doe',
          email: 'jane@example.com',
          department: 'Sales',
          departmentType: DepartmentType.sales,
          jobTitle: 'Manager',
          salary: 80000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        await repository.createEmployee(emp1);
        await repository.createEmployee(emp2);
        final avg = await repository.getAverageSalary();
        expect(avg, 90000);
      });
    });

    group('Repository Tests - Departments', () {
      test('Create and retrieve department', () async {
        final dept = Department(
          departmentId: 'dept_001',
          departmentName: 'Engineering',
          departmentType: DepartmentType.engineering,
          managerId: 'emp_001',
          budgetAllocation: 500000,
          employeeIds: ['emp_001'],
          createdDate: DateTime.now(),
        );
        await repository.createDepartment(dept);
        final retrieved = await repository.getDepartment('dept_001');
        expect(retrieved?.departmentName, 'Engineering');
      });

      test('Get departments by type', () async {
        final dept = Department(
          departmentId: 'dept_001',
          departmentName: 'Sales',
          departmentType: DepartmentType.sales,
          managerId: 'emp_001',
          budgetAllocation: 300000,
          employeeIds: [],
          createdDate: DateTime.now(),
        );
        await repository.createDepartment(dept);
        final sales = await repository.getDepartmentsByType(DepartmentType.sales);
        expect(sales.length, greaterThan(0));
      });

      test('Get total department budget', () async {
        final dept1 = Department(
          departmentId: 'dept_001',
          departmentName: 'Engineering',
          departmentType: DepartmentType.engineering,
          managerId: 'emp_001',
          budgetAllocation: 500000,
          employeeIds: [],
          createdDate: DateTime.now(),
        );
        final dept2 = Department(
          departmentId: 'dept_002',
          departmentName: 'Sales',
          departmentType: DepartmentType.sales,
          managerId: 'emp_002',
          budgetAllocation: 300000,
          employeeIds: [],
          createdDate: DateTime.now(),
        );
        await repository.createDepartment(dept1);
        await repository.createDepartment(dept2);
        final total = await repository.getTotalDepartmentBudget();
        expect(total, 800000);
      });
    });

    group('Repository Tests - Recruitment', () {
      test('Create and retrieve recruitment', () async {
        final rec = Recruitment(
          recruitmentId: 'rec_001',
          positionTitle: 'Engineer',
          departmentId: 'dept_001',
          departmentType: DepartmentType.engineering,
          status: RecruitmentStatus.openings,
          targetHires: 5,
          applicantsReceived: 20,
          openDate: DateTime.now(),
        );
        await repository.createRecruitment(rec);
        final retrieved = await repository.getRecruitment('rec_001');
        expect(retrieved?.positionTitle, 'Engineer');
      });

      test('Get open positions', () async {
        final rec = Recruitment(
          recruitmentId: 'rec_001',
          positionTitle: 'Manager',
          departmentId: 'dept_001',
          departmentType: DepartmentType.sales,
          status: RecruitmentStatus.openings,
          targetHires: 2,
          applicantsReceived: 10,
          openDate: DateTime.now(),
        );
        await repository.createRecruitment(rec);
        final open = await repository.getOpenPositions();
        expect(open.length, greaterThan(0));
      });

      test('Get total open positions', () async {
        final rec1 = Recruitment(
          recruitmentId: 'rec_001',
          positionTitle: 'Engineer',
          departmentId: 'dept_001',
          departmentType: DepartmentType.engineering,
          status: RecruitmentStatus.openings,
          targetHires: 5,
          applicantsReceived: 20,
          openDate: DateTime.now(),
        );
        final rec2 = Recruitment(
          recruitmentId: 'rec_002',
          positionTitle: 'Manager',
          departmentId: 'dept_002',
          departmentType: DepartmentType.sales,
          status: RecruitmentStatus.openings,
          targetHires: 3,
          applicantsReceived: 15,
          openDate: DateTime.now(),
        );
        await repository.createRecruitment(rec1);
        await repository.createRecruitment(rec2);
        final total = await repository.getTotalPositionsOpen();
        expect(total, greaterThan(0));
      });
    });

    group('Repository Tests - Compensation', () {
      test('Create and retrieve compensation', () async {
        final comp = Compensation(
          compensationId: 'comp_001',
          employeeId: 'emp_001',
          baseSalary: 100000,
          bonus: 20000,
          benefits: 10000,
          stocks: 5000,
          effectiveDate: DateTime.now(),
        );
        await repository.createCompensation(comp);
        final retrieved = await repository.getCompensation('comp_001');
        expect(retrieved?.baseSalary, 100000);
      });

      test('Get total compensation amount', () async {
        final comp1 = Compensation(
          compensationId: 'comp_001',
          employeeId: 'emp_001',
          baseSalary: 100000,
          bonus: 20000,
          benefits: 10000,
          stocks: 5000,
          effectiveDate: DateTime.now(),
        );
        final comp2 = Compensation(
          compensationId: 'comp_002',
          employeeId: 'emp_002',
          baseSalary: 80000,
          bonus: 15000,
          benefits: 8000,
          stocks: 3000,
          effectiveDate: DateTime.now(),
        );
        await repository.createCompensation(comp1);
        await repository.createCompensation(comp2);
        final total = await repository.getTotalCompensationAmount();
        expect(total, greaterThan(200000));
      });
    });

    group('Repository Tests - Performance Reviews', () {
      test('Create and retrieve review', () async {
        final review = PerformanceReview(
          reviewId: 'rev_001',
          employeeId: 'emp_001',
          reviewerId: 'mgr_001',
          rating: PerformanceRating.exceeds,
          strengths: 'Good work',
          areasForImprovement: 'Communication',
          goals: 'Lead team',
          reviewDate: DateTime.now(),
        );
        await repository.createPerformanceReview(review);
        final retrieved = await repository.getPerformanceReview('rev_001');
        expect(retrieved?.rating, PerformanceRating.exceeds);
      });

      test('Get needs improvement reviews', () async {
        final review = PerformanceReview(
          reviewId: 'rev_001',
          employeeId: 'emp_001',
          reviewerId: 'mgr_001',
          rating: PerformanceRating.needsImprovement,
          strengths: 'Potential',
          areasForImprovement: 'Performance',
          goals: 'Improve metrics',
          reviewDate: DateTime.now(),
        );
        await repository.createPerformanceReview(review);
        final needsImp = await repository.getNeedsImprovementReviews();
        expect(needsImp.length, greaterThan(0));
      });
    });

    group('Repository Tests - Training', () {
      test('Create and retrieve training', () async {
        final training = Training(
          trainingId: 'train_001',
          employeeId: 'emp_001',
          trainingName: 'Leadership',
          status: TrainingStatus.completed,
          startDate: DateTime.now().subtract(Duration(days: 30)),
          completionDate: DateTime.now(),
          cost: 5000,
        );
        await repository.createTraining(training);
        final retrieved = await repository.getTraining('train_001');
        expect(retrieved?.trainingName, 'Leadership');
      });

      test('Get total training cost', () async {
        final train1 = Training(
          trainingId: 'train_001',
          employeeId: 'emp_001',
          trainingName: 'Leadership',
          status: TrainingStatus.completed,
          startDate: DateTime.now().subtract(Duration(days: 30)),
          completionDate: DateTime.now(),
          cost: 5000,
        );
        final train2 = Training(
          trainingId: 'train_002',
          employeeId: 'emp_002',
          trainingName: 'Data Science',
          status: TrainingStatus.completed,
          startDate: DateTime.now().subtract(Duration(days: 20)),
          completionDate: DateTime.now(),
          cost: 8000,
        );
        await repository.createTraining(train1);
        await repository.createTraining(train2);
        final total = await repository.getTotalTrainingCost();
        expect(total, 13000);
      });
    });

    group('Repository Tests - Leave', () {
      test('Create and retrieve leave', () async {
        final leave = LeaveRequest(
          leaveId: 'leave_001',
          employeeId: 'emp_001',
          leaveType: LeaveType.annual,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 5)),
          isApproved: true,
        );
        await repository.createLeaveRequest(leave);
        final retrieved = await repository.getLeaveRequest('leave_001');
        expect(retrieved?.leaveType, LeaveType.annual);
      });

      test('Get pending leaves', () async {
        final leave = LeaveRequest(
          leaveId: 'leave_001',
          employeeId: 'emp_001',
          leaveType: LeaveType.sick,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 2)),
          isApproved: false,
        );
        await repository.createLeaveRequest(leave);
        final pending = await repository.getPendingLeaves();
        expect(pending.length, greaterThan(0));
      });
    });

    group('Repository Tests - Payroll', () {
      test('Create and retrieve payroll', () async {
        final payroll = Payroll(
          payrollId: 'pay_001',
          employeeId: 'emp_001',
          grossSalary: 10000,
          taxes: 2000,
          deductions: 500,
          netPay: 7500,
          payPeriodStart: DateTime.now().subtract(Duration(days: 14)),
          payPeriodEnd: DateTime.now(),
          paymentDate: DateTime.now(),
        );
        await repository.createPayroll(payroll);
        final retrieved = await repository.getPayroll('pay_001');
        expect(retrieved?.netPay, 7500);
      });

      test('Get total payroll amount', () async {
        final pay1 = Payroll(
          payrollId: 'pay_001',
          employeeId: 'emp_001',
          grossSalary: 10000,
          taxes: 2000,
          deductions: 500,
          netPay: 7500,
          payPeriodStart: DateTime.now().subtract(Duration(days: 14)),
          payPeriodEnd: DateTime.now(),
          paymentDate: DateTime.now(),
        );
        await repository.createPayroll(pay1);
        final total = await repository.getTotalPayrollAmount();
        expect(total, 7500);
      });
    });

    group('Repository Tests - Attendance', () {
      test('Create and retrieve attendance', () async {
        final att = Attendance(
          attendanceId: 'att_001',
          employeeId: 'emp_001',
          date: DateTime.now(),
          checkInTime: DateTime.now(),
          checkOutTime: DateTime.now().add(Duration(hours: 8)),
        );
        await repository.createAttendance(att);
        final retrieved = await repository.getAttendance('att_001');
        expect(retrieved?.employeeId, 'emp_001');
      });

      test('Get average attendance rate', () async {
        final att = Attendance(
          attendanceId: 'att_001',
          employeeId: 'emp_001',
          date: DateTime.now(),
          checkInTime: DateTime.now(),
          checkOutTime: DateTime.now().add(Duration(hours: 8)),
        );
        await repository.createAttendance(att);
        final rate = await repository.getAverageAttendanceRate();
        expect(rate, 100);
      });
    });

    // ========================================================================
    // Engine Tests
    // ========================================================================

    group('Engine Tests - TalentAcquisition', () {
      test('Get total openings', () async {
        final rec = Recruitment(
          recruitmentId: 'rec_001',
          positionTitle: 'Engineer',
          departmentId: 'dept_001',
          departmentType: DepartmentType.engineering,
          status: RecruitmentStatus.openings,
          targetHires: 5,
          applicantsReceived: 20,
          openDate: DateTime.now(),
        );
        await repository.createRecruitment(rec);
        final engine = TalentAcquisitionEngine(repository);
        final total = await engine.getTotalOpenings();
        expect(total, greaterThan(0));
      });
    });

    group('Engine Tests - EmployeeManagement', () {
      test('Get active employee count', () async {
        final emp = Employee(
          employeeId: 'emp_001',
          firstName: 'Test',
          lastName: 'Employee',
          email: 'test@example.com',
          department: 'Engineering',
          departmentType: DepartmentType.engineering,
          jobTitle: 'Engineer',
          salary: 100000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        await repository.createEmployee(emp);
        final engine = EmployeeManagementEngine(repository);
        final count = await engine.getActiveEmployeeCount();
        expect(count, 1);
      });

      test('Get company average salary', () async {
        final emp = Employee(
          employeeId: 'emp_001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          department: 'Engineering',
          departmentType: DepartmentType.engineering,
          jobTitle: 'Engineer',
          salary: 100000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        await repository.createEmployee(emp);
        final engine = EmployeeManagementEngine(repository);
        final avg = await engine.getCompanyAverageSalary();
        expect(avg, 100000);
      });
    });

    group('Engine Tests - Performance', () {
      test('Get average performance score', () async {
        final review = PerformanceReview(
          reviewId: 'rev_001',
          employeeId: 'emp_001',
          reviewerId: 'mgr_001',
          rating: PerformanceRating.meets,
          strengths: 'Good',
          areasForImprovement: 'Time management',
          goals: 'Improve',
          reviewDate: DateTime.now(),
        );
        await repository.createPerformanceReview(review);
        final engine = PerformanceEngine(repository);
        final score = await engine.getAveragePerformanceScore();
        expect(score, greaterThan(0));
      });
    });

    group('Engine Tests - Development', () {
      test('Get total training investment', () async {
        final training = Training(
          trainingId: 'train_001',
          employeeId: 'emp_001',
          trainingName: 'Leadership',
          status: TrainingStatus.completed,
          startDate: DateTime.now().subtract(Duration(days: 30)),
          completionDate: DateTime.now(),
          cost: 5000,
        );
        await repository.createTraining(training);
        final engine = DevelopmentEngine(repository);
        final investment = await engine.getTotalTrainingInvestment();
        expect(investment, 5000);
      });
    });

    // ========================================================================
    // Facade Tests
    // ========================================================================

    group('Facade Tests', () {
      test('Hire employee', () async {
        final emp = Employee(
          employeeId: 'emp_001',
          firstName: 'Alice',
          lastName: 'Johnson',
          email: 'alice@example.com',
          department: 'Engineering',
          departmentType: DepartmentType.engineering,
          jobTitle: 'Engineer',
          salary: 95000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        await facade.hireEmployee(emp);
        final retrieved = await facade.getEmployee('emp_001');
        expect(retrieved?.firstName, 'Alice');
      });

      test('Get open positions', () async {
        final rec = Recruitment(
          recruitmentId: 'rec_001',
          positionTitle: 'Manager',
          departmentId: 'dept_001',
          departmentType: DepartmentType.sales,
          status: RecruitmentStatus.openings,
          targetHires: 3,
          applicantsReceived: 15,
          openDate: DateTime.now(),
        );
        await repository.createRecruitment(rec);
        final open = await facade.getOpenPositions();
        expect(open.length, greaterThan(0));
      });

      test('Get HR dashboard', () async {
        final emp = Employee(
          employeeId: 'emp_001',
          firstName: 'Test',
          lastName: 'Employee',
          email: 'test@example.com',
          department: 'Engineering',
          departmentType: DepartmentType.engineering,
          jobTitle: 'Engineer',
          salary: 100000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        await repository.createEmployee(emp);
        final dashboard = await facade.getHRDashboard();
        expect(dashboard.containsKey('activeEmployees'), true);
      });
    });

    // ========================================================================
    // Integration Tests
    // ========================================================================

    group('Integration Tests', () {
      test('Complete hiring workflow', () async {
        // Post position
        final rec = Recruitment(
          recruitmentId: 'rec_001',
          positionTitle: 'Engineer',
          departmentId: 'dept_001',
          departmentType: DepartmentType.engineering,
          status: RecruitmentStatus.openings,
          targetHires: 1,
          applicantsReceived: 10,
          openDate: DateTime.now(),
        );
        await facade.postPosition(rec);

        // Hire employee
        final emp = Employee(
          employeeId: 'emp_001',
          firstName: 'New',
          lastName: 'Hire',
          email: 'hire@example.com',
          department: 'Engineering',
          departmentType: DepartmentType.engineering,
          jobTitle: 'Engineer',
          salary: 100000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        await facade.hireEmployee(emp);

        // Set compensation
        final comp = Compensation(
          compensationId: 'comp_001',
          employeeId: 'emp_001',
          baseSalary: 100000,
          bonus: 20000,
          benefits: 10000,
          stocks: 5000,
          effectiveDate: DateTime.now(),
        );
        await facade.setCompensation(comp);

        final dashboard = await facade.getHRDashboard();
        expect(dashboard['activeEmployees'], 1);
      });

      test('Employee performance and development', () async {
        // Hire employee
        final emp = Employee(
          employeeId: 'emp_001',
          firstName: 'Developer',
          lastName: 'Test',
          email: 'dev@example.com',
          department: 'Engineering',
          departmentType: DepartmentType.engineering,
          jobTitle: 'Engineer',
          salary: 100000,
          status: EmploymentStatus.active,
          hireDate: DateTime.now(),
        );
        await facade.hireEmployee(emp);

        // Performance review
        final review = PerformanceReview(
          reviewId: 'rev_001',
          employeeId: 'emp_001',
          reviewerId: 'mgr_001',
          rating: PerformanceRating.exceeds,
          strengths: 'Excellent coding',
          areasForImprovement: 'Documentation',
          goals: 'Lead project',
          reviewDate: DateTime.now(),
        );
        await facade.submitPerformanceReview(review);

        // Training
        final training = Training(
          trainingId: 'train_001',
          employeeId: 'emp_001',
          trainingName: 'Advanced Dart',
          status: TrainingStatus.planned,
          startDate: DateTime.now().add(Duration(days: 30)),
          cost: 3000,
        );
        await facade.enrollTraining(training);

        final performance = await facade.getPerformanceScore();
        expect(performance, greaterThan(0));
      });
    });
  });
}
