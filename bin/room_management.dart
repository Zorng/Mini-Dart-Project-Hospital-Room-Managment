import 'package:room_management/data/data_reader.dart';
import 'package:room_management/domain/hospital.dart';
import 'package:room_management/ui/app_console.dart';



void main() async {
  Hospital hospital = await DataReader.readData();
  AppConsole app = AppConsole(hospital: hospital);
  app.console();

}