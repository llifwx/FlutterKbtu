class Geo {
  const Geo({required this.lat, required this.lng});

  // The server sends coordinates as strings: "-37.3159".
  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
    lat: double.parse(json['lat'] as String),
    lng: double.parse(json['lng'] as String),
  );

  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {'lat': '$lat', 'lng': '$lng'};
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json['street'] as String,
    suite: json['suite'] as String,
    city: json['city'] as String,
    zipcode: json['zipcode'] as String,
    geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
  );

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  Map<String, dynamic> toJson() => {
    'street': street,
    'suite': suite,
    'city': city,
    'zipcode': zipcode,
    'geo': geo.toJson(),
  };
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>;
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String?,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      company: (
        name: company['name'] as String,
        catchPhrase: company['catchPhrase'] as String,
      ),
    );
  }

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String? website;
  final Address address;
  final ({String name, String catchPhrase}) company;

  /// "1-770-736-8031 x56442" → "1770736803156442".
  String get phoneDigits => phone.replaceAll(RegExp(r'[^\d+]'), '');

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'address': address.toJson(),
    'phone': phone,
    'website': website,
    'company': {'name': company.name, 'catchPhrase': company.catchPhrase},
  };

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User($id, $name, ${address.city})';
}
