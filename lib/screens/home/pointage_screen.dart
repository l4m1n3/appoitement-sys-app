import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pointage_controller.dart';

class PointageScreen extends StatelessWidget {
  final PointageController controller = Get.put(PointageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sélection du périphérique',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message d’état
            Obx(() => _buildStatusMessage(context)),

            const SizedBox(height: 20),

            // Sélecteur de mode de scan
            _buildScanModeSwitch(context),

            const SizedBox(height: 24),

            // Bouton de scan
            _buildScanButton(context),

            const SizedBox(height: 24),

            // Liste des appareils détectés
            _buildDevicesList(context),
          ],
        ),
      ),
    );
  }

  /// Message d’état
  Widget _buildStatusMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _getMessageColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(_getMessageIcon(), color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              controller.message.value.isNotEmpty
                  ? controller.message.value
                  : "Aucun message pour le moment",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Switch pour choisir le mode de scan
  Widget _buildScanModeSwitch(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              controller.filterAuthorizedOnly.value
                  ? "Mode : Portiques autorisés uniquement"
                  : "Mode : Tous les périphériques Bluetooth",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Switch(
            value: controller.filterAuthorizedOnly.value,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              controller.filterAuthorizedOnly.value = value;
            },
          ),
        ],
      ),
    );
  }

  /// Bouton de scan
  Widget _buildScanButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.isScanning.value
              ? null
              : () => controller.scanDevices(
                  filterOnly: controller.filterAuthorizedOnly.value,
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: controller.isScanning.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text("Scan en cours..."),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.bluetooth_searching),
                    SizedBox(width: 10),
                    Text("Scanner les périphériques"),
                  ],
                ),
        ),
      ),
    );
  }

  /// Liste des appareils détectés
  Widget _buildDevicesList(BuildContext context) {
    return Obx(() {
      if (controller.devicesList.isEmpty) {
        return Expanded(
          child: Center(
            child: Text(
              controller.isScanning.value
                  ? "Recherche en cours..."
                  : "Aucun périphérique trouvé",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: controller.devicesList.length,
          itemBuilder: (context, index) {
            final device = controller.devicesList[index];
            final isSelected =
                controller.selectedDevice.value?.remoteId == device.remoteId;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  Icons.bluetooth,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                ),
                title: Text(
                  device.platformName.isNotEmpty
                      ? device.platformName
                      : "Périphérique inconnu",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(device.remoteId.str),
                trailing: ElevatedButton(
                  onPressed: isSelected
                      ? null
                      : () => controller.connectToDevice(device),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(isSelected ? "Connecté" : "Connecter"),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Color _getMessageColor(BuildContext context) {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("erreur") || msg.contains("échec"))
      return Colors.redAccent;
    if (msg.contains("connecté") || msg.contains("succès")) return Colors.green;
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getMessageIcon() {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("erreur") || msg.contains("échec")) return Icons.error;
    if (msg.contains("connecté") || msg.contains("succès"))
      return Icons.check_circle;
    return Icons.info_outline;
  }
}
