import 'package:room_management/ui/table.dart';
import 'package:room_management/ui/app_console.dart';
import 'dart:io';

class Paginator {
  static int itemPerPage = 6;

  static int paginate(Table table) {  
    String ?input;
    int page = 1;
    double totalPage = (table.items.length + itemPerPage - 1) / itemPerPage;
    while (true) {
      int start = (page - 1) * itemPerPage;
      int end = (start + itemPerPage < table.items.length)
          ? start + itemPerPage
          : table.items.length;
      stdout.write("\n");
      table.printTable(start, end);
      print("page $page/${totalPage.floor()}");

      // print("\nPress a for previous page");
      // print("Pressd d for next page");
      // print("Press e to select actions");
      // print("Press q to return");

      print("\nPage naviagtion: [a] for previous page, [d] for next page and [q] to return");
      print("Action selections: [e]");

      stdout.write("\nEnter an option: ");

      input = stdin.readLineSync();
      
      if (input == 'a' && page < totalPage.floor()) {
        page++;
      } else if (input == 'd' && page > 1) {
        page--;
      } else if (input == 'q') {
        AppConsole.clearConsole();
        return 0;
      } else if (input == 'e') {
        return -1; //signal for action selections
      }
      AppConsole.clearConsole();
    }
  }
}
