import 'package:flutter/material.dart';

enum WorkshopCategory {
  craft('Craft', Icons.handyman_outlined),
  code('Code', Icons.code),
  design('Design', Icons.draw_outlined),
  media('Media', Icons.photo_camera_outlined),
  science('Science', Icons.science_outlined);

  const WorkshopCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    craft => scheme.tertiaryContainer,
    code => scheme.primaryContainer,
    design => scheme.secondaryContainer,
    media => scheme.surfaceContainerHighest,
    science => scheme.inversePrimary,
  };
}

class Workshop {
  // The factory freezes incoming lists; only this private constructor is const.
  const Workshop._(
    this._attendees, {
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.location,
    required this.capacity,
    required this.online,
    required this.description,
    required this.favourite,
  });

  factory Workshop({
    required String id,
    required String title,
    required WorkshopCategory category,
    required DateTime startsAt,
    required String location,
    required int capacity,
    List<String> attendees = const [],
    bool online = false,
    String? description,
    bool favourite = false,
  }) => Workshop._(
    List.unmodifiable(attendees),
    id: id,
    title: title,
    category: category,
    startsAt: startsAt,
    location: location,
    capacity: capacity,
    online: online,
    description: description,
    favourite: favourite,
  );

  Workshop.empty()
    : this._(
        const [],
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        category: WorkshopCategory.craft,
        startsAt: DateTime.now().add(const Duration(days: 1)),
        location: '',
        capacity: 12,
        online: false,
        description: null,
        favourite: false,
      );

  final String id;
  final String title;
  final WorkshopCategory category;
  final DateTime startsAt;
  final String location;
  final int capacity;
  final List<String> _attendees;
  List<String> get attendees => _attendees;
  final bool online;
  final String? description;
  final bool favourite;

  int get count => attendees.length;
  int get freePlaces => capacity - count;
  bool get isFull => count >= capacity;
  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => attendees.any((entry) => entry == name);
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Workshop copyWith({
    String? title,
    WorkshopCategory? category,
    DateTime? startsAt,
    String? location,
    int? capacity,
    List<String>? attendees,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) => Workshop(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    startsAt: startsAt ?? this.startsAt,
    location: location ?? this.location,
    capacity: capacity ?? this.capacity,
    attendees: attendees ?? this.attendees,
    online: online ?? this.online,
    description: clearDescription ? null : description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}
