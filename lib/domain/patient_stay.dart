import 'enums.dart';
import 'room_type.dart';

class PatientStay{
  final String stayId;
  final String patientId;
  final String bedId;
  final String roomNumber;
  final RoomType roomRateSnapshot;
  final Level acuitySnapshot;
  final DateTime admissionTime;
  DateTime? dischargeTime;

  PatientStay({
    required this.stayId,
    required this.patientId,
    required this.bedId,
    required this.roomNumber,
    required this.roomRateSnapshot,
    required this.acuitySnapshot,
    required this.admissionTime,
    this.dischargeTime,
  });

  void recordDischarge(){
    if(dischargeTime == null){
      dischargeTime = DateTime.now();
      print('Stay $stayId discharged at ${dischargeTime!.toIso8601String()}.');
    }
  }

  double getPatientStayBill(){
    if(dischargeTime == null){
      return 0.0;
    }

    // calculate days stayed
    double totalDays = dischargeTime!.difference(admissionTime).inDays.toDouble();
    // RULE: minimum 1 day charge
    if(totalDays < 1) totalDays = 1.0;

    // calculate total bill
    double totalCents = totalDays * roomRateSnapshot.centPerDay;
    return totalCents / 100.0;
  }

  Map<String, dynamic> toJson() {
    return {
      "stayId": stayId,
      "patientId": patientId,
      "bedId": bedId,
      "roomNumber": roomNumber,
      "roomRateSnapshotName": roomRateSnapshot.name, 
      "acuitySnapshotName": acuitySnapshot.name,    
      "admissionTime": admissionTime.toIso8601String(),
      "dischargeTime": dischargeTime?.toIso8601String(), 
    };
  }

  static PatientStay fromJson(Map<String, dynamic> json) {
    // Helper functions to convert string names back to enums
    RoomType roomTypeFromStr(String name) => RoomType.values.firstWhere((e) => e.name == name);
    Level acuityFromStr(String name) => Level.values.firstWhere((e) => e.name == name);
    
    return PatientStay(
      stayId: json["stayId"] as String,
      patientId: json["patientId"] as String,
      bedId: json["bedId"] as String,
      roomNumber: json["roomNumber"] as String,
      roomRateSnapshot: roomTypeFromStr(json["roomRateSnapshotName"] as String),
      acuitySnapshot: acuityFromStr(json["acuitySnapshotName"] as String),
      admissionTime: DateTime.parse(json["admissionTime"] as String),
      dischargeTime: json["dischargeTime"] != null 
          ? DateTime.parse(json["dischargeTime"] as String) // Parse if available
          : null, // Otherwise, it is null
    );
  }
}