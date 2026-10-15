class Contact {
  const Contact({required this.name, required this.email, this.unread = 0});

  final String name;
  final String email;
  final int unread;

  String get initial => name.isEmpty ? '?' : name[0];
}

const _names = [
  'Aida Akhmetova',
  'Dias Nurlanov',
  'Madina Serik',
  'Alikhan Bekov',
  'Sultanmakhmutova-Bekzhanova Aigerim-Madina Nurlanovna',
  'Arman Kairat',
  'Zhanel Tolegen',
  'Nurlan Abdi',
  'Kamila Dosym',
  'Yerlan Sadyk',
  'Aruzhan Mukhtar',
  'Timur Zhaksylyk',
  'Dana Orazbek',
  'Sanzhar Kenzhe',
  'Amina Talgat',
  'Bekzat Ospan',
  'Inkar Rakhim',
  'Daniyar Amir',
  'Ayan Bolat',
  'Tomiris Serikbay',
];

final contacts = [
  for (var i = 0; i < _names.length; i++)
    Contact(
      name: _names[i],
      email: '${_names[i].split(' ').first.toLowerCase()}@kbtu.kz',
      unread: i % 4,
    ),
];
