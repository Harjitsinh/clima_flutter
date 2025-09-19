import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/weather_model.dart';
import '../providers/weather_provider.dart';

class WeatherPage extends StatelessWidget {
  WeatherPage({super.key});

  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WeatherApp'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Get current location weather',
              onPressed: () {
                FocusScope.of(context).unfocus(); // Hide keyboard
                context.read<WeatherProvider>().fetchWeatherByCurrentLocation();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            hintText: 'Enter city name',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                FocusScope.of(context).unfocus(); // Hide keyboard
                                final city = _cityController.text.trim();
                                if (city.isNotEmpty) {
                                  provider.fetchWeatherByCity(city);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a city name')),
                                  );
                                }
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            final city = value.trim();
                            if (city.isNotEmpty) {
                              provider.fetchWeatherByCity(city);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (provider.isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.errorMessage != null)
                    Expanded(
                      child: Center(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (provider.currentWeather != null)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CurrentWeatherWidget(weather: provider.currentWeather!),
                              const SizedBox(height: 20),
                              if (provider.sevenDayForecast != null)
                                _SevenDayForecastWidget(forecast: provider.sevenDayForecast!)
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Center(
                          child: Text(
                            'Search for a city or tap location icon',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CurrentWeatherWidget extends StatelessWidget {
  final WeatherModel weather;
  const _CurrentWeatherWidget({required this.weather});

  @override
  Widget build(BuildContext context) {
    final iconUrl = 'https://openweathermap.org/img/wn/${weather.icon}@4x.png';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              weather.cityName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Image.network(iconUrl, width: 100, height: 100),
            const SizedBox(height: 8),
            Text(
              weather.description.capitalize(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              '${weather.temperature.toStringAsFixed(1)} °C',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoColumn(icon: Icons.water_drop, label: 'Humidity', value: '${weather.humidity}%'),
                _InfoColumn(icon: Icons.air, label: 'Wind', value: '${weather.windSpeed} m/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.onPrimaryContainer),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _SevenDayForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecast;

  const _SevenDayForecastWidget({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7-Day Forecast',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final day = forecast[index];
              final iconUrl = 'https://openweathermap.org/img/wn/${day.icon}@2x.png';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekday(day.date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Image.network(iconUrl, width: 50, height: 50),
                      const SizedBox(height: 8),
                      Text(
                        day.description.capitalize(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${day.maxTemp.toStringAsFixed(0)}° / ${day.minTemp.toStringAsFixed(0)}° C',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _weekday(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
