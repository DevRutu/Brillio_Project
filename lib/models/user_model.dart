class UserModel {
  final String uid;
  final String email;
  final String parentName;
  final String childName;
  final DateTime childDOB;

  UserModel({
    required this.uid,
    required this.email,
    required this.parentName,
    required this.childName,
    required this.childDOB,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      parentName: data['parentName'] ?? '',
      childName: data['childName'] ?? '',
      childDOB: data['childDOB']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'parentName': parentName,
      'childName': childName,
      'childDOB': childDOB,
    };
  }
}