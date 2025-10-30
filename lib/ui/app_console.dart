import 'dart:io';

class AppConsole {
  String username = "Titan";
  String password = "1234";

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

  void pagination(){
    
  }

  //AI generated
  void clearConsole() {
    if (Platform.isWindows) {
      // Windows ANSI support
      stdin.readLineSync();
      stdout.write('\x1B[2J\x1B[0;0H');
      stdin.readLineSync();
    } else {
      // macOS / Linux
      stdin.readLineSync();
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
              print("Room xxx");
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
