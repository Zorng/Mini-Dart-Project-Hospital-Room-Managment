import 'people.dart';
import 'enums.dart';

class User extends People{
  final Gender gender;
  final String passwordHash;

  User({
    required String id,
    required String name,
    required String phone,
    required this.gender, 
    required this.passwordHash,
  }) : super(id: id, name: name, phone: phone);

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
      "id": id,
      "name": name,
      "phone": phone,
      "gender": gender.name,
      "passwordHash": passwordHash,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    Gender genderFromStr(String name) => Gender.values.byName(name);

    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      gender: genderFromStr(json['gender'] as String), // <-- Read gender directly
      passwordHash: json["passwordHash"] as String,
    );
  }
}