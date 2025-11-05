import 'room.dart';
import 'bed.dart';
import 'enums.dart';
import 'room_type.dart';
import 'patient.dart';
import 'patient_stay.dart';

class Ward extends Room {
  Ward({
    required String roomNumber,
    required RoomType type,
    required List<Bed> beds,
    required GenderPolicy genderPolicy,
    DateTime? lastCleaned,
    bool isUnderMaintenance = false,
  }) : super(
         roomNumber: roomNumber,
         type: type,
         beds: beds,
         genderPolicy: (type.capacity == 1) ? GenderPolicy.mixed : genderPolicy,
         lastCleaned: lastCleaned,
         isUnderMaintenance: isUnderMaintenance,
       );

  @override
  bool canAdmit(Patient patient) {
    // Check basic room availability
    if (!isAvailable) {
      print(
        'Admission denied for ${patient.name}: Room $roomNumber is full or under maintenance.',
      );
      return false;
    }

    // Check gender policy
    if (genderPolicy == GenderPolicy.mixed) {
      return true;
    }

    // Check male and female only
    if ((genderPolicy == GenderPolicy.maleOnly &&
            patient.gender == Gender.male) ||
        (genderPolicy == GenderPolicy.femaleOnly &&
            patient.gender == Gender.female)) {
      return true;
    }

    print(
      'Admission denied for ${patient.name}: Gender policy violation in $roomNumber (${genderPolicy.name} only).',
    );
    return false;
  }

  @override
  void admitPatient(Patient patient) {
    if (!canAdmit(patient)) {
      return;
    }

    // Find first available bed
    Bed targetBed = beds.firstWhere(
      (bed) => bed.isAvailable,
      orElse: () => throw Exception(
        'Critical Error: Room $roomNumber passed canAdmit() but found no free beds.',
      ),
    );

    // create a new PatientStay record
    final newStay = PatientStay(
      stayId: 'STAY-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patient.id,
      assignedBedId: targetBed.bedId,
      assignedDate: DateTime.now(),
      roomRateSnapshot: type,
      roomNumberSnapshot: roomNumber,
    );

    // assign patient to the bed
    targetBed.assignPatient(patient, newStay);

    print(
      'Patient ${patient.name} admitted to Ward $roomNumber, Bed ${targetBed.bedId}.',
    );
  }

  static Ward fromJson(Map<String, dynamic> json) {
    final RoomType type = RoomType.values.byName(json["type"] as String);
    final GenderPolicy policy = GenderPolicy.values.byName(json["gender"] as String);

    final List<Bed> beds = (json["beds"] as List)
        .cast<Map<String, dynamic>>()
        .map((bedMap) => Bed.fromJson(bedMap))
        .toList();

    DateTime? parseDate(String? dateString) => dateString != null ? DateTime.parse(dateString) : null;

    return Ward(
      roomNumber: json["roomNumber"] as String,
      type: type,
      beds: beds,
      genderPolicy: policy,
      lastCleaned: parseDate(json["lastCleaned"] as String?),
      isUnderMaintenance: json["isUnderMaintenance"] as bool? ?? false,
    );
  }
}
