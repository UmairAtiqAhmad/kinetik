class KinetikUser {
  String? uid;
  String? name;
  String? email;

  KinetikUser({
    this.uid,
    this.name,
    this.email,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
      };

  KinetikUser.fromJson(Map<dynamic, dynamic> map) {
    uid = map['uid'] ?? '';
    name = map['name'] ?? '';
    email = map['email'] ?? '';
  }
}
