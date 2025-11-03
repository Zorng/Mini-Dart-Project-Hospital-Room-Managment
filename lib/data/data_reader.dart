import 'dart:convert';
import 'dart:io';
import 'package:room_management/domain/dummy.dart';

class DataReader {
  Hosptial loadData(){
    final f = File('lib/data/haha.json');
    final content = f.readAsStringSync();
    final Map <String, dynamic> data = jsonDecode(content);
    List<dynamic> roomsJson = data['rooms'] as List;
    
    var rooms = roomsJson.map((room){
      return Room(
        roomNumber: room['roomNumber'],
        status: room['status'],
        type: room['type']
      );
    }).toList();

    return Hosptial(rooms);
  }
}
