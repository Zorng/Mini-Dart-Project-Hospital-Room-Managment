import 'enums.dart';
import 'patient.dart';
import 'patient_stay.dart';

class Bed{
  final String bedId;
  BedAvailability status;
  final DateTime? lastClean;
  final DateTime? lastAssigned;

  // Link to Patient and stay records
  Patient? currentPatient;
  PatientStay? currentStayId;

  Bed(this.bedId, {
    this.status = BedAvailability.available,
    this.currentPatient,
    this.lastClean,
    this.lastAssigned,
  });

  bool get isAvailable{
    return status == BedAvailability.available;
  }

  // mark the bed as Occupied and assigned it to patient
  void assignPatient(Patient patient, PatientStay stay){
    if(status != BedAvailability.available){
      throw Exception('Bed $bedId is not available (Status: ${status.name})');
    }
    currentPatient = patient;
    currentStayId = stay;
    status = BedAvailability.occupied;
    print('Bed $bedId assigned to ${patient.name} (Stay: ${stay.stayId})');
  }

  // discharge patient and then set the bed to need clean
  void dischargePatient(){
    if(status != BedAvailability.occupied){
      throw Exception('Cannot discharge: Bed is not occupied.');
    }
    
    // clear the reference
    currentPatient = null;
    currentStayId = null;

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
      "lastClean": lastClean?.toIso8601String(),
      "lastAssigned": lastAssigned?.toIso8601String(),
    };
  }

  static Bed fromJson(Map<String, dynamic> json) {
    BedAvailability statusFromStr(String name) {
      return BedAvailability.values.firstWhere(
        (e) => e.name == name,
        orElse: () => BedAvailability.available, 
      );
    }

    DateTime? parseDate(String? dateString){
      return dateString != null ? DateTime.parse(dateString) : null;
    }

    return Bed(
      json["bedId"] as String,
      status: statusFromStr(json["status"] as String),
      lastClean: parseDate(json["lastClean"] as String?),
      lastAssigned: parseDate(json['lastAssigned'] as String?),
    );
  }
}