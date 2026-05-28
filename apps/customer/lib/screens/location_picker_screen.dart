import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../widgets/common_widgets.dart';

class LocationPickResult {
  const LocationPickResult({required this.address, required this.point});

  final String address;
  final LatLng point;
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.title,
    this.initialQuery,
    this.initialPoint,
  });

  final String title;
  final String? initialQuery;
  final LatLng? initialPoint;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const LatLng _defaultCenter = LatLng(22.9734, 78.6569);

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();

  Timer? _debounce;
  List<LocationSuggestion> _suggestions = const <LocationSuggestion>[];
  bool _isSearching = false;
  bool _isResolvingAddress = false;
  LatLng? _selectedPoint;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _selectedPoint = widget.initialPoint;
    if (_selectedPoint != null) {
      _resolveAddress(_selectedPoint!);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final suggestions = await _locationService.searchPlaces(query);

      if (!mounted) {
        return;
      }

      setState(() {
        _suggestions = suggestions;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _suggestions = const <LocationSuggestion>[];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchPlaces(value);
    });
  }

  Future<void> _resolveAddress(LatLng point) async {
    setState(() {
      _isResolvingAddress = true;
    });

    try {
      final resolvedAddress = await _locationService.resolveAddress(point);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedAddress = resolvedAddress;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedAddress = 'Pinned location (${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)})';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingAddress = false;
        });
      }
    }
  }

  Future<void> _setLocation(LatLng point, {String? address}) async {
    setState(() {
      _selectedPoint = point;
      _selectedAddress = address;
      _suggestions = const <LocationSuggestion>[];
    });

    _mapController.move(point, 13);

    if (address == null || address.trim().isEmpty) {
      await _resolveAddress(point);
      return;
    }

    _searchController.text = address;
  }

  @override
  Widget build(BuildContext context) {
    final center = _selectedPoint ?? _defaultCenter;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search area, landmark, or city',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? FreightFairColors.darkBorder : FreightFairColors.border)),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_rounded, color: FreightFairColors.accentDark),
                    title: Text(
                      suggestion.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _setLocation(suggestion.point, address: suggestion.address),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: _selectedPoint == null ? 5.2 : 12.5,
                    minZoom: 4,
                    maxZoom: 18,
                    onTap: (_, point) => _setLocation(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.freightfair.customer',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    if (_selectedPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint!,
                            width: 44,
                            height: 44,
                            child: const Icon(Icons.place_rounded, color: Colors.redAccent, size: 34),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: InfoCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Address',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: FreightFairColors.adaptiveSecondaryText(context),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedAddress ?? 'Tap on map or search to set a location',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_isResolvingAddress)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Confirm Location',
                    onPressed: _selectedPoint == null || _selectedAddress == null
                        ? null
                        : () {
                            Navigator.of(context).pop(
                              LocationPickResult(address: _selectedAddress!, point: _selectedPoint!),
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
