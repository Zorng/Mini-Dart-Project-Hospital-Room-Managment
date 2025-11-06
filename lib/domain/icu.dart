import 'room.dart';
import 'bed.dart';
import 'enums.dart';
import 'room_type.dart';
import 'patient.dart';
import 'patient_stay.dart';

class ICU extends Room {
  final bool hasVentilator;
  final bool hasCardiacMonitor;
  final Level level;

  ICU({
    required String roomNumber,
    required RoomType type,
    required List<Bed> beds,
    required GenderPolicy genderPolicy,
    required this.hasVentilator,
    required this.hasCardiacMonitor,
    required this.level,
    DateTime? lastCleaned,
    bool isUnderMaintenance = false,
  }) : super(
         roomNumber: roomNumber,
         type: type,
         beds: beds,
         genderPolicy: genderPolicy,
         lastCleaned: lastCleaned,
         isUnderMaintenance: isUnderMaintenance,
       );

  @override
  bool canAdmit(Patient patient) {
    if (!isAvailable) {
      print(
        'Admission denied for ${patient.name}: ICU $roomNumber is full or under maintenance.',
      );
      return false;
    }

    if ((genderPolicy == GenderPolicy.maleOnly &&
            patient.gender != Gender.male) ||
        (genderPolicy == GenderPolicy.femaleOnly &&
            patient.gender != Gender.female)) {
      print(
        'Admission denied for ${patient.name}: Gender policy violation in ICU $roomNumber.',
      );
      return false;
    }

    // Acuity level check
    // if (patient.requiredAcuity.index > acuityLevel.index) {
    //   print(
    //     'Admission denied for ${patient.name}: Acuity mismatch (Patient requires ${patient.requiredAcuity.name}, ICU is only ${acuityLevel.name}).',
    //   );
    //   return false;
    // }

    // Ventilator resource check
    // if (patient.requiresVentilator && !hasVentilator) {
    //   print(
    //     'Admission denied for ${patient.name}: Patient requires ventilator, but ICU $roomNumber does not have one.',
    //   );
    //   return false;
    // }

    return true;
  }

  @override
  PatientStay admitPatient(Patient patient) {
    if (!canAdmit(patient)) {
      throw Exception('Admission failed for ${patient.name} to ICU $roomNumber due to failed policies.');
    }

    Bed targetBed = beds.firstWhere(
      (bed) => bed.isAvailable,
      orElse: () => throw Exception(
        'Critical Error: ICU $roomNumber passed canAdmit() but found no free beds.',
      ),
    );

    // create a new PatientStay record
    final newStay = PatientStay(
      stayId: 'S${DateTime.now().microsecondsSinceEpoch}',
      patientId: patient.id,
      assignedBedId: targetBed.bedId,
      assignedDate: DateTime.now(),
      roomRateSnapshot: type,
      roomNumberSnapshot: roomNumber,
      acuitySnapshot: level,
    );

    newStay.currentPatient = patient;
    newStay.assignedBed = targetBed;

    // assign patient to the bed
    targetBed.assignPatient(patient, newStay);
    print('Patient ${patient.name} admitted to ICU $roomNumber, Bed ${targetBed.bedId}.');

    return newStay;
  }

  @override
  Map<String, dynamic> toJson() {
    // Merge base Room data (including the 'beds' list) with ICU specific data
    return {
      ...super.toJson(),
      "hasVentilator": hasVentilator,
      "hasCardiacMonitor": hasCardiacMonitor,
      "level": level.name,
    };
  }

  static String _cleanRoomType(String rawType) {
    final String noHyphen = rawType.replaceAll('-', '').toLowerCase();

    switch (noHyphen) {
      case 'semiprivate':
        // Fixes case for 'semiPrivate' enum member
        return 'semiPrivate';
      case 'vip':
        // Fixes case for 'vip' enum member
        return 'vip';
      case 'shared':
      case 'private':
        return noHyphen;
      default:
        return noHyphen;
    }
  }

  static ICU fromJson(Map<String, dynamic> json) {
    // Helper functions to convert string names back to enums
    final String? typeString = json["type"] as String?;
    if (typeString == null) {
      throw ArgumentError('Missing required key "type" for ICU.');
    }

    final String cleanedTypeString = _cleanRoomType(typeString);
    final RoomType type = RoomType.values.byName(cleanedTypeString);

    final String? genderString = json["gender"] as String?;
    if (genderString == null) {
      throw ArgumentError('Missing required key "gender" for ICU.');
    }
    final GenderPolicy policy = GenderPolicy.values.byName(genderString);

    final String? levelString = json["level"] as String?;
    if (levelString == null) {
      throw ArgumentError('Missing required key "level" for ICU.');
    }
    final Level level = Level.values.byName(levelString.toLowerCase());

    final List<Bed> beds = (json["beds"] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((bedMap) => Bed.fromJson(bedMap))
        .toList();

    DateTime? parseDate(String? dateString) => dateString != null ? DateTime.parse(dateString) : null;

    final bool hasVentilator = json["hasVentilator"] as bool? ?? false;
    final bool hasCardiacMonitor = json["hasCardiacMonitor"] as bool? ?? false;

    return ICU(
      roomNumber: json["roomNumber"] as String,
      type: type,
      beds: beds,
      genderPolicy: policy,
      hasVentilator: hasVentilator,
      hasCardiacMonitor: hasCardiacMonitor,
      level: level,
      lastCleaned: parseDate(json["lastCleaned"] as String?),
      isUnderMaintenance: json["isUnderMaintenance"] as bool? ?? false,
    );
  }
}
