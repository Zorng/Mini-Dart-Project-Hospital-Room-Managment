import 'package:room_management/domain/bed.dart';
import 'package:room_management/domain/enums.dart';
import 'package:room_management/domain/room_type.dart';

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
    return beds.where((bed) => bed.status == BedAvailability.Available).length;
  }

  bool get isAvailable{
    return !isUnderMaintenance && freeBeds > 0;
  }

  String get overallStatus{
    if(isUnderMaintenance) return 'Maintenance';
    if(beds.any((b) => b.status == BedAvailability.NeedCleaning)) return "Needs Cleaning";
    if(beds.every((b) => b.status == BedAvailability.Available)) return "Ready";
    if(beds.every((b) => b.status == BedAvailability.Occupied)) return "Full";

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
}