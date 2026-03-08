class ReportModel {
  final String studentId;
  final String studentName;
  final String phoneNumber;
  final String itemType;
  final String description;
  final String locationLost;
  final String status;

  ReportModel({
    required this.studentId,
    required this.studentName,
    required this.phoneNumber,
    required this.itemType,
    required this.description,
    required this.locationLost,
    this.status = 'PENDING',
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'phone_number': phoneNumber,
      'item_type': itemType,
      'description': description,
      'location_lost': locationLost,
      'status': status,
    };
  }
}
