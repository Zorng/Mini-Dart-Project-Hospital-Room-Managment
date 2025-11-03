class Room{
  String roomNumber;
  String status;
  String type;
  Room({required this.roomNumber, required this.status, required this.type});
  
}

class Hosptial{
  List<Room> rooms;
  Hosptial(this.rooms);
}