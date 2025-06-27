class LeaveModel {
  final int? id;
  final String userNip;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String? proofFile;
  final String status;
  final Map<String, dynamic>? approvedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveModel({
    this.id,
    required this.userNip,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.proofFile,
    required this.status,
    this.approvedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    dynamic approvedByData = json['approved_by'] ?? json['approvedBy'];

    Map<String, dynamic>? parseApprovedBy(dynamic approvedByData) {
      if (approvedByData == null) return null;

      try {
        if (approvedByData is Map<String, dynamic>) {
          return approvedByData;
        }

        if (approvedByData is Map) {
          return Map<String, dynamic>.from(approvedByData);
        }

        return null;
      } catch (e) {
        print('Error parsing approved_by: $e');
        return null;
      }
    }

    return LeaveModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userNip: json['user_nip'].toString(),
      type: json['type'].toString(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      reason: json['reason'].toString(),
      proofFile: json['proof_file'],
      status: json['status'].toString(),
      approvedBy: parseApprovedBy(approvedByData),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_nip': userNip,
      'type': type,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'reason': reason,
      if (proofFile != null) 'proof_file': proofFile,
      'status': status,
      'approvedBy': approvedBy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Helper methods for status checking
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  // Helper methods for leave type
  bool get isPaidLeave => type == 'paid';
  bool get isSickLeave => type == 'sick';

  // Calculate leave duration
  int get leaveDuration => endDate.difference(startDate).inDays + 1;

  String get approverName {
    if (approvedBy == null) return 'Pending Approval';

    // Cek semua kemungkinan key untuk nama
    if (approvedBy!['name'] != null) return approvedBy!['name']!.toString();
    if (approvedBy!['full_name'] != null)
      return approvedBy!['full_name']!.toString();
    if (approvedBy!['username'] != null)
      return approvedBy!['username']!.toString();
    if (approvedBy!['display_name'] != null)
      return approvedBy!['display_name']!.toString();

    return 'Approved';
  }
}
