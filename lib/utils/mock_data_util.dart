import 'dart:math';
import '../models/system_data_model.dart';
import '../services/api_service.dart';

class MockDataUtil {
  static final ApiService _apiService = ApiService();
  static final Random _random = Random();

  static Future<void> insertMockSystemData({int? hour}) async {
    double roundToTwo(double value) => double.parse(value.toStringAsFixed(2));

    final mockData = SystemDataModel(
      voltage: roundToTwo(220.0 + _random.nextDouble() * 20), // 220-240V
      current: roundToTwo(5.0 + _random.nextDouble() * 10),   // 5-15A
      power: roundToTwo(1000.0 + _random.nextDouble() * 2000), // 1000-3000W
      temperature: roundToTwo(25.0 + _random.nextDouble() * 15), // 25-40C
      waterLevel: _random.nextInt(100),            // 0-100%
      energyHour: roundToTwo(1.0 + _random.nextDouble() * 2),  // 1-3 kWh
      dailyEnergy: roundToTwo(10.0 + _random.nextDouble() * 20), // 10-30 kWh
      status: _random.nextBool() ? 'Normal' : 'Active',
    );

    DateTime? customTime;
    if (hour != null) {
      final now = DateTime.now();
      customTime = DateTime(now.year, now.month, now.day, hour);
    }

    await _apiService.updateSystemData(mockData, customTimestamp: customTime);
  }

  static Future<void> simulateFullDay() async {
    for (int i = 6; i <= 18; i++) {
      await insertMockSystemData(hour: i);
    }
  }
}
