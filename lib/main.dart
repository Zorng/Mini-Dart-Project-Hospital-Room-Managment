import 'package:room_management/domain/bed.dart';
import 'package:room_management/domain/enums.dart';

void main() {
  print('--- Testing Bed Methods ---');
  // AI GENERATED
  // Setup Data
  var patientA = Patient('P101', 'Rafat','012345678', GenderPolicy.FemaleOnly);
  var patientB = Patient('P102', 'Sok', '012345678', GenderPolicy.MaleOnly);
  var stayID = 'STAY-001';

  // Beds for Testing
  var bed101 = Bed('B101'); // Used for a full lifecycle test
  var bed102 = Bed('B102', status: BedAvailability.Occupied); // Used for Assign negative test
  var bed103 = Bed('B103'); // Used for Discharge negative test
  var bed104 = Bed('B104', status: BedAvailability.Available); // Used for Clean negative test

  // --- ASSIGN TESTS ---

  // TEST 1: positive (Assign)
  print('\n[TEST 1: ASSIGN] Testing assignment to an AVAILABLE bed (B101)...');
  try{
    bed101.assignPatient(patientA, stayID);
    assert(bed101.status == BedAvailability.Occupied, 'FAIL: Status should be Occupied.');
    print('SUCCESS: Bed B101 assigned correctly. Status: ${bed101.status.name}');
  }
  catch (e){
    print('FAILURE: Test 1 should not have thrown an exception. Error: $e');
  }

  // TEST 2: negative (Assign)
  print('\n[TEST 2: ASSIGN] Testing assignment to an OCCUPIED bed (B102)...');
  try{
    bed102.assignPatient(patientB, 'STAY-002');
    print('FAILURE: Test 2 should have thrown an exception, but it did not.');
  }catch (e){
    if (e.toString().contains('is not available')) {
      print('SUCCESS: Exception caught correctly (Prevented assignment to occupied bed).');
    } else {
      print('FAILURE: Caught an unexpected exception: $e');
    }
  }

  // --- DISCHARGE TESTS ---
  
  // Test 3: positive (Discharge) - Use the bed from Test 1, which is now Occupied
  print('\n[TEST 3: DISCHARGE] Testing discharge from an OCCUPIED bed (B101)...');
  try {
    bed101.dischargePatient();
    assert(bed101.status == BedAvailability.NeedCleaning, 'FAIL: Status should be NeedCleaning.');
    assert(bed101.currentPatient == null, 'FAIL: currentPatient should be null.');
    print('SUCCESS: Bed B101 discharged correctly. Status: ${bed101.status.name}');
    
  } catch (e) {
    print('FAILURE: Test 3 should not have thrown an exception. Error: $e');
  }

  // Test 4: negative (Discharge)
  print('\n[TEST 4: DISCHARGE] Testing discharge from an AVAILABLE bed (B103)...');
  try {
    bed103.dischargePatient();
    print('FAILURE: Test 4 should have thrown an exception, but it did not.');
  } catch (e) {
    if (e.toString().contains('Bed is not occupied')) {
      print('SUCCESS: Exception caught correctly (Prevented discharge from free bed).');
    } else {
      print('FAILURE: Caught an unexpected exception: $e');
    }
  }
  
  // --- CLEANING TESTS (New) ---

  // TEST 5: positive (Mark Cleaned) - Use the bed from Test 3, which is now NeedCleaning
  print('\n[TEST 5: CLEANING] Testing markCleaned() on a NEEDCLEANING bed (B101)...');
  try {
    bed101.markCleaned();
    assert(bed101.status == BedAvailability.Available, 'FAIL: Status should be Available.');
    print('SUCCESS: Bed B101 cleaned and ready. Status: ${bed101.status.name}');
    
  } catch (e) {
    print('FAILURE: Test 5 should not have thrown an exception. Error: $e');
  }

  // TEST 6: negative (Mark Cleaned)
  print('\n[TEST 6: CLEANING] Testing markCleaned() on an AVAILABLE bed (B104)...');
  try {
    bed104.markCleaned();
    print('FAILURE: Test 6 should have thrown an exception, but it did not.');
  } catch (e) {
    if (e.toString().contains('is not marked for cleaning')) {
      print('SUCCESS: Exception caught correctly (Prevented cleaning an available bed).');
    } else {
      print('FAILURE: Caught an unexpected exception: $e');
    }
  }
}