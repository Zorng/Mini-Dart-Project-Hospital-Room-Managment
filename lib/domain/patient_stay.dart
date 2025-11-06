import 'enums.dart';
import 'room_type.dart';
import 'patient.dart';
import 'bed.dart';

class PatientStay{
  final String stayId;
  final String patientId;
  final String assignedBedId;
  final DateTime assignedDate;
  DateTime? dischargeDate;

  Patient? currentPatient;
  Bed? assignedBed;

  RoomType? roomRateSnapshot;
  Level? acuitySnapshot;
  String? roomNumberSnapshot;

  PatientStay({
    required this.stayId,
    required this.patientId,
    required this.assignedBedId,
    required this.assignedDate,
    this.dischargeDate,
    this.roomRateSnapshot,
    this.acuitySnapshot,
    this.roomNumberSnapshot,
  });

  // check if patient is currently admitted
  bool get isActive => dischargeDate == null;

  void recordDischarge(){
    if(dischargeDate == null){
      dischargeDate = DateTime.now();
      print('Stay $stayId discharged at ${dischargeDate!.toIso8601String()}.');
    }
  }

  double getPatientStayBill(){
    if(dischargeDate == null || roomRateSnapshot == null){
      return 0.0;
    }

    // calculate days stayed
    double totalHours = dischargeDate!.difference(assignedDate).inHours.toDouble();
    double totalDays = totalHours / 24.0;
    // RULE: minimum 1 day charge
    if(totalDays < 1) totalDays = 1.0;

    // calculate total bill
    double totalCents = totalDays * roomRateSnapshot!.centPerDay;
    return totalCents / 100.0;
  }

  Map<String, dynamic> toJson() {
    return {
      "stayId": stayId,
      "patientId": patientId,
      "bedId": assignedBedId,
      "admitDate": assignedDate.toIso8601String(),
      "dischargeDate": dischargeDate?.toIso8601String(),
    };
  }

  static PatientStay fromJson(Map<String, dynamic> json) {

    DateTime? parseDate(String? dateString) => dateString != null ? DateTime.parse(dateString) : null;

    final String? stayId = json["stayId"] as String?;
    if (stayId == null) throw ArgumentError('Missing required field "stayId".');

    final String? patientId = json["patientId"] as String?;
    if (patientId == null) throw ArgumentError('Missing required field "patientId".');

    final String? bedId = json["bedId"] as String?;
    if (bedId == null) throw ArgumentError('Missing required field "bedId" for Stay.');

    final DateTime? assignedDate = parseDate(json["admitDate"] as String?);
    if (assignedDate == null) throw ArgumentError('Missing or invalid required field "admitDate".');

    final DateTime? dischargeDate = parseDate(json["dischargeDate"] as String?);

    return PatientStay(
      stayId: stayId,
      patientId: patientId,
      assignedBedId: bedId, 
      assignedDate: assignedDate,
      dischargeDate: dischargeDate,
      roomRateSnapshot: null,
      acuitySnapshot: null,
      roomNumberSnapshot: null,
    );
  }
}