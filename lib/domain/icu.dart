import 'room.dart';
import 'bed.dart';
import 'enums.dart';
import 'room_type.dart';
import 'patient.dart';
import 'patient_stay.dart';

class ICU extends Room {
  final bool hasVentilator;
  final bool hasCardiacMonitor;
  final Level acuityLevel;

  ICU({
    required String roomNumber,
    required RoomType type,
    required List<Bed> beds,
    required GenderPolicy genderPolicy,
    required this.hasVentilator,
    required this.hasCardiacMonitor,
    required this.acuityLevel,
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
  void admitPatient(Patient patient) {
    if (!canAdmit(patient)) {
      return;
    }

    Bed targetBed = beds.firstWhere(
      (bed) => bed.isAvailable,
      orElse: () => throw Exception(
        'Critical Error: ICU $roomNumber passed canAdmit() but found no free beds.',
      ),
    );

    // create a new PatientStay record
    final newStay = PatientStay(
      stayId: 'STAY-${DateTime.now().microsecondsSinceEpoch}',
      patientId: patient.id,
      assignedBedId: targetBed.bedId,
      assignedDate: DateTime.now(),
      roomRateSnapshot: type,
      roomNumberSnapshot: roomNumber,
      acuitySnapshot: acuityLevel,
    );

    // assign patient to the bed
    targetBed.assignPatient(patient, newStay);
    print('Patient ${patient.name} admitted to ICU $roomNumber, Bed ${targetBed.bedId}.');
  }

  @override
  Map<String, dynamic> toJson() {
    // Merge base Room data (including the 'beds' list) with ICU specific data
    return {
      ...super.toJson(),
      "hasVentilator": hasVentilator,
      "hasCardiacMonitor": hasCardiacMonitor,
      "acuityLevelName": acuityLevel.name,
    };
  }

  static ICU fromJson(Map<String, dynamic> json) {
    // Helper functions to convert string names back to enums
    final RoomType type = RoomType.values.byName(json["type"] as String);
    final GenderPolicy policy = GenderPolicy.values.byName(json["gender"] as String);
    final Level level = Level.values.byName(json["acuityLevelName"] as String);

    final List<Bed> beds = (json["beds"] as List)
        .cast<Map<String, dynamic>>()
        .map((bedMap) => Bed.fromJson(bedMap))
        .toList();

    DateTime? parseDate(String? dateString) => dateString != null ? DateTime.parse(dateString) : null;

    return ICU(
      roomNumber: json["roomNumber"] as String,
      type: type,
      beds: beds,
      genderPolicy: policy,
      hasVentilator: json["hasVentilator"] as bool,
      hasCardiacMonitor: json["hasCardiacMonitor"] as bool,
      acuityLevel: level,
      lastCleaned: parseDate(json["lastCleaned"] as String?),
      isUnderMaintenance: json["isUnderMaintenance"] as bool? ?? false,
    );
  }
}
