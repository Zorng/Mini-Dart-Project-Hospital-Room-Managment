import 'enums.dart';
import 'bed.dart';
import 'patient.dart';
import 'patient_stay.dart';
import 'room.dart';
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
    required String name,
    required String phone,
    required Gender gender,
    required DateTime dob,
  }) {
    final newId = 'P-${DateTime.now().millisecondsSinceEpoch}';

    // create new patient
    final newPatient = Patient(
      id: newId,
      name: name,
      phone: phone,
      gender: gender,
      dob: dob,
    );

    patients.add(newPatient);
    _patientMap[newId] = newPatient;

    print('✅ Patient ${newPatient.name} created with ID $newId.');
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

  void dischargePatient({required String patientId}) {
    // find active stay
    final activeStays = stays
        .where((s) => s.patientId == patientId && s.isActive)
        .toList();

    if (activeStays.isEmpty) {
      throw Exception(
        'Patient $patientId is not currently admitted (No active stay found).',
      );
    }

    final stay = activeStays.reduce(
      (a, b) => a.assignedDate.isAfter(b.assignedDate) ? a : b,
    );

    final bed = stay.assignedBed;
    final patient = stay.currentPatient;

    if (bed == null || patient == null) {
      throw Exception(
        'Critical Data Error: Stay ${stay.stayId} has unlinked Patient or Bed.',
      );
    }

    stay.recordDischarge(); // trigger discharge on PatientStay
    bed.dischargePatient(); // trigger discharge on Bed
    patient.markDischarged(); // update patient status

    // Find the room the bed belongs to for status check
    final room = rooms.firstWhere(
      (r) => r.beds.any((b) => b.bedId == bed.bedId),
      orElse: () => throw Exception(
        'Critical Data Error: Bed ${bed.bedId} not found in any room list.',
      ),
    );

    print('--- Discharge Complete ---');
    print(
      'Patient ${patient.name} discharged from Bed ${bed.bedId} in Room ${room.roomNumber}.',
    );
    print('Room ${room.roomNumber} status: ${room.overallStatus}');
  }
}
