class Person {
  late final int id;
  String firstname;
  String lastname;
  String email;
  String photoUrl;
  Map<String, String> colorPreferences;
  Map<String, String> iconPreferences;

  Person(
      {required this.id,
      required this.firstname,
      required this.lastname,
      required this.email,
      required this.photoUrl,
      required this.colorPreferences,
      required this.iconPreferences});

  factory Person.fromJson(Map<String, dynamic> json) {
    Person newPerson = Person(
        id: json['id'],
        firstname: json['firstName'],
        lastname: json['lastName'],
        email: json['email'],
        photoUrl: json['photoURL'],
        colorPreferences: Map<String, String>.from(json['colorPreferences']),
        iconPreferences: Map<String, String>.from(json['iconPreferences']));
    return newPerson;
  }
}
