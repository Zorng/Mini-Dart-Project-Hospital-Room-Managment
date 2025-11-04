  import 'room.dart';
  import 'bed.dart';
  import 'enums.dart';
  import 'room_type.dart';
  import 'patient.dart';

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
      if (genderPolicy == GenderPolicy.mixed) {
        return true;
      }
      
      // Check male only
      if (genderPolicy == GenderPolicy.maleOnly && patient.gender == Gender.male) {
        return true;
      }
      
      // Check female only
      if (genderPolicy == GenderPolicy.femaleOnly && patient.gender == Gender.female) {
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

    static Ward fromJson(Map<String, dynamic> json) {
    // Helper functions to convert string names back to enums
    RoomType typeFromStr(String name) => RoomType.values.firstWhere((e) => e.name == name);
    GenderPolicy policyFromStr(String name) => GenderPolicy.values.firstWhere((e) => e.name == name);
    
    // Instantiate the Ward using the constructor (handles beds list initialization)
    final Ward ward = Ward(
      json["roomNumber"] as String,
      typeFromStr(json["type"] as String),
      policyFromStr(json["genderPolicy"] as String),
    );
    
    // Load the nested Bed objects from the JSON map
    final List<Map<String, dynamic>> bedMaps = (json["beds"] as List).cast<Map<String, dynamic>>();
    
    // Deserialize each bed map using the Bed.fromJson method
    ward.beds = bedMaps.map((bedMap) => Bed.fromJson(bedMap)).toList();
    
    // Load remaining properties that don't pass through the constructor
    // lastCleaned can be null
    if (json["lastCleaned"] != null) {
      ward.lastCleaned = DateTime.parse(json["lastCleaned"] as String);
    }
    // isUnderMaintenance can be loaded if the file explicitly includes it
    if (json["isUnderMaintenance"] != null) {
      ward.isUnderMaintenance = json["isUnderMaintenance"] as bool;
    }

    return ward;
  }
}