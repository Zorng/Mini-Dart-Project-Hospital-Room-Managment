import 'dart:io';
import 'package:room_management/domain/enums.dart';
import 'package:room_management/domain/hospital.dart';
import 'package:room_management/domain/room.dart';
import 'package:room_management/domain/ward.dart';
import 'package:room_management/domain/icu.dart';
import 'package:room_management/domain/bed.dart';
import 'package:room_management/domain/patient.dart';
import 'package:room_management/domain/patient_stay.dart';
import 'package:room_management/ui/paginator.dart';
import 'package:room_management/ui/table.dart';

List<Column<Ward>> wardColumns = [
  Column<Ward>(title: "Room Number", width: 15, data: (r) => r.roomNumber),
  Column<Ward>(title: "Status", width: 15, data: (r) => r.overallStatus),
  Column<Ward>(title: "Type", width: 15, data: (r) => r.type.name.toString()),
  Column<Ward>(
    title: "Price \$",
    width: 15,
    data: (r) => (r.type.centPerDay / 100).toString(),
  ),
  Column<Ward>(
    title: "Gender Policy",
    width: 15,
    data: (r) => r.genderPolicy.toString(),
  ),
  Column<Ward>(
    title: "Available Beds",
    width: 15,
    data: (r) => r.freeBeds.toString(),
  ),
  Column<Ward>(
    title: "Last Cleaned",
    width: 15,
    data: (r) => r.lastCleaned.toString(),
  ),
];

List<Column<ICU>> icuColumns = [
  Column<ICU>(title: "Room Number", width: 15, data: (r) => r.roomNumber),
  Column<ICU>(title: "Status", width: 15, data: (r) => r.overallStatus),
  Column<ICU>(title: "Type", width: 15, data: (r) => r.type.name.toString()),
  Column<ICU>(
    title: "Price",
    width: 15,
    data: (r) => (r.type.centPerDay / 100).toString(),
  ),
  Column<ICU>(
    title: "Acuity Level",
    width: 15,
    data: (r) => r.level.toString(),
  ),
  Column<ICU>(
    title: "Last Cleaned",
    width: 14,
    data: (r) => r.lastCleaned.toString(),
  ),
];

List<Column<Bed>> bedColumn = [
  Column<Bed>(title: "Bed ID", width: 15, data: (r) => r.bedId),
  Column<Bed>(title: "Status", width: 15, data: (r) => r.status.toString()),
  Column<Bed>(
    title: "Last Cleaned",
    width: 15,
    data: (r) => r.lastClean.toString(),
  ),
  Column<Bed>(
    title: "Last Assigned",
    width: 15,
    data: (r) => r.lastAssigned.toString(),
  ),
];

List<Column<Patient>> patientColumn = [
  Column<Patient>(title: "Patient ID", width: 15, data: (r) => r.id),
  Column(title: "Status", width: 15, data: (r) => r.status.name),
  Column<Patient>(title: "Name", width: 15, data: (r) => r.name),
  Column<Patient>(title: "Gender", width: 15, data: (r) => r.gender.name),
  Column<Patient>(title: "DOB", width: 15, data: (r) => r.dob.toString()),
];

List<Column<PatientStay>> patientStayColumn = [
  Column<PatientStay>(title: "ID", width: 15, data: (r) => r.stayId),
  Column<PatientStay>(title: "Patient ID", width: 15, data: (r) => r.patientId),
  Column<PatientStay>(title: "Bed ID", width: 15, data: (r) => r.assignedBedId),
  Column<PatientStay>(
    title: "Assigned Date",
    width: 15,
    data: (r) => r.assignedDate.toString(),
  ),
  Column<PatientStay>(
    title: "Discharge Date",
    width: 15,
    data: (r) =>
        r.dischargeDate == null ? "not yet" : r.dischargeDate.toString(),
  ),
];

class AppConsole {
  Hospital hospital;

  AppConsole({required this.hospital});

  bool login() {
    String? name;
    String? pass;
    print("\nWelcome to Room Management System\n");
    stdout.write("Enter username: ");
    name = stdin.readLineSync();
    stdout.write("Enter password: ");
    pass = stdin.readLineSync();

    if (name == null || pass == null) return false;

    if (hospital.logIn(name: name, password: pass)) {
      print("ACCESS GRANTED");
      clearConsole();
      return true;
    } else {
      print("Incorrect credentials.\nPress 'Enter to try again'");
      clearConsole();
      return false;
    }
  }

