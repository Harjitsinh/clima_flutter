class ApiConstants {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String apiKey = 'd65fdc935d70427dd256713653414e7d'; // Your API key

  static String weatherByCity(String city) =>
      '$baseUrl/weather?q=$city&appid=$apiKey&units=metric';

  static String weatherByCoordinates(double lat, double lon) =>
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

  static String oneCallForecast(double lat, double lon) =>
      '$baseUrl/onecall?lat=$lat&lon=$lon&exclude=current,minutely,hourly,alerts&appid=$apiKey&units=metric';
}
