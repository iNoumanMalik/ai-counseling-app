/// Model for counselor data
class Counselor {
  final String id;
  final String name;
  final String specialty;
  final int experience; // years
  final String city;
  final String fee;
  final String profilePicture;
  final String category;
  final String? marhamUrl;
  final String? oladocUrl;
  final String? whatsappNumber;
  final String? bio;

  Counselor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.city,
    required this.fee,
    required this.profilePicture,
    required this.category,
    this.marhamUrl,
    this.oladocUrl,
    this.whatsappNumber,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'experience': experience,
      'city': city,
      'fee': fee,
      'profilePicture': profilePicture,
      'category': category,
      'marhamUrl': marhamUrl,
      'oladocUrl': oladocUrl,
      'whatsappNumber': whatsappNumber,
      'bio': bio,
    };
  }

  factory Counselor.fromJson(Map<String, dynamic> json) {
    return Counselor(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      experience: json['experience'] as int,
      city: json['city'] as String,
      fee: json['fee'] as String,
      profilePicture: json['profilePicture'] as String,
      category: json['category'] as String,
      marhamUrl: json['marhamUrl'] as String?,
      oladocUrl: json['oladocUrl'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      bio: json['bio'] as String?,
    );
  }
}