  // AI refactored Code
  /// Generic selector + action executor.
  /// E  = entity type (Room, Patient, Bed, ...)
  /// R  = return type of your callback (int, void, bool, ...)
  R? selectAndDo<E, R>({
    String prompt = "Enter an id: ",
    String Function(String id)? normalize, // e.g., trim/uppercase
    required E? Function(String id) lookup, // how to find the entity
    required R Function(E entity) action, // what to do with it
    void Function(Object e)? onError, // optional error hook
    String Function(String id)? notFoundMessage, // custom message
  }) {
    try {
      stdout.write(prompt);
      final raw = stdin.readLineSync();
      if (raw == null) return null;

      final id = (normalize != null) ? normalize(raw) : raw;
      final entity = lookup(id);

      if (entity == null) {
        final msg = (notFoundMessage != null)
            ? notFoundMessage(id)
            : "Not found: $id";
        print(msg);
        return null;
      }

      return action(entity);
    } catch (e) {
      onError?.call(e);
      print("Error: $e");
      return null;
    }
  }

  void roomActionsSelect() {
    print(
      "\nactions:\n[1]. View Beds\n[2]. Put under maintenance\n[3]. Clear maintenance\n[q]. Back",
    );
    stdout.write("Enter an option: ");
    String? input = stdin.readLineSync();

    if (input == '1') {
      int? i = selectAndDo<Room, int>(
        prompt: "Select a room by room number",
        normalize: (s) => s.trim().toUpperCase(),
        lookup: (id) => hospital.getRoom(roomNumber: id),
        action: (room) => Paginator.paginate(
          Table<Bed>(
            title: "Beds of Room ${room.roomNumber}",
            items: room.beds,
            columns: bedColumn,
          ),
        ),
      );
      if (i == -1) {
        print("\nactions:\n[q]. Back");
        stdout.write("Enter an option: ");
        String? input = stdin.readLineSync();
        if (input == 'q') return;
      }
    } else if (input == '2') {
      selectAndDo<Room, void>(
        normalize: (s) => s.trim().toUpperCase(),
        prompt: "Select a room by room number: ",
        lookup: (id) => hospital.getRoom(roomNumber: id),
        action: (room) => room.markForMaintenance(),
      );

      stdin.readLineSync();
    } else if (input == '3') {
      selectAndDo<Room, void>(
        normalize: (s) => s.trim().toUpperCase(),
        prompt: "Select a room by room number: ",
        lookup: (id) => hospital.getRoom(roomNumber: id),
        action: (room) => room.clearMaintenance(),
      );
      stdin.readLineSync();
    }
  }

  void admitFlow() {
    Paginator.paginate(
      Table<Patient>(
        title: "List of not assigned patients",
        items: hospital.patients
            .where((r) => r.status == PatientStatus.notAssigned)
            .toList(),
        columns: patientColumn,
      ),
      eButtonTitle: "select patient"
    );
    selectAndDo<Patient, void>(
      prompt: "Enter patient id: ",
      normalize: (s) => s.trim().toUpperCase(),
      lookup: (id) => hospital.getPatientById(id),
      action: (patient) {
        if (patient.status == PatientStatus.assigned) {
          print("Patient ${patient.id} is already admitted.");
          return;
        }

        print("Assign to:\n[1]. Ward\n[2]. ICU");
        String? roomOption = stdin.readLineSync();
        if (roomOption != '1' && roomOption != '2' || roomOption == null) {
          return;
        }
        if (roomOption == '1') {
          Paginator.paginate(
            Table<Ward>(
              title: "List of Wards",
              items: hospital.rooms.whereType<Ward>().cast<Ward>().toList(),
              columns: wardColumns,
            ),
            eButtonTitle: "go to select room"
          );
        } else if (roomOption == '2') {
          Paginator.paginate(
            Table<ICU>(
              title: "List of ICU",
              items: hospital.rooms.whereType<ICU>().cast<ICU>().toList(),
              columns: icuColumns,
            ),
            eButtonTitle: "go to select room"
          );
        }

        selectAndDo<Room, void>(
          prompt: "Select a room by room number: ",
          normalize: (s) => s.trim().toUpperCase(),
          lookup: (id) => hospital.getRoom(roomNumber: id), // -> Room?
          action: (room) {
            try {
              hospital.admitPatientToRoom(
                patient: patient,
                roomNumber: room.roomNumber,
              );
              print("Admitted ${patient.name} to room ${room.roomNumber}");
              stdin.readLineSync();
            } catch (e) {
              print("Admit failed: $e");
              stdin.readLineSync();
            }
          },
          notFoundMessage: (id) => "Room $id not found.",
        );
      },
      notFoundMessage: (id) => "Patient $id not found.",
    );
  }

