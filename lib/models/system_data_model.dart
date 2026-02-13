class SystemDataModel {
  final double voltage;
  final double current;
  final double power;
  final double temperature;
  final double dailyLiters;
  final double energyHour;
  final double dailyEnergy;
  final String status;

  SystemDataModel({
    required this.voltage,
    required this.current,
    required this.power,
    required this.temperature,
    required this.dailyLiters,
    required this.energyHour,
    required this.dailyEnergy,
    required this.status,
  });

  factory SystemDataModel.fromJson(Map<String, dynamic> json) {
    return SystemDataModel(
      voltage: (json['voltage'] ?? 0.0).toDouble(),
      current: (json['current'] ?? 0.0).toDouble(),
      power: (json['power'] ?? 0.0).toDouble(),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      dailyLiters: (json['daily_liters'] ?? 0.0).toDouble(),
      energyHour: (json['energy_hour'] ?? 0.0).toDouble(),
      dailyEnergy: (json['daily_energy'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voltage': voltage,
      'current': current,
      'power': power,
      'temperature': temperature,
      'daily_liters': dailyLiters,
      'energy_hour': energyHour,
      'daily_energy': dailyEnergy,
      'status': status,
    };
  }
}
