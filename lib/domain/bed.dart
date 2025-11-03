import 'enums.dart';

class Patient{
  final String id;
  final String name;
  final String phone;
  final Gender gender;

  Patient(this.id, this.name, this.phone, this.gender);
}

class Bed{
  final String bedId;
  BedAvailability status;

  // Link to Patient and stay records
  Patient? currentPatient;
  String? currentStayId;

  DateTime? assignedDate;

  Bed(this.bedId, {this.status = BedAvailability.Available});

  bool get isAvailable{
    return status == BedAvailability.Available;
  }

  // mark the bed as Occupied and assigned it to patient
  void assignPatient(Patient patient, String stayId){
    if(status != BedAvailability.Available){
      throw Exception('Bed $bedId is not available (Status: ${status.name})');
    }
    currentPatient = patient;
    currentStayId = stayId;
    assignedDate = DateTime.now();
    status = BedAvailability.Occupied;
    print('Bed $bedId assigned to ${patient.name} (Stay: $stayId)');
  }

  // discharge patient and then set the bed to need clean
  void dischargePatient(){
    if(status != BedAvailability.Occupied){
      throw Exception('Cannot discharge: Bed is not occupied.');
    }
    
    // clear the reference
    currentPatient = null;
    currentStayId = null;

    status = BedAvailability.NeedCleaning;
    print('Patient discharged from Bed $bedId. Status set to NeedCleaning.');
  }

  // mark the bed as clean after NeedCleaning, and make it Available
  void markCleaned(){
    if(status != BedAvailability.NeedCleaning){
      throw Exception('Cannot clean: Bed is not marked for cleaning');
    }

    status = BedAvailability.Available;
    print('Bed $bedId cleaned and now available');
  }
}