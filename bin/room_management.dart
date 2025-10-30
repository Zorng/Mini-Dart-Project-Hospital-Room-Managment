
import 'dart:io';
//import 'package:room_management/data/haha.json';
import 'dart:convert';

void main() {
  // AppConsole app = AppConsole();

  // app.console();
  final f = File('lib/data/haha.json');
  final content = f.readAsStringSync();
  final Map <String, dynamic> data = jsonDecode(content);
  List<dynamic> myList = data['data'] as List;

  myList.forEach(print);
}