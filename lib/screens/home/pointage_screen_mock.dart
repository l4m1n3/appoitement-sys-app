// screens/home/pointage_screen_mock.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pointage_controller_mock.dart';

class PointageScreenMock extends StatelessWidget {
  final controller = Get.put(PointageControllerMock());

  PointageScreenMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pointage MOCK"),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // _showHistory(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Message
            Obx(() => _buildStatusCard()),

            const SizedBox(height: 20),

            // Dernier pointage
            Obx(() => _buildLastPointage()),

            const SizedBox(height: 30),

            // Boutons
            Row(
              children: [
                Expanded(child: _buildButton("entrée", Colors.green, Icons.login)),
                const SizedBox(width: 16),
                Expanded(child: _buildButton("sortie", Colors.red, Icons.logout)),
              ],
            ),

            const SizedBox(height: 40),

            // Simulateur GPS
            _buildGpsSimulator(),

            const SizedBox(height: 30),

            // Historique mini
            _buildMiniHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.message.value.contains("Hors") ? Colors.red : Colors.purple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            controller.message.value.contains("enregistré") ? Icons.check_circle : Icons.info,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.message.value.isEmpty ? "Prêt (MOCK)" : controller.message.value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          if (controller.isLoading.value)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildLastPointage() {
    final p = controller.lastPointage.value;
    if (p == null) {
      return const Card(child: ListTile(title: Text("Aucun pointage")));
    }
    final heure = p['date_heure'].split(' ')[1].substring(0, 5);
    final type = p['type'] == 'entrée' ? 'Entrée' : 'Sortie';
    return Card(
      child: ListTile(
        leading: Icon(p['type'] == 'entrée' ? Icons.login : Icons.logout,
            color: p['type'] == 'entrée' ? Colors.green : Colors.red),
        title: Text("Dernier : $type"),
        subtitle: Text("à $heure"),
      ),
    );
  }

  Widget _buildButton(String type, Color color, IconData icon) {
    return Obx(() => ElevatedButton.icon(
          onPressed: controller.isLoading.value ? null : () => controller.pointer(type),
          icon: Icon(icon),
          label: Text(type.toUpperCase()),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ));
  }

  Widget _buildGpsSimulator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("SIMULATEUR GPS", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Obx(() => Text(
                  "Distance : ${controller.mockDistance.value.toInt()} m",
                  style: const TextStyle(fontSize: 16),
                )),
            Slider(
              value: controller.mockDistance.value,
              min: 0,
              max: 200,
              divisions: 20,
              label: controller.mockDistance.value.toInt().toString(),
              onChanged: controller.setDistance,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("0m"),
                Text("Rayon : ${controller.rayonMax.value.toInt()}m"),
                const Text("200m"),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => controller.setDistance(45),
              icon: const Icon(Icons.my_location),
              label: const Text("Me mettre DANS la zone"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Derniers pointages", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => Column(
                  children: controller.historique.take(5).map((p) {
                    final heure = p['date_heure'].split(' ')[1].substring(0, 5);
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        p['type'] == 'entrée' ? Icons.login : Icons.logout,
                        size: 16,
                        color: p['type'] == 'entrée' ? Colors.green : Colors.red,
                      ),
                      title: Text("${p['type']} à $heure", style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
    );
  }

  // void _showHistory(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) => DraggableScrollableSheet(
  //       expand: false,
  //       builder: (_, controller) => ListView.builder(
  //         controller: controller,
  //         itemCount: controller.historique.length,
  //         itemBuilder: (_, i) {
  //           final p = controller.historique[i];
  //           final heure = p['date_heure'].split(' ')[1].substring(0, 5);
  //           return ListTile(
  //             leading: Icon(p['type'] == 'entrée' ? Icons.login : Icons.logout,
  //                 color: p['type'] == 'entrée' ? Colors.green : Colors.red),
  //             title: Text("${p['type'].toUpperCase()} à $heure"),
  //             subtitle: Text(p['date_heure'].split(' ')[0]),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
}