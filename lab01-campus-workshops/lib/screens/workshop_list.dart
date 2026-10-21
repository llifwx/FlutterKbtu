import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../widgets/empty_state.dart';
import '../widgets/workshop_card.dart';

class WorkshopList extends StatefulWidget {
  const WorkshopList({
    super.key,
    required this.workshops,
    required this.favouritesOnly,
    required this.onOpen,
    required this.onFavourite,
    required this.onExplore,
  });
  final List<Workshop> workshops;
  final bool favouritesOnly;
  final ValueChanged<Workshop> onOpen;
  final ValueChanged<Workshop> onFavourite;
  final VoidCallback onExplore;

  @override
  State<WorkshopList> createState() => _WorkshopListState();
}

class _WorkshopListState extends State<WorkshopList> {
  final _search = TextEditingController();
  WorkshopCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
    _search.clear();
    _category = null;
    _showPast = false;
  });

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final items =
        widget.workshops
            .where(
              (item) =>
                  (!widget.favouritesOnly || item.favourite) &&
                  (_showPast || !item.isPast) &&
                  (_category == null || item.category == _category) &&
                  item.title.toLowerCase().contains(query),
            )
            .toList()
          ..sort((a, b) {
            if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
            return a.startsAt.compareTo(b.startsAt);
          });
    final hasFavourites = widget.workshops.any((item) => item.favourite);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, viewport) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewport.maxHeight >= 430) ...[
                  Text(
                    widget.favouritesOnly
                        ? 'Keep a little inspiration.'
                        : 'Make something\nafter class.',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.favouritesOnly
                        ? 'Your saved campus workshops'
                        : 'Small workshops. Curious people. New skills.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                TextFormField(
                  controller: _search,
                  validator: (_) => null,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Find your next workshop',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () => setState(_search.clear),
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final category in WorkshopCategory.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: Icon(category.icon, size: 18),
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                ],
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Include past'),
                  selected: _showPast,
                  onSelected: (value) => setState(() => _showPast = value),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Text(
              '${items.length} WORKSHOPS${widget.favouritesOnly ? ' SAVED' : ' TO EXPLORE'}',
              style: theme.textTheme.labelSmall,
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: widget.favouritesOnly && !hasFavourites
                        ? Icons.favorite_border
                        : Icons.search_off,
                    message: widget.favouritesOnly && !hasFavourites
                        ? 'Save a workshop that sparks your curiosity.'
                        : 'No workshops match these filters.',
                    actionLabel: widget.favouritesOnly && !hasFavourites
                        ? 'Explore workshops'
                        : 'Reset filters',
                    onAction: widget.favouritesOnly && !hasFavourites
                        ? widget.onExplore
                        : _clear,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      Widget card(int index) => WorkshopCard(
                        workshop: items[index],
                        onOpen: () => widget.onOpen(items[index]),
                        onFavourite: () => widget.onFavourite(items[index]),
                      );
                      if (constraints.maxWidth >= 600) {
                        final columns = ((constraints.maxWidth - 40) / 360)
                            .ceil();
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: 208,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: items.length,
                          itemBuilder: (_, index) => card(index),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) => card(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
