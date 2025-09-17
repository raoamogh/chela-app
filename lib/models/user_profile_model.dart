class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String college;
  final String course;
  final String codechefUsername;
  final String leetcodeUsername;
  final String? photoURL;

  UserProfile({
    required this.uid,
    required this.email,
    this.name = '',
    this.college = '',
    this.course = '',
    this.codechefUsername = '',
    this.leetcodeUsername = '',
    this.photoURL,
  });

  // This "factory constructor" builds a UserProfile object from a Map (like JSON).
  // It's essential for parsing data from our backend.
  factory UserProfile.fromJson(String uid, String email, Map<String, dynamic>? json) {
    // If the json from Firestore is null (e.g., for a new user),
    // we return a default profile with the essential info.
    if (json == null) {
      return UserProfile(uid: uid, email: email);
    }

    // Otherwise, we populate the fields with data from the database.
    return UserProfile(
      uid: uid,
      email: email,
      name: json['name'] ?? '',
      college: json['college'] ?? '',
      course: json['course'] ?? '',
      codechefUsername: json['codechef_username'] ?? '',
      leetcodeUsername: json['leetcode_username'] ?? '',
      photoURL: json['photoURL'], // This can be null
    );
  }
}