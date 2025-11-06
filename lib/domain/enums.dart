enum GenderPolicy {
  maleOnly,
  femaleOnly,
  mixed;

  @override
  String toString() => name;
}

enum Gender{
  male,
  female;
  @override
  String toString() => name;
}

enum Level {
  lv1(100), 
  lv2(120),
  lv3(130);

  final int rateMultiplier;
  @override
  String toString() => name;
  const Level(this.rateMultiplier);
}

enum BedAvailability {
  available,      
  occupied,       
  maintenance,    
  needCleaning;
  @override
  String toString() => name;  
}

enum PatientStatus{
  notAssigned,
  assigned,
  discharged;
  @override
  String toString() => name;
}