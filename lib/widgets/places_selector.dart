import 'package:flutter/material.dart';

import '../data/gulf_locations.dart';
import '../l10n/post_card_localizations.dart';
import '../theme/app_theme.dart';

class PlacesSelector extends StatelessWidget {
  final List<String> countries;
  final Map<String, List<String>> places;
  final ValueChanged<Map<String, List<String>>> onChanged;

  const PlacesSelector({
    super.key,
    required this.countries,
    required this.places,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = postCardLocalizations(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkFg : AppColors.fg;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    if (countries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.optionalCitiesHelp,
          style: TextStyle(color: mutedColor, fontSize: 12),
        ),
        const SizedBox(height: 8),
        for (final country in countries) ...[
          Text(
            localizations.citiesPickerLabel(country),
            style: TextStyle(
              color: titleColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ChoiceChip(
                key: ValueKey('all-cities-$country'),
                label: Text(localizations.allCities),
                selected: (places[country] ?? const <String>[]).isEmpty,
                onSelected: (_) =>
                    _updateCountry(country, const <String>[], onChanged),
              ),
              for (final city
                  in GulfLocations.citiesByCountry[country] ?? const <String>[])
                FilterChip(
                  key: ValueKey('place-city-$country-$city'),
                  label: Text(city),
                  selected: (places[country] ?? const <String>[]).contains(
                    city,
                  ),
                  onSelected: (selected) {
                    final selectedCities = [
                      ...(places[country] ?? const <String>[]),
                    ];
                    if (selected) {
                      selectedCities.add(city);
                    } else {
                      selectedCities.remove(city);
                    }
                    final availableCities =
                        GulfLocations.citiesByCountry[country] ??
                        const <String>[];
                    _updateCountry(
                      country,
                      selectedCities.length == availableCities.length
                          ? const <String>[]
                          : selectedCities,
                      onChanged,
                    );
                  },
                ),
            ],
          ),
          if (country != countries.last) const SizedBox(height: 12),
        ],
      ],
    );
  }

  void _updateCountry(
    String country,
    List<String> selectedCities,
    ValueChanged<Map<String, List<String>>> onChanged,
  ) {
    final updated = {
      for (final entry in places.entries)
        if (entry.key != country) entry.key: List<String>.of(entry.value),
    };
    updated[country] = List.unmodifiable(selectedCities);
    onChanged(Map.unmodifiable(updated));
  }
}
