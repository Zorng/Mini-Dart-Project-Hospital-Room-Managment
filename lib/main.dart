// main.dart

import 'package:room_management/domain/bed.dart';
import 'package:room_management/domain/enums.dart';
import 'package:room_management/domain/patient.dart'; 
import 'package:room_management/domain/room_type.dart'; 
import 'package:room_management/domain/ward.dart'; 
import 'package:room_management/domain/icu.dart'; 
import 'package:room_management/domain/user.dart'; // REQUIRED for T20

void main() {
  print('--- Testing Hospital Domain Logic ---');

  // --- SETUP DATA ---
  
  // Basic Patients (T1-T6)
  var patientA = Patient('P101', 'Rafat', '012345678', Gender.female, Level.lv1);
  var patientB = Patient('P102', 'Sok', '012345678', Gender.male, Level.lv1);
  var stayID = 'STAY-001';
  
  // Policy Test Patients (T7-T19)
  var malePatient = Patient('P201', 'John', '555-1234', Gender.male, Level.lv2, requiresVentilator: false);
  var femalePatient = Patient('P202', 'Sarah', '555-5678', Gender.female, Level.lv2, requiresVentilator: false);
  var lv3Patient = Patient('P302', 'Linda', '555-2000', Gender.female, Level.lv3);
  var ventPatient = Patient('P303', 'Ray', '555-3000', Gender.male, Level.lv2, requiresVentilator: true);

  // Beds (T1-T6)
  var bed101 = Bed('B101'); 
  var bed102 = Bed('B102', status: BedAvailability.occupied); 
  var bed103 = Bed('B103'); 
  var bed104 = Bed('B104', status: BedAvailability.available); 

  // Wards (T7-T15)
  var roomTypeSmall = RoomType.semiPrivate; // capacity: 2
  var mixedWard = Ward('W101', roomTypeSmall, GenderPolicy.mixed);
  var maleWard = Ward('W102', roomTypeSmall, GenderPolicy.maleOnly);
  var femaleWard = Ward('W103', roomTypeSmall, GenderPolicy.femaleOnly);
  var testWard = Ward('W200', RoomType.shared, GenderPolicy.mixed); // For T11-T15 status tests
  
  // ICUs (T16-T19)
  var icuA = ICU('I101', RoomType.semiPrivate, GenderPolicy.mixed, true, true, Level.lv2); // LV2, Has Vent
  var icuB = ICU('I102', RoomType.semiPrivate, GenderPolicy.mixed, false, true, Level.lv2); // LV2, NO Vent
  
  // User (T20)
  var adminUser = User('U001', 'Admin', '111', Gender.male, 'hash123'); // For T20 User test

  // --- BED LIFECYCLE TESTS (T1-T6) ---
  print('\n--- TESTING BED LIFECYCLE (T1-T6) ---');
  
  // TEST 1: positive (Assign)
  print('\n[TEST 1: ASSIGN] Testing assignment to an AVAILABLE bed (B101)...');
  try{ bed101.assignPatient(patientA, stayID); assert(bed101.status == BedAvailability.occupied, 'FAIL: Status should be Occupied.'); print('SUCCESS: Bed B101 assigned correctly. Status: ${bed101.status.name}'); }
  catch (e){ print('FAILURE: Test 1 should not have thrown an exception. Error: $e'); }

  // TEST 2: negative (Assign)
  print('\n[TEST 2: ASSIGN] Testing assignment to an OCCUPIED bed (B102)...');
  try{ bed102.assignPatient(patientB, 'STAY-002'); print('FAILURE: Test 2 should have thrown an exception, but it did not.'); }
  catch (e){ if (e.toString().contains('is not available')) { print('SUCCESS: Exception caught correctly.'); } else { print('FAILURE: Caught an unexpected exception: $e'); } }

  // Test 3: positive (Discharge) 
  print('\n[TEST 3: DISCHARGE] Testing discharge from an OCCUPIED bed (B101)...');
  try { bed101.dischargePatient(); assert(bed101.status == BedAvailability.needCleaning, 'FAIL: Status should be NeedCleaning.'); print('SUCCESS: Bed B101 discharged correctly.'); } 
  catch (e) { print('FAILURE: Test 3 should not have thrown an exception. Error: $e'); }

  // Test 4: negative (Discharge)
  print('\n[TEST 4: DISCHARGE] Testing discharge from an AVAILABLE bed (B103)...');
  try { bed103.dischargePatient(); print('FAILURE: Test 4 should have thrown an exception, but it did not.'); } 
  catch (e) { if (e.toString().contains('Bed is not occupied')) { print('SUCCESS: Exception caught correctly.'); } else { print('FAILURE: Caught an unexpected exception: $e'); } }
  
  // TEST 5: positive (Mark Cleaned) 
  print('\n[TEST 5: CLEANING] Testing markCleaned() on a NEEDCLEANING bed (B101)...');
  try { bed101.markCleaned(); assert(bed101.status == BedAvailability.available, 'FAIL: Status should be Available.'); print('SUCCESS: Bed B101 cleaned and ready. Status: ${bed101.status.name}'); } 
  catch (e) { print('FAILURE: Test 5 should not have thrown an exception. Error: $e'); }

  // TEST 6: negative (Mark Cleaned)
  print('\n[TEST 6: CLEANING] Testing markCleaned() on an AVAILABLE bed (B104)...');
  try { bed104.markCleaned(); print('FAILURE: Test 6 should have thrown an exception, but it did not.'); } 
  catch (e) { if (e.toString().contains('is not marked for cleaning')) { print('SUCCESS: Exception caught correctly.'); } else { print('FAILURE: Caught an unexpected exception: $e'); } }
  
  // --- WARD ADMISSION POLICY TESTS (T7-T10) ---
  print('\n--- TESTING WARD POLICIES (T7-T10) ---');

  // T7: Mixed Policy Ward
  assert(mixedWard.canAdmit(malePatient) == true, 'FAIL T7a: Mixed Ward should admit male.');
  assert(mixedWard.canAdmit(femalePatient) == true, 'FAIL T7b: Mixed Ward should admit female.');
  print('SUCCESS T7: Mixed Ward policies verified.');

  // T8: Male-Only Policy Ward
  assert(maleWard.canAdmit(malePatient) == true, 'FAIL T8a: Male-Only Ward should admit male.');
  assert(maleWard.canAdmit(femalePatient) == false, 'FAIL T8b: Male-Only Ward should deny female.');
  print('SUCCESS T8: Male-Only Ward policies verified.');

  // T9: Female-Only Policy Ward
  assert(femaleWard.canAdmit(femalePatient) == true, 'FAIL T9a: Female-Only Ward should admit female.');
  assert(femaleWard.canAdmit(malePatient) == false, 'FAIL T9b: Female-Only Ward should deny male.');
  print('SUCCESS T9: Female-Only Ward policies verified.');

  // T10: Availability Check
  maleWard.admitPatient(malePatient); // Bed 1 used
  maleWard.admitPatient(malePatient); // Bed 2 used
  assert(maleWard.canAdmit(malePatient) == false, 'FAIL T10: Ward should be full and deny admission.');
  print('SUCCESS T10: Ward capacity check verified.');

  // --- ROOM STATUS DERIVATION TESTS (T11-T15) ---
  print('\n--- TESTING ROOM STATUS (T11-T15) ---');
  
  // T11: Initial Status Check
  assert(testWard.overallStatus == 'Ready', 'FAIL T11: Initial status should be Ready.');
  print('SUCCESS T11: Initial status verified.');

  // T12: Full Status Check
  testWard.admitPatient(malePatient); // 1st Bed
  testWard.admitPatient(malePatient); // 2nd Bed
  testWard.admitPatient(malePatient); // 3rd Bed
  testWard.admitPatient(malePatient); // 4th Bed (Full)
  assert(testWard.overallStatus == 'Full', 'FAIL T12: Status should be Full.');
  print('SUCCESS T12: Full status verified.');
  
  // T13: Needs Cleaning Check
  testWard.beds[0].dischargePatient(); // First bed needs cleaning
  assert(testWard.overallStatus == 'Needs Cleaning', 'FAIL T13: Status should be Needs Cleaning.');
  print('SUCCESS T13: Needs Cleaning status verified.');
  
  // T14: Maintenance Check
  testWard.markForMaintenance();
  assert(testWard.overallStatus == 'Maintenance', 'FAIL T14: Status should be Maintenance.');
  assert(testWard.isAvailable == false, 'FAIL T14b: Room should be unavailable during maintenance.');
  testWard.clearMaintenance();
  print('SUCCESS T14: Maintenance status and availability verified.');
  
  // T15: Mixed Status Check (Available + Occupied)
  testWard.beds[0].markCleaned(); // Now have 3 occupied, 1 available
  assert(testWard.overallStatus == 'Mixed', 'FAIL T15: Status should be Mixed (Available/Occupied).');
  print('SUCCESS T15: Mixed status verified.');


  // --- ICU ADMISSION POLICY TESTS (T16-T19) ---
  print('\n--- TESTING ICU POLICIES (T16-T19) ---');

  // T16: Positive Match (Level and Resources)
  assert(icuA.canAdmit(malePatient) == true, 'FAIL T16: Should admit matching LV2 patient.');
  print('SUCCESS T16: Full ICU match verified.');

  // T17: Negative Match (Acuity Level Mismatch)
  assert(icuA.canAdmit(lv3Patient) == false, 'FAIL T17: Should deny LV3 patient to LV2 ICU.');
  print('SUCCESS T17: Acuity Level Mismatch verified.');

  // T18: Negative Match (Ventilator Resource Mismatch)
  assert(icuB.canAdmit(ventPatient) == false, 'FAIL T18: Should deny Vent patient to ICU without vent.');
  print('SUCCESS T18: Resource Mismatch verified.');
  
  // T19: Full Admission Check
  try {
      icuA.admitPatient(malePatient);
      print('SUCCESS T19: ICU Patient admitted successfully.');
  } catch (e) {
      print('FAILURE T19: Admission failed unexpectedly. Error: $e');
  }
  
  // --- USER INHERITANCE TEST (T20) ---
  print('\n--- TESTING USER INHERITANCE (T20) ---');
  
  // T20: Check if User inherits properties from People and defines methods
  assert(adminUser.name == 'Admin', 'FAIL T20a: User failed to inherit name from People.');
  assert(adminUser.gender == Gender.male, 'FAIL T20b: User failed to inherit gender from People.');
  assert(adminUser.logIn(phone: '111', password: 'xyz') == false, 'FAIL T20c: Login method should return false placeholder.');
  print('SUCCESS T20: User inheritance and basic method definitions verified.');


  print('\n--- ALL 20 DOMAIN POLICY TESTS COMPLETE ---');
}