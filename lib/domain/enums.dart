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
  lv1, 
  lv2,
  lv3;
  @override
  String toString() => name;
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