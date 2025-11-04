import 'people.dart';
import 'enums.dart';

class User extends People{
  final String passwordHash;

  User(
    String id,
    String name,
    String phone,
    Gender gender,
    this.passwordHash,
  ) : super(id, name, phone, gender);

  bool logIn({required String phone, required String password}){
    print('Attempting login for User $name via phone $phone...');
    return false;
  }

  void createRoom() => throw UnimplementedError('createRoom() is not implemented.');
  void readRoom() => throw UnimplementedError('readRoom() is not implemented.');
  void updateRoom() => throw UnimplementedError('updateRoom() is not implemented.');
  void deleteRoom() => throw UnimplementedError('deleteRoom() is not implemented.');
  void readRooms() => throw UnimplementedError('readRooms() is not implemented.');
  void updateRoomStatus() => throw UnimplementedError('updateRoomStatus() is not implemented.');

  void assignPatient () => throw UnimplementedError('assignPatient() is not implemented.');

  double getPatientStayBill(){
    throw UnimplementedError('getPatientStayBill() is not implemented.');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      "passwordHash": passwordHash,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    final People basePeople = People.fromJson(json);

    return User(
      basePeople.id,
      basePeople.name,
      basePeople.phone,
      basePeople.gender,
      json["passwordHash"] as String,
    );
  }
}