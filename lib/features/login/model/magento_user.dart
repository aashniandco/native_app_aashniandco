class MagentoUser {
  final String firstname;
  final String lastname;
  final int customer_id;

  MagentoUser({required this.firstname, required this.lastname,required this.customer_id});

  factory MagentoUser.fromJson(Map<String, dynamic> json) {
    return MagentoUser(
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      customer_id: json ['id']
    );
  }
}
