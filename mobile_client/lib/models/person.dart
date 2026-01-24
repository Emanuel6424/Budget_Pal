class Person {
  late final int id;
  String firstname;
  String lastname;
  String email;

  Person({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    Person newPerson = Person(
      id: json['id'],
      firstname: json['firstName'],
      lastname: json['lastName'],
      email: json['email'],
    );
    return newPerson;
  }
}