  void enlistPatient() {
    String id, name, phone, dateStr;
    DateTime? dob;
    Gender gender;
    String? value;
    print("Suggested ID P${hospital.patients.length + 1}");
    stdout.write("ID: ");
    value = stdin.readLineSync();
    id = value ?? '';
    stdout.write("Name: ");
    value = stdin.readLineSync();
    name = value ?? '';
    stdout.write("Gender: [1]. Male, [2]. Female\n");
    value = stdin.readLineSync();
    print("value $value");
    if (value != '1' && value != '2' || value == null) {
      print("Error: bad option.");
      return;
    } else {
      gender = value == '1' ? Gender.male : Gender.female;
    }
    stdout.write("Phone: ");
    value = stdin.readLineSync();
    phone = value ?? '';
    stdout.write("DOB (YYYY-MM-DD): ");
    value = stdin.readLineSync();
    if (value == null || value.isEmpty) {
      print("No date entered!");
      return;
    }

    dob = DateTime.parse(value);

    hospital.createPatient(
      id: id,
      name: name,
      phone: phone,
      gender: gender,
      dob: dob,
    );
    print("Successfully enlisted a patient");
  }

  //AI generated
  static void clearConsole() {
    if (Platform.isWindows) {
      // Windows ANSI support
      stdout.write('\x1B[2J\x1B[0;0H');
    } else {
      // macOS / Linux
      stdout.write('\x1B[2J\x1B[H');
    }
  }

  void console() {
    while (login() == false) {}

    while (true) {
      print('''

======================================
Menu
--------------------------------------
Enter number in the bracket to select.

[1]. Manage Wards
- View beds
- Maintenance Status

[2]. Manage ICU
- View beds
- Maintenance Status

[3]. Manage Patients
- View patients by status
- Create patients

[4]. Admit a patient to a room

[5]. Manage Patient Stays
- admit patient to room
- View patients by status
- Create patients Discharged 

[q]. Quit
''');
      stdout.write("Select: ");
      String? s = stdin.readLineSync();
      if (s != null && s.isNotEmpty) {
        switch (s) {
          case '1':
            {
              int i = Paginator.paginate(
                Table<Ward>(
                  title: "List of Wards",
                  items: hospital.rooms.whereType<Ward>().cast<Ward>().toList(),
                  columns: wardColumns,
                ),
              );
              if (i == -1) {
                roomActionsSelect();
              }
              break;
            }
          case '2':
            {
              int i = Paginator.paginate(
                Table<ICU>(
                  title: "List of ICU",
                  items: hospital.rooms.whereType<ICU>().cast<ICU>().toList(),
                  columns: icuColumns,
                ),
              );
              if (i == -1) {
                roomActionsSelect();
              }
            }

          case '3':
            // [3]. Manage Patients
            // - Create patients
            // - View patients by status
            {
              print(
                "Actions:\n[1]. Enlist a patient\n[2]. View All\n[3]. View not assigned\n[4]. View assigned\n[5]. View discharged",
              );
              stdout.write("Your option: ");
              String? input = stdin.readLineSync();
              if (input == '1') {
                enlistPatient();
              } else if (input == '2') {
                int i = Paginator.paginate(
                  Table<Patient>(
                    title: "List of all Patients",
                    items: hospital.patients,
                    columns: patientColumn,
                  ),
                );
                if (i == -1) {
                  break;
                }
              } else if (input == '3') {
                int i = Paginator.paginate(
                  Table<Patient>(
                    title: "List of not assigned patients",
                    items: hospital.patients
                        .where((r) => r.status == PatientStatus.notAssigned)
                        .toList(),
                    columns: patientColumn,
                  ),
                );
                if (i == -1) {
                  break;
                }
              } else if (input == '4') {
                int i = Paginator.paginate(
                  Table<Patient>(
                    title: "List of assigned patients",
                    items: hospital.patients
                        .where((r) => r.status == PatientStatus.assigned)
                        .toList(),
                    columns: patientColumn,
                  ),
                );
                if (i == -1) {
                  break;
                }
              } else if (input == '5') {
                int i = Paginator.paginate(
                  Table<Patient>(
                    title: "List of discharged patients",
                    items: hospital.patients
                        .where((r) => r.status == PatientStatus.discharged)
                        .toList(),
                    columns: patientColumn,
                  ),
                );
                if (i == -1) {
                  break;
                }
              }
              break;
            }

          case '4':
            {
              //[4]. admit a patient to a room.
              admitFlow();
              break;
            }

          case '5':
            {
              //[5]. Manage Patient Stays
              // - View patients by status
              // - Discharged Patient
              int i = Paginator.paginate(
                Table<PatientStay>(
                  title: "List of Patient Stay",
                  items: hospital.stays,
                  columns: patientStayColumn,
                ),
              );
              break;
            }
          case 'q':
            {
              print("Good bye");
              return;
            }
          default:
            {
              print("im not sure what you want to do");
            }
        }
      }
    }
  }
}
