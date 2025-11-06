import 'dart:convert';
import 'dart:io';
import 'package:room_management/domain/hospital.dart';
import 'package:room_management/domain/patient.dart';
import 'package:room_management/domain/patient_stay.dart';
import 'package:room_management/domain/room.dart';
import 'package:room_management/domain/ward.dart';
import 'package:room_management/domain/icu.dart';
import 'package:room_management/domain/user.dart';
void main() async {
  Hospital hospital = await DataReader.readData();
}

class DataReader {
  static const String _dataFile = 'lib/data/hospital_data.json';

  static Future<Hospital> readData() async{
    try{
      final file = File(_dataFile);
      if(!await file.exists()){
        print('Warning: Data file not found at $_dataFile. Initializing empty Hospital.');
        return Hospital(rooms: [], patients: [], stays: [], users: []);
      }

      final String jsonString = await file.readAsString();
      final Map<String, dynamic> data = json.decode(jsonString);

      final List<Patient> patients = (data['patients'] as List? ?? [])
          .map((jsonMap) => Patient.fromJson(jsonMap))
          .toList();
      
      // patients.forEach(print);

      final List<User> users = (data['users'] as List? ?? [])
          .map((jsonMap) => User.fromJson(jsonMap))
          .toList();

      // users.forEach(print);

      final List<PatientStay> stays = (data['stays'] as List? ?? [])
          .map((jsonMap) => PatientStay.fromJson(jsonMap))
          .toList();
      
      final List<Room> rooms = [];

      final List<dynamic> roomContainers = (data['rooms'] as List? ?? []);
      
      for (final containerMap in roomContainers) {
        if (containerMap is Map<String, dynamic>) {
          // 1. Load Wards from the inner 'wards' list
          final List<dynamic> wardJsons = (containerMap['wards'] as List? ?? []);
          for (final jsonMap in wardJsons.cast<Map<String, dynamic>>()) {
            rooms.add(Ward.fromJson(jsonMap));
          }

          // 2. Load ICUs from the inner 'icus' list
          final List<dynamic> icuJsons = (containerMap['icus'] as List? ?? []);
          for (final jsonMap in icuJsons.cast<Map<String, dynamic>>()) {
            rooms.add(ICU.fromJson(jsonMap));
          }
        }
      }

      final hospital = Hospital(
        rooms: rooms,
        patients: patients,
        stays: stays,
        users: users,
      );

      hospital.resolveReferences();

      print('Data successfully loaded from $_dataFile');
      return hospital;
    }
    catch(e, stackTrace){
      print('Error reading data from $_dataFile: $e');
      print(stackTrace);
      rethrow;
    }
  }

  static Future<void> writeData(Hospital hospital) async{
    final wards = hospital.rooms.whereType<Ward>().cast<Ward>().toList();
    final icus = hospital.rooms.whereType<ICU>().cast<ICU>().toList();
    try{
      final Map<String, dynamic> data = {
        'rooms': [
          {
            'wards': wards.map((w) => w.toJson()).toList()
          },
          {
            'icus': icus.map((i) => i.toJson()).toList()
          }
        ],
        'patients': hospital.patients.map((patient) => patient.toJson()).toList(),
        'stays': hospital.stays.map((stay) => stay.toJson()).toList(),
        'users': hospital.users.map((user) => user.toJson()).toList(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(data);
      final file = File('lib/data/output.json');

      await file.writeAsString(jsonString);
      print('Data successfully written to $_dataFile');
    }
    catch(e){
      print('Error writing data to $_dataFile: $e');
    }
  }
}

