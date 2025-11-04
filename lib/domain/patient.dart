import 'people.dart';
import 'enums.dart';

class Patient extends People{
  final Level requiredAcuity;
  final bool requiresVentilator;

  Patient(
    String id,
    String name,
    String phone,
    Gender gender,
    this.requiredAcuity,
    {this.requiresVentilator = false}
  ) : super(id, name, phone, gender);

  @override
  Map<String, dynamic> toJson(){
    return{
      ...super.toJson(),
      "requiredAcuity": requiredAcuity.name,
      "requiresVentilator": requiresVentilator,
    };
  }

  static Patient fromJson(Map<String, dynamic> json) {
    final People basePeople = People.fromJson(json);

    Level acuityFromStr(String name) {
      return Level.values.firstWhere(
        (e) => e.name == name,
        orElse: () => Level.lv1, // Default
      );
    }

    return Patient(
      basePeople.id,
      basePeople.name,
      basePeople.phone,
      basePeople.gender,
      acuityFromStr(json["requiredAcuity"] as String),
      requiresVentilator: json["requiresVentilator"] as bool,
    );
  }
}
