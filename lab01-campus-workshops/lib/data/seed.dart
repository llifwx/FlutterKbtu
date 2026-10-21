import '../models/workshop.dart';

List<Workshop> seedWorkshops() {
  final today = DateUtilsForSeed.today;
  DateTime day(int offset, [int hour = 16]) =>
      today.add(Duration(days: offset, hours: hour));
  return [
    Workshop(
      id: 'ceramic',
      title: 'Clay, coffee and your first handmade cup',
      category: WorkshopCategory.craft,
      startsAt: day(1),
      location: 'Maker studio · B201',
      capacity: 12,
      attendees: ['Dana', 'Arman', 'Mira'],
      favourite: true,
      description: 'Build a pinch pot, try a glaze, and meet other makers. Aprons and clay are provided. Bring a cup for coffee and clothes you can get messy.',
    ),
    Workshop(
      id: 'long',
      title: 'Design a brighter campus with a collaborative mural workshop',
      category: WorkshopCategory.design,
      startsAt: day(2, 14),
      location: 'Art courtyard',
      capacity: 20,
      attendees: ['Dana', 'Alina'],
      description: 'Sketch a shared mural for the courtyard. No drawing experience needed; we start with shapes and colour studies.',
    ),
    Workshop(
      id: 'full',
      title: 'Film photography after class',
      category: WorkshopCategory.media,
      startsAt: day(1, 18),
      location: 'Photo lab · A104',
      capacity: 3,
      attendees: ['Mira', 'Azat', 'Dana'],
      description: 'Learn to load a film camera and meter natural light. All three cameras are reserved.',
    ),
    Workshop(
      id: 'online',
      title: 'Build your first tiny game',
      category: WorkshopCategory.code,
      startsAt: day(3),
      location: 'https://meet.example.com/tiny-game',
      capacity: 30,
      online: true,
      favourite: true,
      description: 'An online creative coding session. Bring a laptop and turn a simple idea into a playable prototype.',
    ),
    Workshop(
      id: 'no-description',
      title: 'Paper circuits and glowing postcards',
      category: WorkshopCategory.science,
      startsAt: day(4),
      location: 'Discovery lab · C302',
      capacity: 10,
      attendees: ['Arman'],
    ),
    Workshop(
      id: 'past',
      title: 'Zine club: stories from our campus',
      category: WorkshopCategory.design,
      startsAt: day(-2),
      location: 'Library workshop room',
      capacity: 15,
      attendees: ['Dana', 'Azat'],
      description: 'A completed session on small independent magazines and folded paper stories.',
    ),
    Workshop(
      id: 'wood',
      title: 'Make a wooden phone stand',
      category: WorkshopCategory.craft,
      startsAt: day(5),
      location: 'Maker studio · B201',
      capacity: 8,
      attendees: ['Alina', 'Mira', 'Dana', 'Azat'],
      description: 'Measure, sand and finish a small desk accessory. Tools and safety briefing included.',
    ),
    Workshop(
      id: 'sound',
      title: 'Record the sounds of the city',
      category: WorkshopCategory.media,
      startsAt: day(6, 11),
      location: 'Main entrance',
      capacity: 12,
      description: 'A short sound walk followed by an introduction to editing field recordings.',
    ),
    Workshop(
      id: 'plants',
      title: 'Plant pigments under the microscope',
      category: WorkshopCategory.science,
      startsAt: day(7),
      location: 'Discovery lab · C302',
      capacity: 16,
      attendees: ['Arman', 'Mira'],
      description:
          'Extract colours from leaves and explore how plants capture light.',
    ),
    Workshop(
      id: 'web',
      title: 'A personal website in one afternoon',
      category: WorkshopCategory.code,
      startsAt: day(8, 13),
      location: 'Computer lab · D205',
      capacity: 18,
      attendees: ['Azat'],
      description: 'Create a small accessible portfolio using the browser and a text editor.',
    ),
    Workshop(
      id: 'print',
      title: 'Stamp your own tote bag',
      category: WorkshopCategory.craft,
      startsAt: day(9),
      location: 'Maker studio · B201',
      capacity: 10,
      favourite: true,
      description: 'Carve a reusable stamp and print a simple pattern. One cotton tote is included.',
    ),
    Workshop(
      id: 'past-code',
      title: 'Creative coding with moving shapes',
      category: WorkshopCategory.code,
      startsAt: day(-5),
      location: 'https://meet.example.com/shapes',
      capacity: 25,
      online: true,
      attendees: ['Dana'],
      description:
          'A completed online introduction to loops, shapes and animation.',
    ),
  ];
}

abstract final class DateUtilsForSeed {
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
