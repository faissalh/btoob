import 'package:flutter/material.dart';

import '../data/gulf_locations.dart';
import '../theme/app_theme.dart';

class LocationSelection {
  const LocationSelection({required this.countries, required this.cities});

  final Set<String> countries;
  final Set<String> cities;
}

class LocationFilterButton extends StatelessWidget {
  const LocationFilterButton({
    super.key,
    required this.countries,
    required this.cities,
    required this.onChanged,
    this.title = 'الموقع',
    this.allowAll = true,
  });

  final Set<String> countries;
  final Set<String> cities;
  final ValueChanged<LocationSelection> onChanged;
  final String title;
  final bool allowAll;

  Future<void> _showPicker(BuildContext context) async {
    final selection = await showDialog<LocationSelection>(
      context: context,
      builder: (context) => _LocationPickerDialog(
        initialCountries: countries,
        initialCities: cities,
        allowAll: allowAll,
      ),
    );
    if (selection != null) onChanged(selection);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;
    final countryLabel = countries.isEmpty
        ? (allowAll ? 'كل الدول' : 'اختر الدول')
        : countries.length == 1
        ? countries.single
        : '${countries.length} دول';
    final cityLabel = cities.isEmpty
        ? (allowAll ? 'كل المدن' : 'اختر المدن')
        : cities.length == 1
        ? cities.single
        : '${cities.length} مدن';

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showPicker(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          side: BorderSide(color: isDark ? AppColors.darkLine : AppColors.line),
          foregroundColor: isDark ? AppColors.darkFg : AppColors.fg,
          backgroundColor: isDark ? AppColors.darkPanel : AppColors.panel,
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.accent),
            const SizedBox(width: 8),
            Text('$title:', style: TextStyle(color: muted)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$countryLabel · $cityLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class _LocationPickerDialog extends StatefulWidget {
  const _LocationPickerDialog({
    required this.initialCountries,
    required this.initialCities,
    required this.allowAll,
  });

  final Set<String> initialCountries;
  final Set<String> initialCities;
  final bool allowAll;

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  late final Set<String> _countries = Set.from(widget.initialCountries);
  late final Set<String> _cities = Set.from(widget.initialCities);

  List<String> get _availableCountries =>
      _countries.isEmpty ? GulfLocations.countries : _countries.toList();

  void _toggleCountry(String country, bool selected) {
    setState(() {
      if (selected) {
        _countries.add(country);
      } else {
        _countries.remove(country);
      }
      final validCities = GulfLocations.citiesFor(_availableCountries).toSet();
      _cities.removeWhere((city) => !validCities.contains(city));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر الدول والمدن'),
      content: SizedBox(
        width: 380,
        height: 440,
        child: ListView(
          children: [
            Text('الدول', style: Theme.of(context).textTheme.titleSmall),
            if (widget.allowAll)
              CheckboxListTile(
                key: const ValueKey('location-all'),
                value: _countries.isEmpty && _cities.isEmpty,
                title: const Text('الكل'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (_) => setState(() {
                  _countries.clear();
                  _cities.clear();
                }),
              ),
            ...GulfLocations.countries.map(
              (country) => CheckboxListTile(
                key: ValueKey('country-$country'),
                value: _countries.contains(country),
                title: Text(country),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (selected) =>
                    _toggleCountry(country, selected == true),
              ),
            ),
            const Divider(),
            Text('المدن', style: Theme.of(context).textTheme.titleSmall),
            for (final country in _availableCountries) ...[
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, top: 8),
                child: Text(
                  country,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...(GulfLocations.citiesByCountry[country] ?? const <String>[])
                  .map(
                    (city) => CheckboxListTile(
                      key: ValueKey('city-$city'),
                      value: _cities.contains(city),
                      title: Text(city),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (selected) => setState(() {
                        if (selected == true) {
                          _cities.add(city);
                        } else {
                          _cities.remove(city);
                        }
                      }),
                    ),
                  ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            LocationSelection(
              countries: Set.unmodifiable(_countries),
              cities: Set.unmodifiable(_cities),
            ),
          ),
          child: const Text('تطبيق'),
        ),
      ],
    );
  }
}
