enum VerificationStatus { pending, approved, rejected }

VerificationStatus verificationStatusFromString(String? s) {
  switch (s) {
    case 'approved':
      return VerificationStatus.approved;
    case 'rejected':
      return VerificationStatus.rejected;
    default:
      return VerificationStatus.pending;
  }
}

class TrainerApplication {
  final String trainerId;
  final VerificationStatus verificationStatus;
  final DateTime submittedAt;
  final String qualifications;
  final int experienceYears;
  final String experienceBio;
  final List<String> certifications;
  final bool hasProfilePhoto;
  final String? idCardFrontPath;
  final String? idCardBackPath;
  final String? idCardVerdictNote;
  final List<String> certificatePaths;
  final List<String> certificateVerdictNotes;

  const TrainerApplication({
    required this.trainerId,
    this.verificationStatus = VerificationStatus.pending,
    required this.submittedAt,
    this.qualifications = '',
    this.experienceYears = 0,
    this.experienceBio = '',
    this.certifications = const [],
    this.hasProfilePhoto = false,
    this.idCardFrontPath,
    this.idCardBackPath,
    this.idCardVerdictNote,
    this.certificatePaths = const [],
    this.certificateVerdictNotes = const [],
  });

  factory TrainerApplication.fromRow(Map<String, dynamic> row) {
    return TrainerApplication(
      trainerId: row['trainer_user_id'] as String,
      verificationStatus: verificationStatusFromString(row['verification_status'] as String?),
      submittedAt: DateTime.tryParse(row['submitted_at'] as String? ?? '') ?? DateTime.now(),
      qualifications: row['qualifications'] as String? ?? '',
      experienceYears: (row['experience_years'] as num?)?.toInt() ?? 0,
      experienceBio: row['experience_bio'] as String? ?? '',
      certifications: (row['certifications'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      hasProfilePhoto: row['has_profile_photo'] as bool? ?? false,
      idCardFrontPath: row['id_card_front_path'] as String?,
      idCardBackPath: row['id_card_back_path'] as String?,
      idCardVerdictNote: row['id_card_verdict_note'] as String?,
      certificatePaths: (row['certificate_paths'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      certificateVerdictNotes:
          (row['certificate_verdict_notes'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
