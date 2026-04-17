class UserModel {
  String uid;
  String? name;
  String? email;
  String? phone;

  UserModel({required this.uid, this.name, this.email, this.phone});

  Map<String, dynamic> toMap() {
    return {"uid": uid, "name": name, "email": email, "phone": phone};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
    );
  }
}
