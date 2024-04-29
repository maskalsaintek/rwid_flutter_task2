class Contact {
  String id;
  String fullName;
  String phoneNumber;
  String? email;
  String? birthDate;
  String covertType;
  String? profileImage;
  String? profileColor;

  Contact(this.id, this.fullName, this.phoneNumber, this.email, this.birthDate, this.covertType, this.profileColor, this.profileImage);

  Contact.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        fullName = json['full_name'],
        phoneNumber = json['phone_number'],
        email = json['email'],
        birthDate = json['birth_date'],
        covertType = json['cover_type'],
        profileImage = json['profile_image'],
        profileColor = json['profile_color'];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      "email": email,
      "birth_date": birthDate,
      "cover_type": covertType,
      "profile_image": profileImage,
      "profile_color": profileColor
    };
  }
}
