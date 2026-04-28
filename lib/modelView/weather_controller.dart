import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class WeatherController extends GetxController {
  // API Configuration
  final  String _apiKey = '${dotenv.env['WEATHER_API_KEY']}';
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  // Observable variables
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Current weather data
  var cityName = 'Loading...'.obs;
  var currentTemp = '0°'.obs;
  var weatherCondition = 'Loading...'.obs;
  var highTemp = '0°'.obs;
  var lowTemp = '0°'.obs;
  var weatherIcon = ''.obs;
  var humidity = 0.obs;
  var windSpeed = '0 km/h'.obs;
  var uvIndex = 0.obs;
  var visibility = '0 km'.obs;

  // Forecast data
  var hourlyForecast = <Map<String, dynamic>>[].obs;
  var weeklyForecast = <Map<String, dynamic>>[].obs;

  // UI state
  var showHourlyForecast = true.obs;
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocationWeather();
  }

  // Get current location and fetch weather
  Future<void> getCurrentLocationWeather() async {
    try {
      isLoading(true);
      hasError(false);

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Default to Islamabad if permission denied
          await getWeatherByCity('Islamabad');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Default to Islamabad if permission permanently denied
        await getWeatherByCity('Islamabad');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get city name from coordinates
      // List<Placemark> placemarks = await placemarkFromCoordinates(
      //   position.latitude,
      //   position.longitude,
      // );

      // String city = placemarks.first.locality ?? 'Unknown';
      
      // Fetch weather for current location
      await getWeatherByCoordinates(position.latitude, position.longitude);
      
    } catch (e) {
      print('Location error: $e');
      // Fallback to Islamabad
      await getWeatherByCity('Islamabad');
    } finally {
      isLoading(false);
    }
  }

  // Get weather by city name
  Future<void> getWeatherByCity(String city) async {
    try {
      isLoading(true);
      hasError(false);

      // Current weather
      final currentResponse = await http.get(
        Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$city&aqi=yes'),
      );

      if (currentResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        _updateCurrentWeather(currentData);
      }

      // Forecast weather (7 days)
      final forecastResponse = await http.get(
        Uri.parse('$_baseUrl/forecast.json?key=$_apiKey&q=$city&days=7&aqi=no'),
      );

      if (forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body);
        _updateForecastWeather(forecastData);
      }

    } catch (e) {
      hasError(true);
      errorMessage('Error fetching weather data: $e');
      print('Weather API error: $e');
    } finally {
      isLoading(false);
    }
  }

  // Get weather by coordinates
  Future<void> getWeatherByCoordinates(double lat, double lon) async {
    try {
      isLoading(true);
      hasError(false);

      // Current weather
      final currentResponse = await http.get(
        Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$lat,$lon&aqi=yes'),
      );

      if (currentResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        _updateCurrentWeather(currentData);
      }

      // Forecast weather
      final forecastResponse = await http.get(
        Uri.parse('$_baseUrl/forecast.json?key=$_apiKey&q=$lat,$lon&days=7&aqi=no'),
      );

      if (forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body);
        _updateForecastWeather(forecastData);
      }

    } catch (e) {
      hasError(true);
      errorMessage('Error fetching weather data: $e');
      print('Weather API error: $e');
    } finally {
      isLoading(false);
    }
  }

  // Update current weather data
  void _updateCurrentWeather(Map<String, dynamic> data) {
    final location = data['location'];
    final current = data['current'];

    cityName(location['name'] ?? 'Unknown');
    currentTemp('${current['temp_c']?.round() ?? 0}°');
    weatherCondition(current['condition']['text'] ?? 'Unknown');
    weatherIcon(current['condition']['icon'] ?? '');
    humidity(current['humidity'] ?? 0);
    windSpeed('${current['wind_kph']?.round() ?? 0} km/h');
    uvIndex(current['uv']?.round() ?? 0);
    visibility('${current['vis_km']?.round() ?? 0} km');
  }

  // Update forecast weather data
  void _updateForecastWeather(Map<String, dynamic> data) {
    final forecast = data['forecast']['forecastday'] as List;
    
    // Set today's high/low temperatures
    if (forecast.isNotEmpty) {
      final today = forecast.first['day'];
      highTemp('${today['maxtemp_c']?.round() ?? 0}°');
      lowTemp('${today['mintemp_c']?.round() ?? 0}°');
    }

    // Update hourly forecast for today
    if (forecast.isNotEmpty) {
      final todayHours = forecast.first['hour'] as List;
      hourlyForecast.value = todayHours.map((hour) {
        final time = DateTime.parse(hour['time']);
        return {
          'time': '${time.hour.toString().padLeft(2, '0')}:00',
          'temp': '${hour['temp_c']?.round() ?? 0}°',
          'icon': _getWeatherEmoji(hour['condition']['code']),
          'condition': hour['condition']['text'],
        };
      }).toList();
    }

    // Update weekly forecast
    weeklyForecast.value = forecast.map((day) {
      final date = DateTime.parse(day['date']);
      final dayName = _getDayName(date);
      
      return {
        'day': dayName,
        'temp': '${day['day']['maxtemp_c']?.round() ?? 0}°/${day['day']['mintemp_c']?.round() ?? 0}°',
        'icon': _getWeatherEmoji(day['day']['condition']['code']),
        'condition': day['day']['condition']['text'],
      };
    }).toList();
  }

  // Get weather emoji based on condition code
  String _getWeatherEmoji(int code) {
    switch (code) {
      case 1000: return '☀️'; // Sunny
      case 1003: return '🌤️'; // Partly cloudy
      case 1006: return '☁️'; // Cloudy
      case 1009: return '☁️'; // Overcast
      case 1030: case 1135: case 1147: return '🌫️'; // Mist/Fog
      case 1063: case 1180: case 1183: case 1186: case 1189: case 1192: case 1195: case 1240: case 1243: case 1246: return '🌧️'; // Rain
      case 1066: case 1069: case 1072: case 1114: case 1117: case 1210: case 1213: case 1216: case 1219: case 1222: case 1225: case 1237: case 1249: case 1252: case 1255: case 1258: case 1261: case 1264: return '🌨️'; // Snow
      case 1087: case 1273: case 1276: case 1279: case 1282: return '⛈️'; // Thunder
      default: return '🌤️'; // Default partly cloudy
    }
  }

  // Get day name from date
  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    
    if (targetDay == today) return 'Today';
    if (targetDay == today.add(Duration(days: 1))) return 'Tomorrow';
    
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  // Toggle between hourly and weekly forecast
  void setHourlyForecast() {
    showHourlyForecast(true);
  }

  void setWeeklyForecast() {
    showHourlyForecast(false);
  }

  // Update selected date and fetch hourly data for that date
  void updateSelectedDate(DateTime date) {
    selectedDate(date);
    // You can add logic here to fetch hourly data for the selected date
  }

  // Get hourly weather data (filtered by current hour and next few hours)
  List<Map<String, String>> getHourlyWeather() {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Return next 4 hours from current time
    return hourlyForecast
        .where((weather) {
          final hour = int.parse(weather['time'].split(':')[0]);
          return hour >= currentHour;
        })
        .take(4)
        .map((weather) => {
          'time': weather['time'].toString(),
          'temp': weather['temp'].toString(),
          'icon': weather['icon'].toString(),
        })
        .toList();
  }

  // Get weekly weather data
  List<Map<String, String>> getWeeklyWeather() {
    return weeklyForecast
        .map((weather) => {
          'day': weather['day'].toString(),
          'temp': weather['temp'].toString(),
          'icon': weather['icon'].toString(),
        })
        .toList();
  }

  // Refresh weather data
  Future<void> refreshWeather() async {
    await getCurrentLocationWeather();
  }

  // Search weather by city
  Future<void> searchWeatherByCity(String city) async {
    if (city.trim().isEmpty) return;
    await getWeatherByCity(city.trim());
  }
}