import 'people.dart';
import 'enums.dart';

class Patient extends People{
  final Gender gender;
  final DateTime dob;
  PatientStatus status;

  Patient({
    required String id,
    required String name,
    required String phone,
    required this.gender,
    required this.dob,
    this.status = PatientStatus.notAssigned,
  }) : super(id: id, name: name, phone: phone);

  void markAssigned(){
    status = PatientStatus.assigned;
  }

  void markDischarged(){
    status = PatientStatus.discharged;
  }

  @override
  Map<String, dynamic> toJson(){
    return{
      "patientId": id,
      "name": name,
      "phone": phone,
      "gender": gender.name,
      "dob": dob.toIso8601String(),
      "status": status.name,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "$id, $name, $phone, $dob, $gender";
  }

  static Patient fromJson(Map<String, dynamic> json) {
    final String? genderString = json["gender"] as String?;
    if (genderString == null) {
      throw ArgumentError('Missing required field "gender" for Patient.');
    }
    final Gender gender = Gender.values.byName(genderString);

    final String? statusString = json["status"] as String?;
    final PatientStatus status = statusString != null
        ? PatientStatus.values.byName(statusString)
        : PatientStatus.notAssigned;

    return Patient(
      id: json["patientId"] as String,
      name: json["name"] as String,
      phone: json["phone"] as String,
      gender: gender,
      dob: DateTime.parse(json["dob"] as String),
      status: status,
    );
  }
}
