class Patient {
  const Patient({required this.code, required this.name, required this.age});

  final String code;
  final String name;
  final int age;

  Patient copyWith({String? code, String? name, int? age}) {
    return Patient(
      code: code ?? this.code,
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}
