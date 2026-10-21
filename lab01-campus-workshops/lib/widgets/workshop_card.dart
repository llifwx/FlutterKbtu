import 'package:flutter/material.dart';
import '../models/workshop.dart';
import '../utils/format.dart';

class WorkshopCard extends StatelessWidget {
  const WorkshopCard({super.key, required this.workshop, required this.onOpen, required this.onFavourite});
  final Workshop workshop;
  final VoidCallback onOpen;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (:taken, :free) = workshop.places;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Row(children: [
            Stack(clipBehavior: Clip.none, children: [
              CircleAvatar(radius: 26, backgroundColor: workshop.category.color(theme.colorScheme), child: Icon(workshop.category.icon, color: theme.colorScheme.onSurface)),
              if (free <= 5)
                Positioned(bottom: -12, left: -4, right: -4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: workshop.isFull ? theme.colorScheme.errorContainer : theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text(workshop.isFull ? 'FULL' : '$free left', textAlign: TextAlign.center, style: theme.textTheme.labelSmall)),
                  ),
                ),
            ]),
            const SizedBox(width: 14),
            Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(workshop.category.label.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 4),
              Text(workshop.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(formatDateTime(workshop.startsAt), style: theme.textTheme.bodySmall),
              Text(workshop.online ? 'Online studio' : workshop.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text('$taken / ${workshop.capacity} makers${workshop.isPast ? ' · Past' : ''}', style: theme.textTheme.labelSmall),
            ])),
            IconButton(tooltip: workshop.favourite ? 'Remove favourite' : 'Add favourite', onPressed: onFavourite, icon: Icon(workshop.favourite ? Icons.favorite : Icons.favorite_border, color: theme.colorScheme.primary)),
          ]),
        ),
      ),
    );
  }
}
