import 'package:flutter/material.dart';
import 'package:fortis_apps/core/data/models/leave_model.dart';
import 'package:fortis_apps/core/data/repositories/leave_repository.dart';
import 'package:fortis_apps/view/leave/view/addleave.dart';
import 'package:intl/intl.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final LeaveRepository _leaveRepo = LeaveRepositoryImpl();
  int selectedTabIndex = 0;
  List<String> tabs = ['All', 'Approved', 'Pending', 'Rejected'];

  // State variables
  List<LeaveModel> _allLeaves = [];
  List<LeaveModel> _filteredLeaves = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Statistics
  int _totalLeaves = 0;
  int _pendingLeaves = 0;
  int _approvedLeaves = 0;
  int _rejectedLeaves = 0;
  int _availableLeave = 24;

  @override
  void initState() {
    super.initState();
    _loadLeaveData();
  }

  Future<void> _loadLeaveData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _leaveRepo.getMyLeaves();

      if (response['success'] == true) {
        final leaves = (response['leaves'] as List)
            .map((json) => LeaveModel.fromJson(json))
            .toList();

        _calculateStatistics(leaves);

        setState(() {
          _allLeaves = leaves;
          _updateFilteredApplications();
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load leave data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateStatistics(List<LeaveModel> leaves) {
    setState(() {
      _totalLeaves = leaves.length;
      _pendingLeaves = leaves.where((l) => l.status == 'pending').length;
      _approvedLeaves = leaves.where((l) => l.status == 'approved').length;
      _rejectedLeaves = leaves.where((l) => l.status == 'rejected').length;
    });
  }

  void _updateFilteredApplications() {
    if (selectedTabIndex == 0) {
      _filteredLeaves = _allLeaves;
    } else if (selectedTabIndex == 1) {
      _filteredLeaves =
          _allLeaves.where((l) => l.status == 'approved').toList();
    } else if (selectedTabIndex == 2) {
      _filteredLeaves = _allLeaves.where((l) => l.status == 'pending').toList();
    } else if (selectedTabIndex == 3) {
      _filteredLeaves =
          _allLeaves.where((l) => l.status == 'rejected').toList();
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      selectedTabIndex = index;
      _updateFilteredApplications();
    });
  }

  void _navigateToAddLeave() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddLeavePage()),
    );

    if (result != null &&
        result is Map<String, dynamic> &&
        result['success'] == true) {
      _loadLeaveData(); // Refresh data setelah menambahkan cuti baru
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
            onPressed: () => _navigateToAddLeave(),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
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
                                _totalLeaves,
                                Colors.grey,
                                colorScheme,
                                textTheme,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Available',
                                _availableLeave,
                                Colors.blue,
                                colorScheme,
                                textTheme,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Applied',
                                _totalLeaves,
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
                                _approvedLeaves,
                                Colors.green,
                                colorScheme,
                                textTheme,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Pending',
                                _pendingLeaves,
                                Colors.orange,
                                colorScheme,
                                textTheme,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Rejected',
                                _rejectedLeaves,
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
                                onTap: () => _onTabChanged(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF4285F4)
                                            .withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF4285F4)
                                              .withOpacity(0.2)
                                          : colorScheme.outline
                                              .withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tab,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: isSelected
                                          ? Colors.blue
                                          : colorScheme.onSurface
                                              .withOpacity(0.4),
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
                      child: _filteredLeaves.isEmpty
                          ? const Center(
                              child: Text('No leave applications found'))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18.0),
                              itemCount: _filteredLeaves.length,
                              itemBuilder: (context, index) {
                                final application = _filteredLeaves[index];
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
    );
  }

  Widget _buildStatCard(
    String title,
    int value, // Ubah parameter menjadi int
    Color indicatorColor,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: indicatorColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          value.toString(),
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
    LeaveModel application,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    Color statusColor;
    String statusText;
    Color statusBackgroundColor;

    switch (application.status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.white;
        statusText = 'Approved';
        statusBackgroundColor = const Color(0xFF2EC22B);
        break;
      case 'pending':
        statusColor = Colors.white;
        statusText = 'Pending';
        statusBackgroundColor = const Color(0xFFFFBF2B);
        break;
      case 'rejected':
        statusColor = Colors.white;
        statusText = 'Rejected';
        statusBackgroundColor = Colors.red;
        break;
      default:
        statusColor = Colors.black;
        statusText = application.status;
        statusBackgroundColor = Colors.grey;
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
                DateFormat('MMM dd, yyyy').format(application.startDate),
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
                      _leaveRepo.formatLeaveType(application.type),
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
                      '${application.leaveDuration} days',
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
                      application.status == 'approved'
                          ? application.approverName
                          : application.status == 'rejected'
                              ? application.approverName
                              : '-', // Untuk pending dan status lainnya
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.status == 'approved'
                          ? 'Approved by'
                          : application.status == 'rejected'
                              ? 'Rejected by'
                              : 'Approved by',
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
// enum LeaveStatus { approved, pending, rejected }

// class LeaveApplication {
//   final String date;
//   final String leaveType;
//   final String appliedDays;
//   final String approvedBy;
//   final LeaveStatus status;

//   LeaveApplication({
//     required this.date,
//     required this.leaveType,
//     required this.appliedDays,
//     required this.approvedBy,
//     required this.status,
//   });
// }

// CustomSuccessDialog - Move this to Leave page or create a shared widget
class CustomSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onOkayPressed;

  const CustomSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onOkayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Check icon
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onOkayPressed != null) {
                    onOkayPressed!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2463EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Okay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getStatusText(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return 'Approved';
    case 'pending':
      return 'Pending';
    case 'rejected':
      return 'Rejected';
    case 'cancelled':
      return 'Cancelled';
    default:
      return status;
  }
}
