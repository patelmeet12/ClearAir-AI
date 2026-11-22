import 'package:flutter/material.dart';
import '../../domain/models/air_quality.dart';

class AtmosphericConditionsBar extends StatelessWidget {
  final AirQualityData airQuality;

  const AtmosphericConditionsBar({
    super.key,
    required this.airQuality,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(child: _weatherItem(context, Icons.thermostat, '${airQuality.temperatureC.toStringAsFixed(1)}°C', 'Temp')),
          Expanded(child: _weatherItem(context, Icons.water_drop_outlined, '${airQuality.humidityPercent.toStringAsFixed(0)}%', 'Humidity')),
          Expanded(child: _weatherItem(context, Icons.air, '${airQuality.windSpeedKmh.toStringAsFixed(1)} km/h', 'Wind')),
          Expanded(
            child: _weatherItem(
              context,
              airQuality.weatherCode == 45 ? Icons.foggy : Icons.wb_sunny_outlined,
              airQuality.weatherCode == 45 ? 'Smog/Fog' : 'Fair',
              'Sky',
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherItem(BuildContext context, IconData icon, String val, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D9488)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(title, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      ],
    );
  }
}
