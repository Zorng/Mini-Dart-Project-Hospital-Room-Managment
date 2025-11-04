import 'enums.dart';

class People{
  final String id;
  final String name;
  final String phone;
  final Gender gender;

  People(this.id, this.name, this.phone, this.gender);

  Map<String, dynamic> toJson(){
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "gender": gender.name,
    };
  }

  static People fromJson(Map<String, dynamic> json){
    Gender genderFromStr(String name){
      return Gender.values.firstWhere(
        (e) => e.name == name,
        orElse: () => Gender.male, // default
      );
    }

    return People(
      json['id'] as String,
      json['name'] as String,
      json['phone'] as String,
      genderFromStr(json['gender'] as String),
    );
  }
}