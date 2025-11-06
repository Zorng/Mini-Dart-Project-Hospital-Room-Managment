abstract class People{
  final String id;
  final String name;
  final String phone;

  People({
    required this.id,
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson();
}