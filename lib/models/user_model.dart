class AppUser {
  final String uid;
  final String email;
  final String role; // "tutor" or "student"

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'],
      role: data['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
    };
  }
}
