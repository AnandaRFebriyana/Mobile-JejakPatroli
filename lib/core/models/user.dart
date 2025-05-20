class User {
  final int id;
  final String name;
  final String? birthDate;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? photo;
  final String? token;

  User({
    required this.id,
    required this.name,
    this.birthDate,
    required this.email,
    this.phoneNumber,
    this.address,
    this.photo,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      birthDate: json['birth_date'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      photo: json['photo'],
      token: json['token'],
    );
  }
}