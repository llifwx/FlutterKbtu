class Student {
  const Student({required this.name, required this.group, required this.email});

  final String name;
  final String group;
  final String email;

  Student copyWith({String? name}) =>
      Student(name: name ?? this.name, group: group, email: email);
}

const students = [
  Student(name: 'Aida Akhmetova', group: 'IT-2302', email: 'aida@kbtu.kz'),
  Student(name: 'Dias Nurlanov', group: 'IT-2302', email: 'dias@kbtu.kz'),
  Student(name: 'Madina Serik', group: 'IT-2303', email: 'madina@kbtu.kz'),
  Student(name: 'Alikhan Bekov', group: 'IT-2303', email: 'alikhan@kbtu.kz'),
  Student(name: 'Zhanel Tolegen', group: 'IT-2304', email: 'zhanel@kbtu.kz'),
  Student(name: 'Arman Kairat', group: 'IT-2304', email: 'arman@kbtu.kz'),
  Student(name: 'Kamila Dosym', group: 'IT-2305', email: 'kamila@kbtu.kz'),
  Student(name: 'Yerlan Sadyk', group: 'IT-2305', email: 'yerlan@kbtu.kz'),
];
