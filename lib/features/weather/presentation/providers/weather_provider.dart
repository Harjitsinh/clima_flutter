import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/datasources/weather_api.dart';
import '../../data/models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherApi _weatherApi = WeatherApi();

  WeatherModel? _currentWeather;
  List<DailyForecast>? _sevenDayForecast;

  bool _isLoading = false;
  String? _errorMessage;

  WeatherModel? get currentWeather => _currentWeather;
  List<DailyForecast>? get sevenDayForecast => _sevenDayForecast;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch weather by city name
  Future<void> fetchWeatherByCity(String city) async {
    _setLoading(true);
    _clearError();

    final weather = await _weatherApi.fetchWeatherByCity(city);
    if (weather != null) {
      _currentWeather = weather;
      await _fetch7DayForecast(weather);
      _setLoading(false);
      notifyListeners();
    } else {
      _setError('Could not fetch weather for city "$city".');
      _setLoading(false);
    }
  }

  /// Fetch weather by current location (using Geolocator)
  Future<void> fetchWeatherByCurrentLocation() async {
    _setLoading(true);
    _clearError();

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        _setError('Location permission denied.');
        _setLoading(false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final weather = await _weatherApi.fetchWeatherByLocation(
          position.latitude, position.longitude);

      if (weather != null) {
        _currentWeather = weather;
        await _fetch7DayForecast(weather);
        _setLoading(false);
        notifyListeners();
      } else {
        _setError('Could not fetch weather for current location.');
        _setLoading(false);
      }
    } catch (e) {
      _setError('Failed to get current location: $e');
      _setLoading(false);
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setError('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return false;
      }
    }

    return true;
  }

  Future<void> _fetch7DayForecast(WeatherModel weather) async {
    final forecastJson = await _weatherApi.fetch7DayForecast(
        weather.latitude, weather.longitude);

    if (forecastJson != null) {
      // Assuming forecastJson is a List<dynamic> representing daily forecasts
      _sevenDayForecast = (forecastJson as List)
          .map((json) => DailyForecast.fromJson(json))
          .toList();
    } else {
      _sevenDayForecast = null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

/// Daily forecast model (simplified for UI)
class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String icon;
  final String description;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
    required this.description,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: (json['temp']['min'] as num).toDouble(),
      maxTemp: (json['temp']['max'] as num).toDouble(),
      icon: json['weather'][0]['icon'],
      description: json['weather'][0]['description'],
    );
  }
}
