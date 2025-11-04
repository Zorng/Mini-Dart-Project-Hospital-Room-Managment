import 'enums.dart';
import 'patient.dart';

class Bed{
  final String bedId;
  BedAvailability status;

  // Link to Patient and stay records
  Patient? currentPatient;
  String? currentStayId;

  DateTime? assignedDate;

  Bed(this.bedId, {
    this.status = BedAvailability.available,
    this.currentPatient,
    this.currentStayId,
    this.assignedDate,
  });

  bool get isAvailable{
    return status == BedAvailability.available;
  }

  // mark the bed as Occupied and assigned it to patient
  void assignPatient(Patient patient, String stayId){
    if(status != BedAvailability.available){
      throw Exception('Bed $bedId is not available (Status: ${status.name})');
    }
    currentPatient = patient;
    currentStayId = stayId;
    assignedDate = DateTime.now();
    status = BedAvailability.occupied;
    print('Bed $bedId assigned to ${patient.name} (Stay: $stayId)');
  }

  // discharge patient and then set the bed to need clean
  void dischargePatient(){
    if(status != BedAvailability.occupied){
      throw Exception('Cannot discharge: Bed is not occupied.');
    }
    
    // clear the reference
    currentPatient = null;
    currentStayId = null;
    assignedDate = null;

    status = BedAvailability.needCleaning;
    print('Patient discharged from Bed $bedId. Status set to NeedCleaning.');
  }

  // mark the bed as clean after NeedCleaning, and make it Available
  void markCleaned(){
    if(status != BedAvailability.needCleaning){
      throw Exception('Cannot clean: Bed is not marked for cleaning');
    }

    status = BedAvailability.available;
    print('Bed $bedId cleaned and now available');
  }  

  Map<String, dynamic> toJson() {
    return {
      "bedId": bedId,
      "status": status.name,
      "currentPatientId": currentPatient?.id, 
      "currentStayId": currentStayId,
      "assignedDate": assignedDate?.toIso8601String(), 
    };
  }

  static Bed fromJson(Map<String, dynamic> json) {
    BedAvailability statusFromStr(String name) {
      return BedAvailability.values.firstWhere(
        (e) => e.name == name,
        orElse: () => BedAvailability.available, 
      );
    }

    return Bed(
      json["bedId"] as String,
      status: statusFromStr(json["status"] as String),
      currentStayId: json["currentStayId"] as String?,
      assignedDate: json["assignedDate"] != null
          ? DateTime.parse(json["assignedDate"] as String)
          : null,
    );
  }
}