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
    required this.firstName,
    required this.lastName,
    required this.ageGroup,
    required this.avatar,
    required this.nationalCode,
    required this.province,
    required this.city,
    required this.address,
    required this.postalCode,
    required this.birthdate,
  });
}
