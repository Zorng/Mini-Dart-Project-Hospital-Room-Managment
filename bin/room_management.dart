import 'package:room_management/domain/dummy.dart';
import 'package:room_management/data/data_reader.dart';
import 'package:room_management/ui/app_console.dart';
import 'package:room_management/ui/paginator.dart';
import 'package:room_management/ui/table.dart';

void main() {
  DataReader d1 = DataReader();
  Hosptial h1 = d1.loadData();
  AppConsole app =AppConsole(hospital: h1);
  app.console();


  
}