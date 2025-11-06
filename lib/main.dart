import 'package:room_management/data/data_reader.dart';
import 'package:room_management/domain/hospital.dart';
import 'package:room_management/domain/enums.dart';

Future <void> main() async {
  print('Starting Hospital System Integration Test...');

  // --- A. DATA LOADING ---
  Hospital hospital = await DataReader.readData();

  // --- 1. INITIAL VALIDATION ---
  print('\n--- 1. Initial State Check ---');
  // We will use P009, who is loaded but not currently active in a bed.
  final testPatient = hospital.getPatientById('P009');
  final testRoomNumber = 'A001'; 
  final testBedId = 'A00101'; // Bed is currently 'available' in your JSON

  if (hospital.patients.isNotEmpty && hospital.rooms.isNotEmpty) {
    print('✅ Load Test: Data loaded successfully. Patients: ${hospital.patients.length}, Rooms: ${hospital.rooms.length}');
  } else {
    print('❌ Load Test FAILED: Data structure is empty. Check hospital_data.json content.');
    return;
  }

  if (testPatient == null) {
    // If P009 is missing, use P001, who is linked to S001. P001 will fail the admission test.
    print('❌ Critical Failure: Patient P009 not found. Check JSON data.');
    return;
  }
  
  // --- 2. ADMISSION TEST ---
  print('\n--- 2. Admission Workflow Test ---');
  try {
    // 2.1 Admit the patient
    hospital.admitPatientToRoom(patient: testPatient, roomNumber: testRoomNumber);
    print('✅ Admission: Patient ${testPatient.name} successfully admitted to $testRoomNumber (Bed $testBedId).');

    // 2.2 Validate post-admission state
    final bedToCheck = hospital.getBedById(testBedId);
    
    // Check if a new stay was created and the bed is occupied
    if (bedToCheck?.status == BedAvailability.occupied) {
      print('✅ Admission Validation: Bed $testBedId is now OCCUPIED.');
    } else {
      print('❌ Admission Validation FAILED: Bed status is incorrect (Expected OCCUPIED, found ${bedToCheck?.status}).');
      return;
    }
  } catch (e) {
    print('❌ Admission Test FAILED (Critical Logic Error): $e');
    return;
  }
  
  // --- 3. DISCHARGE TEST ---
  print('\n--- 3. Discharge Workflow Test ---');
  try {
    // 3.1 Discharge the patient (P009)
    hospital.dischargePatient(patientId: testPatient.id);
    print('✅ Discharge: Patient ${testPatient.name} successfully discharged.');

    // 3.2 Validate post-discharge state
    final bedToCheck = hospital.getBedById(testBedId);
    final finalStay = hospital.stays.firstWhere((s) => s.patientId == testPatient.id && s.dischargeDate != null, orElse: () => null as dynamic?);

    if (bedToCheck?.status == BedAvailability.needCleaning && finalStay != null) {
      print('✅ Discharge Validation: Bed $testBedId is NEED_CLEANING and PatientStay has recorded discharge date.');
    } else {
      print('❌ Discharge Validation FAILED: Bed status or discharge date missing.');
      print('Bed Status: ${bedToCheck?.status}');
     print('Discharge Recorded: ${finalStay != null}');
      return;
    }
  } catch (e) {
    print('❌ Discharge Test FAILED (Critical Logic Error): $e');
    return;
  }
  
  // --- 4. DATA WRITING ---
  print('\n--- 4. Persistence Test ---');
  await DataReader.writeData(hospital);
  print('✅ Persistence Test: Final state saved to data file.');
  
  print('\n--- ALL INTEGRATION TESTS PASSED ---');
}