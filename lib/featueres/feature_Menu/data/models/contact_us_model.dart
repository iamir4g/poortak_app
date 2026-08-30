class ContactUsResponse {
  final bool ok;
  final List<ContactUsItem> data;

  ContactUsResponse({
    required this.ok,
    required this.data,
  });

  factory ContactUsResponse.fromJson(Map<String, dynamic> json) {
    return ContactUsResponse(
      ok: json['ok'] == true,
      data: (json['data'] as List? ?? [])
          .map((e) =>
              ContactUsItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class ContactUsItem {
  final String id;
  final String key;
  final String? title;
  final String value;

  ContactUsItem({
    required this.id,
    required this.key,
    this.title,
    required this.value,
  });

  factory ContactUsItem.fromJson(Map<String, dynamic> json) {
    return ContactUsItem(
      id: json['id']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString(),
      value: json['value']?.toString() ?? '',
    );
  }
}

class ContactUsInfo {
  final String? address;
  final List<String> telephones;
  final List<String> websites;
  final List<String> emails;

  const ContactUsInfo({
    this.address,
    this.telephones = const [],
    this.websites = const [],
    this.emails = const [],
  });

  factory ContactUsInfo.fromItems(List<ContactUsItem> items) {
    String? address;
    final telephones = <String>[];
    final websites = <String>[];
    final emails = <String>[];

    for (final item in items) {
      final value = item.value.trim();
      if (value.isEmpty) continue;

      switch (item.key.toLowerCase()) {
        case 'address':
          address ??= value;
          break;
        case 'telephone':
          telephones.add(value);
          break;
        case 'website':
          websites.add(value);
          break;
        case 'email':
          emails.add(value);
          break;
      }
    }

    return ContactUsInfo(
      address: address,
      telephones: telephones,
      websites: websites,
      emails: emails,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactUsInfo &&
        other.address == address &&
        _listEquals(other.telephones, telephones) &&
        _listEquals(other.websites, websites) &&
        _listEquals(other.emails, emails);
  }

  @override
  int get hashCode => Object.hash(
        address,
        Object.hashAll(telephones),
        Object.hashAll(websites),
        Object.hashAll(emails),
      );
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
