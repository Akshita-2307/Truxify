import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../widgets/truck_card.dart';

class TruckResultsScreen extends StatefulWidget {
  const TruckResultsScreen({super.key, required this.draft});

  final RouteDraft draft;

  @override
  State<TruckResultsScreen> createState() => _TruckResultsScreenState();
}

class _TruckResultsScreenState extends State<TruckResultsScreen> {
  int _selectedSort = 0;
  static const _sortChips = ['Best Match', 'Cheapest', 'Fastest', 'Top Rated'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('12 trucks found'),
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.sort_rounded))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sortChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final selected = index == _selectedSort;
                return ChoiceChip(
                  label: Text(_sortChips[index]),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedSort = index),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ...mockTruckResults.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final truck = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TruckCard(
                  truck: truck,
                  draft: widget.draft,
                  isHighlighted: index == 0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

