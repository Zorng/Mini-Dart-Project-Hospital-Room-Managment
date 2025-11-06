import 'bed.dart';
import 'enums.dart';
import 'room_type.dart';
import 'patient.dart';
import 'patient_stay.dart';

abstract class Room {
  final String roomNumber;
  final RoomType type;
  final List<Bed> beds;
  final GenderPolicy genderPolicy;
  DateTime? lastCleaned;
  bool isUnderMaintenance;

  Room({
    required this.roomNumber,
    required this.type,
    required this.beds,
    required this.genderPolicy,
    this.lastCleaned,
    this.isUnderMaintenance = false,
  });

  int get freeBeds {
    return beds.where((bed) => bed.status == BedAvailability.available).length;
  }

  bool get isAvailable {
    return !isUnderMaintenance && freeBeds > 0;
  }

  String get overallStatus {
    if (isUnderMaintenance) {
      return 'Maintenance';
    } else if (beds.any((b) => b.status == BedAvailability.needCleaning)) {
      return "Needs Cleaning";
    } else if (beds.every((b) => b.status == BedAvailability.occupied)) {
      return "Full";
    } else {
      return 'Ready';
    }
  }

  void markForMaintenance() {
    if (beds.every((b) => b.status == BedAvailability.available)) {
      isUnderMaintenance = true;
    } else {
      throw Exception("Occupied beds exist. Cannot put $roomNumber under maintenance");
    }
  }

  void clearMaintenance() {
    if(isUnderMaintenance == false) {
     print ("Room $roomNumber Already under maintenance");
     return;
    }
    isUnderMaintenance = false;
    print('Room $roomNumber maintenance cleared.');
  }

  // Abstract method
  bool canAdmit(Patient patient);
  PatientStay admitPatient(Patient patient);

  Map<String, dynamic> toJson() {
    return {
      "roomNumber": roomNumber,
      "type": type.name,
      "genderPolicy": genderPolicy.name,
      "isUnderMaintenance": isUnderMaintenance,
      "lastCleaned": lastCleaned?.toIso8601String(),
      "beds": beds.map((bed) => bed.toJson()).toList(),
    };
  }
}

// for abstact class, fromJson is implemented in subclasses
