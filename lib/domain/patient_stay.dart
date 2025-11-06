import 'enums.dart';
import 'room_type.dart';
import 'patient.dart';
import 'bed.dart';

class PatientStay {
  final String stayId;
  final String patientId;
  final String assignedBedId;
  final DateTime assignedDate;
  DateTime? dischargeDate;

  // Optional runtime references
  Patient? currentPatient;
  Bed? assignedBed;

  // Snapshots for billing (captured at admit time)
  final RoomType roomRateSnapshot;   // e.g., shared, semiPrivate, private, vip
  final Level? acuitySnapshot;       // e.g., lv1–lv3, null for wards
  final String roomNumberSnapshot;   // e.g., A001, 2V201, etc.

  PatientStay({
    required this.stayId,
    required this.patientId,
    required this.assignedBedId,
    required this.assignedDate,
    required this.roomRateSnapshot,
    required this.roomNumberSnapshot,
    this.acuitySnapshot,
    this.dischargeDate,
  });

  bool get isActive => dischargeDate == null;

  void recordDischarge() {
    if (dischargeDate == null) {
      dischargeDate = DateTime.now();
      print('Stay $stayId discharged at ${dischargeDate!.toIso8601String()}');
    }
  }

  double getPatientStayBill() {
    if (roomRateSnapshot.centPerDay <= 0) return 0.0;

    final end = dischargeDate ?? DateTime.now();
    double totalHours = end.difference(assignedDate).inHours.toDouble();
    double totalDays = totalHours / 24.0;
    if (totalDays < 1) totalDays = 1.0; // minimum charge = 1 day

    final totalCents = totalDays * roomRateSnapshot.centPerDay;
    return totalCents / 100.0;
  }

  /// ✅ Serialize to JSON (matches your updated dataset)
  Map<String, dynamic> toJson() {
    return {
      "stayId": stayId,
      "patientId": patientId,
      "bedId": assignedBedId,
      "admitDate": assignedDate.toIso8601String(),
      "dischargeDate": dischargeDate?.toIso8601String(),
      "roomRateSnapshot": roomRateSnapshot.name,      // e.g. "shared"
      "acuitySnapshot": acuitySnapshot?.name,         // e.g. "lv2" or null
      "roomNumberSnapshot": roomNumberSnapshot,       // e.g. "A001"
    };
  }

  /// ✅ Deserialize from JSON (handles null `acuitySnapshot`)
  static PatientStay fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) =>
        (dateString != null && dateString.isNotEmpty)
            ? DateTime.parse(dateString)
            : null;

    final stayId = json["stayId"] as String?;
    final patientId = json["patientId"] as String?;
    final bedId = json["bedId"] as String?;
    final admitDate = parseDate(json["admitDate"] as String?);
    final dischargeDate = parseDate(json["dischargeDate"] as String?);
    final roomRate = json["roomRateSnapshot"] as String?;
    final acuity = json["acuitySnapshot"];
    final roomNumberSnap = json["roomNumberSnapshot"] as String?;

    if (stayId == null) throw ArgumentError('Missing "stayId".');
    if (patientId == null) throw ArgumentError('Missing "patientId".');
    if (bedId == null) throw ArgumentError('Missing "bedId".');
    if (admitDate == null) throw ArgumentError('Missing "admitDate".');
    if (roomRate == null) throw ArgumentError('Missing "roomRateSnapshot".');
    if (roomNumberSnap == null) throw ArgumentError('Missing "roomNumberSnapshot".');

    return PatientStay(
      stayId: stayId,
      patientId: patientId,
      assignedBedId: bedId,
      assignedDate: admitDate,
      dischargeDate: dischargeDate,
      roomRateSnapshot: RoomType.values.firstWhere(
        (r) => r.name == roomRate,
        orElse: () => throw ArgumentError('Invalid roomRateSnapshot: $roomRate'),
      ),
      acuitySnapshot: acuity == null
          ? null
          : Level.values.firstWhere(
              (l) => l.name == acuity,
              orElse: () => throw ArgumentError('Invalid acuitySnapshot: $acuity'),
            ),
      roomNumberSnapshot: roomNumberSnap,
    );
  }
}