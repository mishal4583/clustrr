class ClustrrUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String batchId;

  ClustrrUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.batchId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'batchId': batchId,
    };
  }

  factory ClustrrUser.fromMap(Map<String, dynamic> map) {
    return ClustrrUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      batchId: map['batchId'],
    );
  }
}
