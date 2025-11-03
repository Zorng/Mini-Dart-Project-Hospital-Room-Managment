// ward.dart

import 'package:room_management/domain/room.dart';
import 'package:room_management/domain/bed.dart';
import 'package:room_management/domain/enums.dart';
import 'package:room_management/domain/room_type.dart';

class Ward extends Room {

  Ward(
    String roomNumber, 
    RoomType type, 
    GenderPolicy genderPolicy
  ) : super(roomNumber, type, genderPolicy);
  
  @override
  bool canAdmit(Patient patient) {
    // Check basic room availability
    if (!isAvailable) {
      print('Admission denied for ${patient.name}: Room $roomNumber is full or under maintenance.');
      return false;
    }

    // Check gender policy
    if (genderPolicy == GenderPolicy.Mixed) {
      return true;
    }
    
    // Check male only
    if (genderPolicy == GenderPolicy.MaleOnly && patient.gender == Gender.Male) {
      return true;
    }
    
    // Check female only
    if (genderPolicy == GenderPolicy.FemaleOnly && patient.gender == Gender.Female) {
      return true;
    }

    print('Admission denied for ${patient.name}: Gender policy violation in $roomNumber (${genderPolicy.name} only).');
    return false;
  }
  
  @override
  void admitPatient(Patient patient) {
    if (!canAdmit(patient)) {
      return; 
    }
    
    // Find first available bed
    Bed? targetBed = beds.firstWhere(
      (bed) => bed.isAvailable, 
      orElse: () => throw Exception('Critical Error: Room $roomNumber passed canAdmit() but found no free beds.'),
    );
    
    String newStayId = 'STAY-${DateTime.now().microsecondsSinceEpoch}';

    // Assign the patient to the bed
    targetBed.assignPatient(patient, newStayId);
    print('Patient ${patient.name} admitted to Ward $roomNumber, Bed ${targetBed.bedId}.');
  }
}