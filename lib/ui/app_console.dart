import 'dart:io';
import 'package:room_management/domain/hospital.dart';
import 'package:room_management/domain/room.dart';
import 'package:room_management/domain/ward.dart';
import 'package:room_management/domain/icu.dart';
import 'package:room_management/domain/bed.dart';
import 'package:room_management/ui/paginator.dart';
import 'package:room_management/ui/table.dart';

List<Column<Ward>> wardColumns = [
  Column<Ward>(title: "Room Number", width: 15, data: (r) => r.roomNumber),
  Column<Ward>(title: "Status", width: 15, data: (r) => r.overallStatus),
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
  Column<ICU>(
    title: "Acuity Level",
    width: 15,
    data: (r) => r.level.toString(),
  ),
  Column<ICU>(
    title: "Gender Policy",
    width: 15,
    data: (r) => r.genderPolicy.toString(),
  ),
  Column<ICU>(
    title: "Available Beds",
    width: 15,
    data: (r) => r.freeBeds.toString(),
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

  T? roomAction<T>(
    T Function(Room room) action, {
    String prompt = "Select a room by room number: ",
  }) {
    try {
      stdout.write(prompt);
      final id = stdin.readLineSync();
      if (id == null) return null;

      final room = hospital.getRoom(roomNumber: id);
      if (room == null) {
        print("room $id not found");
        return null;
      }
      return action(room);
    } catch (e) {
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
      int? i = roomAction<int>((room) {
        return Paginator.paginate(
          Table<Bed>(
            title: "Beds of Room ${room.roomNumber}",
            items: room.beds,
            columns: bedColumn,
          ),
        );
      });
      if (i == -1) {
        print("\nactions:\n[q]. Back");
        stdout.write("Enter an option: ");
        String? input = stdin.readLineSync();
        if (input == 'q') return;
      }
    } else if(input == '2') {
      roomAction<void>((room) => room.markForMaintenance()); 
      stdin.readLineSync();
    } else if(input == '3') {
      roomAction<void>((room) => room.clearMaintenance()); 
      stdin.readLineSync();
    }
  }

  void line() {
    print('\n==============================================');
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
      line();
      print('''
Enter number in the bracket to select.

[1]. Manage Wards
[2]. Manage ICU
[3]. Manage Patients
[4]. Admit Patients
[5]. Get patient bill
[Q]. Quit
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
                print(
                  "\nPerform actions on a room: [1]. Update a room, [2]. Delete a room",
                );
                stdout.write("Enter an option: ");
                String? input = stdin.readLineSync();
                if (input == '1') {
                  stdout.write("Select a room by room number: ");
                  String? id = stdin.readLineSync();
                  print("$id");
                }
                if (input == '2') print("you tried to delete a room");
              }
            }
          case '3':
            {
              print("im sick");
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
