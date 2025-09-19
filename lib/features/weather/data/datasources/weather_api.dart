import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/weather_model.dart';
import '../../presentation/providers/weather_provider.dart'; // For DailyForecast model

class WeatherApi {
  Future<WeatherModel?> fetchWeatherByCity(String city) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.weatherByCity(city)));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherModel.fromJson(jsonData);
      } else {
        print('Failed to load weather. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during fetchWeatherByCity: $e');
      return null;
    }
  }

  Future<WeatherModel?> fetchWeatherByLocation(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.weatherByCoordinates(lat, lon)));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherModel.fromJson(jsonData);
      } else {
        print('Failed to load weather. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during fetchWeatherByLocation: $e');
      return null;
    }
  }

  /// Fetch 7-day forecast using One Call API
  Future<List<DailyForecast>?> fetch7DayForecast(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.oneCallForecast(lat, lon)));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dailyList = jsonData['daily'];

        return dailyList
            .map((dailyJson) => DailyForecast.fromJson(dailyJson))
            .toList();
      } else {
        print('Failed to load 7-day forecast. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during fetch7DayForecast: $e');
      return null;
    }
  }
}
