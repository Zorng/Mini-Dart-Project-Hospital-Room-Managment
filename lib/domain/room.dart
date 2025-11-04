import 'bed.dart';
import 'enums.dart';
import 'room_type.dart';
import 'patient.dart';

abstract class Room{
  final String roomNumber;
  final RoomType type;
  List<Bed> beds;
  DateTime? lastCleaned;
  GenderPolicy genderPolicy;
  bool isUnderMaintenance;

  Room(
    this.roomNumber,
    this.type,
    this.genderPolicy,
    {this.isUnderMaintenance = false}
  ) : beds = List.generate(type.capacity, (i) => Bed('$roomNumber-${i + 1}')); // init number of beds for this room type

  int get freeBeds{
    return beds.where((bed) => bed.status == BedAvailability.available).length;
  }

  bool get isAvailable{
    return !isUnderMaintenance && freeBeds > 0;
  }

  String get overallStatus{
    if(isUnderMaintenance) return 'Maintenance';
    if(beds.any((b) => b.status == BedAvailability.needCleaning)) return "Needs Cleaning";
    if(beds.every((b) => b.status == BedAvailability.available)) return "Ready";
    if(beds.every((b) => b.status == BedAvailability.occupied)) return "Full";

    return "Mixed";
  }

  void markForMaintenance(){
    isUnderMaintenance = true;
    print('Room $roomNumber marked for maintenace. Admission blocked!');
  }

  void clearMaintenance(){
    isUnderMaintenance = false;
    print('Room $roomNumber maintenance cleared.');
  }

  // Abstract method
  bool canAdmit(Patient patient);
  void admitPatient(Patient patient);

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