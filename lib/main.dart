import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/weather/presentation/pages/weather_page.dart';
import 'features/weather/presentation/providers/weather_provider.dart';
import 'core/utils/theme.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: WeatherPage(),  // Removed const here because WeatherPage constructor is not const
      ),
    );
  }
}
