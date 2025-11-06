import 'package:room_management/data/data_reader.dart';
import 'package:room_management/domain/enums.dart';
import 'package:test/test.dart';

import 'package:room_management/domain/hospital.dart';

//AI Generated test case from flow of use and data provided by us
void main() async {
  Hospital hospital = await DataReader.readData();

  group('Hospital I/O', () {
    test('loads dataset from file', () {
      expect(hospital.rooms, isNotEmpty);
      expect(hospital.patients, isNotEmpty);
      expect(hospital.stays, isNotEmpty);
    });
  });

  group('Admit flow', () {
    test('admit a patient to a ready (available) WARD room', () {
      // Choose a female not assigned → dataset shows P016 as notAssigned (female)
      final patient = hospital.getPatientById('P016');
      expect(patient, isNotNull);
      expect(
        patient!.status,
        anyOf(PatientStatus.notAssigned, PatientStatus.discharged),
      );

      // Female-only ward with available beds in your data: A003
      final room = hospital.getRoom(roomNumber: 'A003');
      expect(room, isNotNull);
      // Ensure policy is femaleOnly (optional if your API exposes it)
      expect(room!.genderPolicy, equals(GenderPolicy.femaleOnly));

      // Ensure at least one available bed
      final hasAvailable = room.beds.any(
        (b) => b.status == BedAvailability.available,
      );
      expect(hasAvailable, isTrue, reason: 'A003 should have an available bed');

      // Act
      hospital.admitPatientToRoom(
        patient: patient,
        roomNumber: room.roomNumber,
      );

      // Assert: patient now assigned
      expect(patient.status, equals(PatientStatus.assigned));

      // And one of A003’s beds occupied
      final occupiedCount = room.beds
          .where((b) => b.status == BedAvailability.occupied)
          .length;
      expect(occupiedCount, greaterThanOrEqualTo(1));

      // And an active stay exists for this patient
      final activeStays = hospital.stays
          .where((s) => s.patientId == patient.id && s.isActive)
          .toList();
      expect(activeStays, isNotEmpty);
    });

    test('admit to a FULL room (no available beds) should fail', () {
      // B004 is private with single bed B00401 that is occupied in your data → full
      final patient = hospital.getPatientById('P017'); // female, notAssigned
      expect(patient, isNotNull);

      expect(
        () =>
            hospital.admitPatientToRoom(patient: patient!, roomNumber: 'B004'),
        throwsA(isA<Exception>()),
      );
    });

    test('admit to a room UNDER MAINTENANCE should fail', () {
      final patient = hospital.getPatientById('P017');
      expect(patient, isNotNull);

      final room = hospital.getRoom(roomNumber: 'A002');
      expect(room, isNotNull);

      // Temporarily mark maintenance for the test
      final originalMaintenance = room!.isUnderMaintenance;
      room.isUnderMaintenance = true;

      expect(
        () => hospital.admitPatientToRoom(
          patient: patient!,
          roomNumber: room.roomNumber,
        ),
        throwsA(isA<Exception>()),
      );

      // restore state to avoid side-effects
      room.isUnderMaintenance = originalMaintenance;
    });

    test('admit a patient of WRONG GENDER should fail', () {
      // Try to admit a male into female-only ward A003
      final patient = hospital.getPatientById('P018'); // male (discharged)
      expect(patient, isNotNull);
      expect(patient!.gender, equals(Gender.male));

      final room = hospital.getRoom(roomNumber: 'A003');
      expect(room, isNotNull);
      expect(room!.genderPolicy, equals(GenderPolicy.femaleOnly));

      expect(
        () => hospital.admitPatientToRoom(patient: patient, roomNumber: 'A003'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Discharge flow', () {
    test('check stay/bed/patient/room before and after discharge', () {
      // Use an active stay from your dataset: S001 (P001 in A00102) is active
      const stayId = 'S001';
      final stay = hospital.stays.firstWhere((s) => s.stayId == stayId);
      expect(stay.isActive, isTrue);

      // Resolve patient and bed using helpers
      final patient = hospital.getPatientById(stay.patientId);
      expect(patient, isNotNull);

      final bed = hospital.getBedById(stay.assignedBedId);
      expect(bed, isNotNull);
      expect(bed!.status, equals(BedAvailability.occupied));

      // Find the room that contains this bed
      final room = hospital.rooms.firstWhere(
        (r) => r.beds.any((b) => b.bedId == bed.bedId),
        orElse: () => throw Exception('Room not found for bed ${bed.bedId}'),
      );

      // Pre-condition checks
      expect(room.overallStatus, anyOf('Full', 'Ready'));
      expect(
        patient!.status,
        anyOf(
          PatientStatus.assigned,
          PatientStatus.notAssigned,
          PatientStatus.discharged,
        ),
      );

      // Act
      hospital.dischargePatient(stayId: stayId);

      // Post: stay should be closed
      final stayAfter = hospital.stays.firstWhere((s) => s.stayId == stayId);
      expect(stayAfter.isActive, isFalse);
      expect(stayAfter.dischargeDate, isNotNull);

      // Bed should require cleaning after discharge
      final bedAfter = hospital.getBedById(stay.assignedBedId);
      expect(bedAfter, isNotNull);
      expect(bedAfter!.status, equals(BedAvailability.needCleaning));

      // Patient should now be discharged
      final patientAfter = hospital.getPatientById(stay.patientId);
      expect(patientAfter, isNotNull);
      expect(patientAfter!.status, equals(PatientStatus.discharged));

      // Room overall status should now be "Needs Cleaning"
      final roomAfter = hospital.rooms.firstWhere(
        (r) => r.beds.any((b) => b.bedId == bed.bedId),
      );
      expect(roomAfter.overallStatus, equals('Needs Cleaning'));
    });
  });

  group('Billing after discharge', () {
  test('shared room: S024 bills one day (\$60.00) due to min-1-day rule', () {
    // S024: shared, ~17h stay -> min 1 day
    final stay = hospital.stays.firstWhere((s) => s.stayId == 'S024');
    expect(stay.isActive, isFalse);                 // already discharged in dataset
    expect(stay.dischargeDate, isNotNull);
    expect(stay.roomRateSnapshot.name, equals('shared'));

    final bill = stay.getPatientStayBill();
    expect(bill, equals(60.0));                     // 6000 cents / day -> $60.00
  });

  test('private room: S026 bills one day (\$200.00) due to min-1-day rule', () {
    // S026: private, ~22h stay -> min 1 day
    final stay = hospital.stays.firstWhere((s) => s.stayId == 'S026');
    expect(stay.isActive, isFalse);
    expect(stay.dischargeDate, isNotNull);
    expect(stay.roomRateSnapshot.name, equals('private'));

    final bill = stay.getPatientStayBill();
    expect(bill, equals(200.0));                    // 20000 cents / day -> $200.00
  });
});
}
