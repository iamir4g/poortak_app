class UpdateProfileParams {
  final String firstName;
  final String lastName;
  final String ageGroup;
  final String avatar;
  final String nationalCode;
  final String province;
  final String city;
  final String address;
  final String postalCode;
  final String birthdate;

  UpdateProfileParams({
    this.firstName = '',
    this.lastName = '',
    this.ageGroup = '',
    this.avatar = '',
    this.nationalCode = '',
    this.province = '',
    this.city = '',
    this.address = '',
    this.postalCode = '',
    this.birthdate = '',
  });

  // Factory constructor for creating params with only specific fields
  factory UpdateProfileParams.only({
    String? firstName,
    String? lastName,
    String? ageGroup,
    String? avatar,
    String? nationalCode,
    String? province,
    String? city,
    String? address,
    String? postalCode,
    String? birthdate,
  }) {
    return UpdateProfileParams(
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      ageGroup: ageGroup ?? '',
      avatar: avatar ?? '',
      nationalCode: nationalCode ?? '',
      province: province ?? '',
      city: city ?? '',
      address: address ?? '',
      postalCode: postalCode ?? '',
      birthdate: birthdate ?? '',
    );
  }
}
