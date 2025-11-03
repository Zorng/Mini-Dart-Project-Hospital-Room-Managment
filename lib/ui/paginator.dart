import 'package:room_management/ui/table.dart';
import 'dart:io';

class Paginator {
  static int itemPerPage = 6;

  static void paginate(Table table) {
    String ?input;
    int page = 1;
    double totalPage = (table.items.length + itemPerPage - 1) / itemPerPage;
    while (true) {
      int start = (page - 1) * itemPerPage;
      int end = (start + itemPerPage < table.items.length)
          ? start + itemPerPage
          : table.items.length;
      print("page $page/${totalPage.floor()}");
      table.printTable(start, end);

      print("\nuse c for previous page");
      print("use a for next page");
      print("use q to quit");

      input = stdin.readLineSync();
      if (input == 'a' && page < totalPage) {
        page++;
      } else if (input == 'c' && page > 1) {
        page--;
      } else if (input == 'q') {
        return;
      }
      print(input);
    }
  }
}
