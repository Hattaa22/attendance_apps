import 'package:flutter/material.dart';
import '../../view/leave/addleave.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  int selectedTabIndex = 0;
  List<String> tabs = ['All', 'Approved', 'Pending', 'Rejected'];
  
  // Leave statistics
  int totalLeave = 30;
  int availableLeave = 24;
  int appliedLeave = 27;
  int approvedLeave = 17;
  int pendingLeave = 27;
  int rejectedLeave = 30;
  
  // Leave applications data
  List<LeaveApplication> leaveApplications = [];
  List<LeaveApplication> filteredApplications = [];

  @override
  void initState() {
    super.initState();
    _initializeLeaveData();
    _updateFilteredApplications();
  }

  void _initializeLeaveData() {
    leaveApplications = [
      LeaveApplication(
        date: 'Apr 1, 2025',
        leaveType: 'Sick leave',
        appliedDays: '1 Day',
        approvedBy: 'Manager',
        status: LeaveStatus.pending,
      ),
      LeaveApplication(
        date: 'Feb 25, 2025',
        leaveType: 'Sick leave',
        appliedDays: '3 Day',
        approvedBy: 'Manager',
        status: LeaveStatus.approved,
      ),
      LeaveApplication(
        date: 'January 10, 2025',
        leaveType: 'Paid leave',
        appliedDays: '2 Day',
        approvedBy: 'Manager',
        status: LeaveStatus.rejected,
      ),
    ];
  }

  void _updateFilteredApplications() {
    if (selectedTabIndex == 0) {
      filteredApplications = leaveApplications;
    } else if (selectedTabIndex == 1) {
      filteredApplications = leaveApplications
          .where((app) => app.status == LeaveStatus.approved)
          .toList();
    } else if (selectedTabIndex == 2) {
      filteredApplications = leaveApplications
          .where((app) => app.status == LeaveStatus.pending)
          .toList();
    } else if (selectedTabIndex == 3) {
      filteredApplications = leaveApplications
          .where((app) => app.status == LeaveStatus.rejected)
          .toList();
    }
  }

  void _navigateToAddLeave() async {
    // Navigate to AddLeave page and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddLeavePage(),
      ),
    );
    
    // If a new leave application was added, refresh the data
    if (result != null && result == true) {
      // You can refresh the leave data here if needed
      // For example, if AddLeavePage returns the new leave data:
      // _initializeLeaveData(); // or fetch from API
      // _updateFilteredApplications();
      setState(() {
        // Refresh the UI
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(244, 244, 244, 1),
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Leave',
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF000000),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            onPressed: _navigateToAddLeave, // Modified: Added navigation function
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                color: const Color(0xFF4285F4),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leave Status Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave status',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                // Statistics Row 1
                Row(
                  children: [
                    _buildStatCard(
                      'Total leave',
                      totalLeave.toString(),
                      Colors.grey,
                      colorScheme,
                      textTheme,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Available',
                      availableLeave.toString(),
                      Colors.blue,
                      colorScheme,
                      textTheme,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Applied',
                      appliedLeave.toString(),
                      Colors.cyan,
                      colorScheme,
                      textTheme,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Statistics Row 2
                Row(
                  children: [
                    _buildStatCard(
                      'Approved',
                      approvedLeave.toString(),
                      Colors.green,
                      colorScheme,
                      textTheme,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Pending',
                      pendingLeave.toString(),
                      Colors.orange,
                      colorScheme,
                      textTheme,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Rejected',
                      rejectedLeave.toString(),
                      Colors.red,
                      colorScheme,
                      textTheme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.asMap().entries.map((entry) {
                  int index = entry.key;
                  String tab = entry.value;
                  bool isSelected = selectedTabIndex == index;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTabIndex = index;
                          _updateFilteredApplications();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF4285F4).withOpacity(0.2) // Blue color like in image
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF4285F4).withOpacity(0.2)
                                : colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tab,
                          style: textTheme.bodyMedium?.copyWith(
                            color: isSelected 
                                ? Colors.blue
                                : colorScheme.onSurface.withOpacity(0.4),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Leave Applications List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              itemCount: filteredApplications.length,
              itemBuilder: (context, index) {
                final application = filteredApplications[index];
                return _buildLeaveApplicationCard(
                  application,
                  colorScheme,
                  textTheme,
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: colorScheme.surface,
        elevation: 8,
        currentIndex: 4, // Leave tab is selected
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            label: 'Salary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Leave',
          ),
        ],
      ),
    );
  }

Widget _buildStatCard(
    String title,
    String value,
    Color indicatorColor,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0, // Square aspect ratio for consistent sizing
        child: Container(
          decoration: BoxDecoration(
            color: indicatorColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Top indicator line (full width, touching top)
              Container(
                width: double.infinity,
                height: 4,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              // Content with padding
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      // Title at top-left
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Text(
                          title,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Value at bottom-right
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          value,
                          style: textTheme.headlineLarge?.copyWith(
                            color: indicatorColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveApplicationCard(
    LeaveApplication application,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    Color statusColor;
    String statusText;
    Color statusBackgroundColor;

    switch (application.status) {
      case LeaveStatus.approved:
        statusColor = Colors.white;
        statusText = 'Approved';
        statusBackgroundColor = Color(0xFF2EC22B);
        break;
      case LeaveStatus.pending:
        statusColor = Colors.white;
        statusText = 'Pending';
        statusBackgroundColor = Color(0xFFFFBF2B);
        break;
      case LeaveStatus.rejected:
        statusColor = Colors.white;
        statusText = 'Rejected';
        statusBackgroundColor = Colors.red;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF2463EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                application.date,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Garis horizontal tipis sebagai pemisah
          Divider(
            height: 2,
            thickness: 2,
            color: colorScheme.outline.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.leaveType,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Leave type',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.appliedDays,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Applied days',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.approvedBy,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Approved by',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Data Models
enum LeaveStatus { approved, pending, rejected }

class LeaveApplication {
  final String date;
  final String leaveType;
  final String appliedDays;
  final String approvedBy;
  final LeaveStatus status;

  LeaveApplication({
    required this.date,
    required this.leaveType,
    required this.appliedDays,
    required this.approvedBy,
    required this.status,
  });
}