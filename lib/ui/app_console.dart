import 'dart:io';
import 'package:room_management/domain/dummy.dart';
import 'package:room_management/ui/paginator.dart';
import 'package:room_management/ui/table.dart';

List<Column<Room>> roomColumns = [
  Column<Room>(title: "Room Number", width: 15, data: (r) => r.roomNumber),
  Column<Room>(title: "Status", width: 10, data: (r) => r.status),
  Column<Room>(title: "Type", width: 10, data: (r) => r.type),
];

class AppConsole {
  String username = "Titan";
  String password = "1234";

  Hosptial hospital;

  Table<Room> roomTable;

  AppConsole({required this.hospital})
    : roomTable = Table(items: hospital.rooms, columns: roomColumns);

  bool login() {
    String? name;
    String? pass;
    print("\nWelcome to Room Management System\n");
    stdout.write("Enter username: ");
    name = stdin.readLineSync();
    stdout.write("Enter password: ");
    pass = stdin.readLineSync();

    if (username == name && password == pass) {
      print("ACCESS GRANTED");
      clearConsole();
      return true;
    } else {
      print("Incorrect credentials.\nPress 'Enter to try again'");
      clearConsole();
      return false;
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

[1]. View rooms
[2]. Create room
[3]. Assign a patient
[4]. Update room status
[5]. Get patient bill
[Q]. Quit
''');
      stdout.write("Select: ");
      String? s = stdin.readLineSync();
      if (s != null && s.isNotEmpty) {
        switch (s) {
          case '1':
            {
              int i = Paginator.paginate(roomTable);
              if (i == -1) {
                print(
                  "\nPerform actions on a room: [1]. Update a room, [2]. Delete a room",
                );
                stdout.write("Enter an option: ");
                String? input = stdin.readLineSync();
                if (input == '1') {
                  stdout.write("Select a room by room number: ");
                  String ? id = stdin.readLineSync();
                  print("$id");
                }
                if (input == '2') print("you tried to delete a room");
              }

              break;
            }
          case '2':
            {
              print("make a room");
              break;
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
