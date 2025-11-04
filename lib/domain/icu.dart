import 'room.dart';
import 'bed.dart';
import 'enums.dart';
import 'room_type.dart';
import 'patient.dart';

class ICU extends Room {
  final bool hasVentilator;
  final bool hasCardiacMonitor;
  final Level acuityLevel;

  ICU(
    String roomNumber,
    RoomType type,
    GenderPolicy genderPolicy,
    this.hasVentilator,
    this.hasCardiacMonitor,
    this.acuityLevel,
  ) : super(roomNumber, type, genderPolicy);

  @override
  bool canAdmit(Patient patient) {
    if (!isAvailable) {
      print(
        'Admission denied for ${patient.name}: ICU $roomNumber is full or under maintenance.',
      );
      return false;
    }

    if (genderPolicy == GenderPolicy.maleOnly &&
        patient.gender != Gender.male) {
      print(
        'Admmission denied for ${patient.name}: Gender policy violation in ICU $roomNumber.',
      );
      return false;
    } else if (genderPolicy == GenderPolicy.femaleOnly &&
        patient.gender != Gender.female) {
      print(
        'Admmission denied for ${patient.name}: Gender policy violation in ICU $roomNumber.',
      );
      return false;
    }

    // Acuity level check
    if (patient.requiredAcuity.index > acuityLevel.index) {
      print(
        'Admission denied for ${patient.name}: Acuity mismatch (Patient requires ${patient.requiredAcuity.name}, ICU is only ${acuityLevel.name}).',
      );
      return false;
    }

    // Ventilator resource check
    if (patient.requiresVentilator && !hasVentilator) {
      print(
        'Admission denied for ${patient.name}: Patient requires ventilator, but ICU $roomNumber does not have one.',
      );
      return false;
    }

    return true;
  }

  @override
  void admitPatient(Patient patient) {
    if (!canAdmit(patient)) {
      return;
    }

    Bed? targetBed = beds.firstWhere(
      (bed) => bed.isAvailable,
      orElse: () => throw Exception(
        'Critical Error: ICU $roomNumber passed canAdmit() but found no free beds.',
      ),
    );

    String newStayId = 'STAY-${DateTime.now().microsecondsSinceEpoch}';
    targetBed.assignPatient(patient, newStayId);
    print(
      'Patient ${patient.name} admitted to ICU $roomNumber, Bed ${targetBed.bedId}.',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // Merge base Room data (including the 'beds' list) with ICU specific data
    return {
      ...super.toJson(),
      "hasVentilator": hasVentilator,
      "hasCardiacMonitor": hasCardiacMonitor,
      "acuityLevelName": acuityLevel.name
    };
  }

  static ICU fromJson(Map<String, dynamic> json) {
    // Helper functions to convert string names back to enums
    RoomType typeFromStr(String name) => RoomType.values.firstWhere((e) => e.name == name);
    GenderPolicy policyFromStr(String name) => GenderPolicy.values.firstWhere((e) => e.name == name);
    Level acuityFromStr(String name) => Level.values.firstWhere((e) => e.name == name);

    // Instantiate the ICU using the constructor
    final ICU icu = ICU(
      json["roomNumber"] as String,
      typeFromStr(json["type"] as String),
      policyFromStr(json["genderPolicy"] as String),
      json["hasVentilator"] as bool,
      json["hasCardiacMonitor"] as bool,
      acuityFromStr(json["acuityLevelName"] as String),
    );

    // Deserialize the nested Bed objects from the JSON map
    final List<Map<String, dynamic>> bedMaps = (json["beds"] as List).cast<Map<String, dynamic>>();

    // Deserialize each bed map using the Bed.fromJson method
    // and assign the new list of Bed objects to the ICU instance
    icu.beds = bedMaps.map((bedMap) => Bed.fromJson(bedMap)).toList();

    // Load remaining properties from the abstract Room base class
    if (json["lastCleaned"] != null) {
      icu.lastCleaned = DateTime.parse(json["lastCleaned"] as String);
    }
    if (json["isUnderMaintenance"] != null) {
      icu.isUnderMaintenance = json["isUnderMaintenance"] as bool;
    }

    return icu;
  }
}
