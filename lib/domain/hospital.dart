import 'enums.dart';
import 'bed.dart';
import 'patient.dart';
import 'patient_stay.dart';
import 'room.dart';
import 'ward.dart';
import 'icu.dart';
import 'user.dart';

class Hospital {
  final List<Room> rooms;
  final List<Patient> patients;
  final List<PatientStay> stays;
  final List<User> users;

  // use map for fast lookup
  late final Map<String, Patient> _patientMap;
  late final Map<String, Bed> _bedMap;

  Hospital({
    required this.rooms,
    required this.patients,
    required this.stays,
    required this.users,
  }) {
    // initialize maps
    _patientMap = {for (var p in patients) p.id: p};
    _bedMap = {
      for (var room in rooms)
        for (var bed in room.beds) bed.bedId: bed,
    };
  }

  bool logIn({required String name, required String password}) {
    for (var u in users) {
      if (u.name == name && u.passwordHash == password) return true;
    }
    return false;
  }

  Patient createPatient({
    required String id,
    required String name,
    required String phone,
    required Gender gender,
    required DateTime dob,
  }) {

    // create new patient
    final newPatient = Patient(
      id: id,
      name: name,
      phone: phone,
      gender: gender,
      dob: dob,
    );

    patients.add(newPatient);
    return newPatient;
  }

  // resolveReferences used for link all related obj after load from JSON
  void resolveReferences() {
    print('Starting Reference Resolution');
    // link patientStay to patient and bed
    for (var stay in stays) {
      // find and link patient
      final patient = _patientMap[stay.patientId];
      if (patient == null) {
        print(
          'Warning: Patient ID ${stay.patientId} not found for Stay ${stay.stayId}.',
        );
        continue;
      }
      stay.currentPatient = patient;

      // find and link bed
      final bed = _bedMap[stay.assignedBedId];
      if (bed == null) {
        print(
          'Warning: Bed ID ${stay.assignedBedId} not found for Stay ${stay.stayId}.',
        );
        continue;
      }
      stay.assignedBed = bed;

      // link bed to active patientStay and patient
      if (stay.isActive) {
        // if the stay is active, bed must reflect current occupancy
        if (bed.status != BedAvailability.occupied) {
          bed.status = BedAvailability.occupied;
        }
        bed.currentPatient = patient;
        bed.currentStayId = stay;

        print(
          'Linked active Stay ${stay.stayId} to Bed ${bed.bedId} and Patient ${patient.name}.',
        );
      }
    }
    print('Reference Resolution Complete');
  }

  // util lookup
  Bed? getBedById(String bedId) => _bedMap[bedId];
  Patient? getPatientById(String patientId) => _patientMap[patientId];

  // util to find all current occupied beds
  List<Bed> get occupiedBeds => _bedMap.values
      .where((b) => b.status == BedAvailability.occupied)
      .toList();

  // util to find all available rooms
  List<Room> get availableRooms => rooms.where((r) => r.isAvailable).toList();

  Room? getRoom({required String roomNumber}) {
    for (final r in rooms) {
      if (r.roomNumber == roomNumber) return r;
    }
    return null;
  }

  Ward? getWard({required String roomNumber}) {
    for (final r in rooms) {
      if (r.roomNumber == roomNumber) return r as Ward;
    }
    return null;
  }

  ICU? getIcu({required String roomNumber}) {
    for (final r in rooms) {
      if (r.roomNumber == roomNumber) return r as ICU;
    }
    return null;
  }


   
  // admission/discharge method
  void admitPatientToRoom({
    required Patient patient,
    required String roomNumber,
  }) {
    final room = rooms.firstWhere(
      (r) => r.roomNumber == roomNumber,
      orElse: () => throw Exception('Room $roomNumber not found.'),
    );
    final newStay = room.admitPatient(patient);
    stays.add(newStay);

    patient.markAssigned();
  }

  //AI refactored
  void dischargePatient({required String stayId}) {
  // 1) Find the stay record
  final stay = stays.firstWhere(
    (s) => s.stayId == stayId,
    orElse: () => throw Exception('Stay $stayId not found.'),
  );

  // 2) Check if already discharged
  if (!stay.isActive) {
    throw Exception('Stay $stayId has already been discharged.');
  }

  // 3) Resolve patient and bed references safely
  final patient = stay.currentPatient ??
      patients.firstWhere(
        (p) => p.id == stay.patientId,
        orElse: () => throw Exception(
          'Critical Data Error: Patient ${stay.patientId} not found for stay $stayId.',
        ),
      );

  Bed? bed = stay.assignedBed;
  Room? room;

  if (bed == null) {
    // Find the bed in hospital rooms
    for (final r in rooms) {
      final hit = r.beds.where((b) => b.bedId == stay.assignedBedId).toList();
      if (hit.isNotEmpty) {
        bed = hit.first;
        room = r;
        break;
      }
    }
    if (bed == null) {
      throw Exception(
        'Critical Data Error: Bed ${stay.assignedBedId} not found for stay $stayId.',
      );
    }
  }

  room ??= rooms.firstWhere(
    (r) => r.beds.any((b) => b.bedId == bed!.bedId),
    orElse: () => throw Exception(
      'Critical Data Error: Bed ${bed!.bedId} not mapped to any room.',
    ),
  );

  // 4) Perform discharge
  stay.assignedBed ??= bed;
  stay.currentPatient ??= patient;

  stay.recordDischarge();   // mark stay as discharged
  bed.dischargePatient();   // mark bed available
  patient.markDischarged(); // update patient status

  // 5) Output summary
  print('--- Discharge Complete ---');
  print('Stay ID: ${stay.stayId}');
  print('Patient: ${patient.name} (${patient.id})');
  print('Bed: ${bed.bedId}');
  print('Room: ${room.roomNumber}');
  print('Discharged at: ${stay.dischargeDate}');
}
}
