import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../controllers/pointage_controller.dart';

class PointageScreen extends StatelessWidget {
  final PointageController controller = Get.find();

  PointageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pointage Bluetooth"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout, size: 26),
            tooltip: "Déconnexion",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchLastPointage,
        color: Colors.indigo,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Carte d'état
              Obx(() => _buildStatusCard(context)),
              const SizedBox(height: 24),

              // 2. Dernier pointage
              _buildLastPointageSection(),
              const SizedBox(height: 32),

              // 3. Bouton Bluetooth (seul)
              _buildBluetoothButton(context),

              const SizedBox(height: 32),

              // 4. Portiques détectés
              _buildDetectedPortiques(),

              const SizedBox(height: 24),

              // 5. Historique
              _buildRecentHistory(),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 1. CARTE D'ÉTAT
  // ──────────────────────────────────────────────────────────────
  Widget _buildStatusCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Icon(
              _getIcon(),
              key: ValueKey(controller.message.value),
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.message.value.isNotEmpty ? controller.message.value : "Approchez-vous du portique",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ],
            ),
          ),
          if (controller.isScanning.value || controller.isLoading.value)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  String _getTitle() {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("enregistré") || msg.contains("ok")) return "POINTAGE RÉUSSI";
    if (msg.contains("non autorisé")) return "ACCÈS REFUSÉ";
    if (msg.contains("scan")) return "SCAN EN COURS";
    if (msg.contains("portique")) return "PORTIQUE DÉTECTÉ";
    return "BLUETOOTH";
  }

  // ──────────────────────────────────────────────────────────────
  // 2. DERNIER POINTAGE
  // ──────────────────────────────────────────────────────────────
  Widget _buildLastPointageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text("DERNIER POINTAGE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2)),
        ),
        Obx(() => _buildLastPointageCard()),
      ],
    );
  }

  Widget _buildLastPointageCard() {
    final p = controller.lastPointage.value;
    if (p == null || p['date_heure'] == null) {
      return _buildEmptyCard();
    }

    final isEntree = p['type'] == 'entrée';
    final time = _formatTime(p['date_heure']);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEntree ? Colors.green : Colors.red,
          child: Icon(isEntree ? Icons.login : Icons.logout, color: Colors.white),
        ),
        title: Text(isEntree ? "Entrée" : "Sortie", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isEntree ? Colors.green.shade800 : Colors.red.shade800)),
        subtitle: Text(time),
        trailing: Chip(
          backgroundColor: isEntree ? Colors.green.shade100 : Colors.red.shade100,
          label: Text(isEntree ? "ARRIVÉE" : "DÉPART", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isEntree ? Colors.green.shade800 : Colors.red.shade800)),
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.grey.shade300, child: const Icon(Icons.history, color: Colors.grey)),
        title: const Text("Aucun pointage", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Passez près d’un portique pour pointer"),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 3. BOUTON BLUETOOTH
  // ──────────────────────────────────────────────────────────────
  Widget _buildBluetoothButton(BuildContext context) {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.isScanning.value || controller.isLoading.value
            ? null
            : () => _startScanAndPoint(),
        icon: controller.isScanning.value
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : const Icon(Icons.bluetooth_searching_rounded, size: 32),
        label: Text(
          controller.isScanning.value ? "Recherche..." : "DÉTECTER LE PORTIQUE",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
        ),
      ),
    ));
  }

  void _startScanAndPoint() {
    controller.startBluetoothScan();
    Future.delayed(const Duration(seconds: 10), () {
      if (controller.nearbyPortiques.isNotEmpty) {
        Get.dialog(
          AlertDialog(
            icon: const Icon(Icons.bluetooth_connected, size: 40, color: Colors.indigo),
            title: const Text("Portique détecté !"),
            content: Text("Pointer en ${controller.getNextType()} ?"),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text("Non")),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.pointerViaBluetooth(controller.getNextType());
                },
                child: const Text("Pointer"),
              ),
            ],
          ),
        );
      }
    });
  }

  // ──────────────────────────────────────────────────────────────
  // 4. PORTIQUES DÉTECTÉS
  // ──────────────────────────────────────────────────────────────
  Widget _buildDetectedPortiques() {
    return Obx(() => controller.nearbyPortiques.isEmpty
        ? const SizedBox()
        : Card(
            color: Colors.indigo.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bluetooth, color: Colors.indigo.shade700),
                      const SizedBox(width: 8),
                      Text("Portiques à proximité", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...controller.nearbyPortiques.map((mac) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(controller.selectedPortique.value == mac ? Icons.check_circle : Icons.circle_outlined, size: 16, color: controller.selectedPortique.value == mac ? Colors.green : Colors.grey),
                        const SizedBox(width: 8),
                        Text(mac, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 5. HISTORIQUE
  // ──────────────────────────────────────────────────────────────
  Widget _buildRecentHistory() {
    final history = [
      {'type': 'entrée', 'time': '08:30'},
      {'type': 'sortie', 'time': '12:00'},
      {'type': 'entrée', 'time': '13:30'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text("AUJOURD'HUI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2)),
        ),
        ...history.map((h) {
          final isEntree = h['type'] == 'entrée';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: isEntree ? Colors.green.shade100 : Colors.red.shade100, child: Icon(isEntree ? Icons.login : Icons.logout, size: 16, color: isEntree ? Colors.green : Colors.red)),
                const SizedBox(width: 12),
                Text(isEntree ? "Entrée" : "Sortie", style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(h['time']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // DÉCONNEXION
  // ──────────────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded, size: 40, color: Colors.orange),
              const SizedBox(height: 16),
              const Text("Déconnexion", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Voulez-vous vous déconnecter ?", textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: const Text("Annuler"))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: _logout, child: const Text("Oui"))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() async {
    await GetStorage().erase();
    Get.offAllNamed('/login');
    Get.snackbar("Déconnecté", "À bientôt !", backgroundColor: Colors.green, colorText: Colors.white);
  }

  // ──────────────────────────────────────────────────────────────
  // UTILITAIRES
  // ──────────────────────────────────────────────────────────────
  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return "??:??";
    }
  }

  LinearGradient _getGradient() {
    final color = _getColor();
    return LinearGradient(colors: [color, color.withOpacity(0.8)]);
  }

  Color _getColor() {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("enregistré") || msg.contains("ok")) return Colors.green;
    if (msg.contains("refusé") || msg.contains("non autorisé")) return Colors.red;
    if (msg.contains("scan") || msg.contains("recherche")) return Colors.orange;
    return Colors.indigo.shade600;
  }

  IconData _getIcon() {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("enregistré")) return Icons.check_circle;
    if (msg.contains("refusé")) return Icons.error;
    if (msg.contains("scan")) return Icons.search;
    if (msg.contains("portique")) return Icons.bluetooth_connected;
    return Icons.bluetooth;
  }
}