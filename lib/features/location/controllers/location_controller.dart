import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocationController extends GetxController {
  LocationController({this._storage, Dio? dio}) : _dio = dio ?? Dio();

  final GetStorage? _storage;
  final Dio _dio;

  /// The app starts with the India-wide rate. A city is selected only after
  /// the user explicitly chooses one.
  final city = 'India'.obs;
  final citySuggestions = <String>[].obs;
  final isLocating = false.obs;
  final isSearchingCities = false.obs;
  final locationError = ''.obs;
  static const _cityKey = 'preferred_city_v1';
  static const _explicitCityKey = 'explicit_city_selection_v1';
  static const _userAgent = 'Sonexa/1.0 (mobile metal price tracker)';
  String? _memoryCity;
  Timer? _searchDebounce;
  DateTime? _lastSearchAt;
  int _searchGeneration = 0;

  @override
  void onInit() {
    super.onInit();
    final explicitlyChosen =
        _storage?.read<bool>(_explicitCityKey) ?? (_memoryCity != null);
    city.value = explicitlyChosen
        ? (_storage?.read<String>(_cityKey) ?? _memoryCity ?? 'India')
        : 'India';
  }

  Future<void> requestPermissionOnLaunch() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        locationError.value = 'Location permission is blocked. You can enable it in system Settings or choose a city manually.';
        return;
      }
      if (permission == LocationPermission.denied) {
        locationError.value = 'Location access was declined. You can still choose a city manually.';
        return;
      }
      if ((permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) &&
          city.value == 'Select city' &&
          await Geolocator.isLocationServiceEnabled()) {
        await useCurrentLocation();
      }
    } on MissingPluginException {
      locationError.value = 'Device location needs a full app restart. You can still search for your city.';
    } on Exception catch (error) {
      locationError.value = error.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Search is delayed and limited to one request per second for Nominatim.
  void searchCities(String query) {
    _searchDebounce?.cancel();
    locationError.value = '';
    citySuggestions.clear();
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) {
      citySuggestions.clear();
      isSearchingCities.value = false;
      return;
    }
    final generation = ++_searchGeneration;
    isSearchingCities.value = true;
    _searchDebounce = Timer(const Duration(milliseconds: 900), () {
      _fetchCities(cleanQuery, generation);
    });
  }

  Future<void> _fetchCities(String query, int generation) async {
    final lastSearch = _lastSearchAt;
    if (lastSearch != null) {
      final wait =
          const Duration(seconds: 1) - DateTime.now().difference(lastSearch);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
    }
    if (generation != _searchGeneration) return;
    _lastSearchAt = DateTime.now();
    try {
      final response = await _dio.get<dynamic>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'jsonv2',
          'addressdetails': 1,
          'limit': 6,
        },
        options: Options(
          headers: {'Accept': 'application/json', 'User-Agent': _userAgent},
        ),
      );
      if (generation != _searchGeneration) return;
      final rows = response.data;
      final names = <String>{};
      if (rows is List) {
        for (final row in rows.whereType<Map>()) {
          final address = row['address'] is Map
              ? Map<String, dynamic>.from(row['address'] as Map)
              : <String, dynamic>{};
          final name =
              _cityFromAddress(address) ??
              row['name']?.toString() ??
              row['display_name']?.toString().split(',').first.trim();
          if (name != null && name.isNotEmpty) names.add(name);
        }
      }
      citySuggestions.assignAll(names);
      if (names.isEmpty) locationError.value = 'No matching cities found.';
    } on DioException {
      if (generation == _searchGeneration) {
        locationError.value =
            'City search is unavailable. Check your connection.';
        citySuggestions.clear();
      }
    } finally {
      if (generation == _searchGeneration) isSearchingCities.value = false;
    }
  }

  Future<void> selectCity(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    _cancelCitySearch();
    city.value = cleanName;
    _memoryCity = cleanName;
    locationError.value = '';
    if (cleanName == 'India') {
      _memoryCity = null;
      await _storage?.remove(_explicitCityKey);
      await _storage?.remove(_cityKey);
    } else {
      await _storage?.write(_cityKey, cleanName);
      await _storage?.write(_explicitCityKey, true);
    }
  }

  Future<void> useCurrentLocation() async {
    if (isLocating.value) return;
    _cancelCitySearch();
    isLocating.value = true;
    locationError.value = '';
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Turn on location services and try again.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was not granted.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Enable location permission for Sonexa in Settings.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final response = await _dio.get<dynamic>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': position.latitude,
          'lon': position.longitude,
          'zoom': 10,
          'addressdetails': 1,
        },
        options: Options(
          headers: {'Accept': 'application/json', 'User-Agent': _userAgent},
        ),
      );
      final data = response.data;
      final address = data is Map && data['address'] is Map
          ? Map<String, dynamic>.from(data['address'] as Map)
          : <String, dynamic>{};
      final resolved = _cityFromAddress(address);
      if (resolved == null || resolved.isEmpty) {
        throw Exception('Could not find a city for your current location.');
      }
      await selectCity(resolved);
    } on MissingPluginException {
      locationError.value = 'Device location needs a full app restart. Search for your city below instead.';
    } on Exception catch (error) {
      locationError.value = error is DioException
          ? 'Could not look up your location. Check your connection and try again.'
          : error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLocating.value = false;
    }
  }

  String? _cityFromAddress(Map<String, dynamic> address) {
    // Reverse geocoding often returns a locality or taluka as `village` or
    // `municipality`. Prefer the city/district so the location pill does not
    // label a neighborhood as the selected city (for example, Ahmedabad
    // instead of Ghatlodiya Taluka).
    for (final key in ['city', 'town', 'state_district', 'county']) {
      final value = address[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  void _cancelCitySearch() {
    _searchDebounce?.cancel();
    _searchGeneration++;
    isSearchingCities.value = false;
  }

  @override
  void onClose() {
    _cancelCitySearch();
    super.onClose();
  }
}
