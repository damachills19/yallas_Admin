enum ComplaintStatus { open, inProgress, resolved, closed }

ComplaintStatus complaintStatusFromString(String? s) {
  switch (s) {
    case 'in_progress':
      return ComplaintStatus.inProgress;
    case 'resolved':
      return ComplaintStatus.resolved;
    case 'closed':
      return ComplaintStatus.closed;
    default:
      return ComplaintStatus.open;
  }
}

String complaintStatusToString(ComplaintStatus s) {
  switch (s) {
    case ComplaintStatus.open:
      return 'open';
    case ComplaintStatus.inProgress:
      return 'in_progress';
    case ComplaintStatus.resolved:
      return 'resolved';
    case ComplaintStatus.closed:
      return 'closed';
  }
}

class Complaint {
  final String id;
  final String userId;
  final String subject;
  final String message;
  final ComplaintStatus status;
  final String? adminResponse;
  final DateTime createdAt;

  const Complaint({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    this.status = ComplaintStatus.open,
    this.adminResponse,
    required this.createdAt,
  });

  factory Complaint.fromRow(Map<String, dynamic> row) => Complaint(
        id: row['id'] as String,
        userId: row['user_id'] as String? ?? '',
        subject: row['subject'] as String? ?? '',
        message: row['message'] as String? ?? '',
        status: complaintStatusFromString(row['status'] as String?),
        adminResponse: row['admin_response'] as String?,
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
