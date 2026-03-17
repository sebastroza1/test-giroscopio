import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/motion_controller.dart';

class MotionPage extends StatelessWidget {
  const MotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MotionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACV Motion Monitor'),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConnectionCard(controller),
                  const SizedBox(height: 12),
                  _buildSensorCard(
                    title: 'Teléfono - Giroscopio',
                    x: controller.lastPhoneGyroscope?.x,
                    y: controller.lastPhoneGyroscope?.y,
                    z: controller.lastPhoneGyroscope?.z,
                  ),
                  _buildSensorCard(
                    title: 'Teléfono - Acelerómetro',
                    x: controller.lastPhoneAccelerometer?.x,
                    y: controller.lastPhoneAccelerometer?.y,
                    z: controller.lastPhoneAccelerometer?.z,
                  ),
                  _buildSensorCard(
                    title: 'Reloj - Giroscopio',
                    x: controller.lastWatchGyroscope?.x,
                    y: controller.lastWatchGyroscope?.y,
                    z: controller.lastWatchGyroscope?.z,
                  ),
                  _buildSensorCard(
                    title: 'Reloj - Acelerómetro',
                    x: controller.lastWatchAccelerometer?.x,
                    y: controller.lastWatchAccelerometer?.y,
                    z: controller.lastWatchAccelerometer?.z,
                  ),
                  _buildHeartRateCard(controller.lastWatchHeartRate?.bpm),
                  if (controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionCard(MotionController controller) {
    final state = controller.watchConnectionState;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proveedor: ${state.provider}'),
            Text('Disponible: ${state.available}'),
            Text('Conectado: ${state.connected}'),
            Text('Mensaje: ${state.message}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: controller.connectWatch,
                  child: const Text('Conectar reloj'),
                ),
                ElevatedButton(
                  onPressed: controller.disconnectWatch,
                  child: const Text('Desconectar reloj'),
                ),
                ElevatedButton(
                  onPressed: controller.startAllWatchSensors,
                  child: const Text('Iniciar sensores reloj'),
                ),
                ElevatedButton(
                  onPressed: controller.stopAllWatchSensors,
                  child: const Text('Detener sensores reloj'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required double? x,
    required double? y,
    required double? z,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          'x: ${_f(x)}  y: ${_f(y)}  z: ${_f(z)}',
        ),
      ),
    );
  }

  Widget _buildHeartRateCard(int? bpm) {
    return Card(
      child: ListTile(
        title: const Text('Reloj - Ritmo cardiaco'),
        subtitle: Text('BPM: ${bpm ?? '-'}'),
      ),
    );
  }

  String _f(double? v) => v?.toStringAsFixed(2) ?? '-';
}
