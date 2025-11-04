// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/pointage_controller.dart';

// class PointageScreen extends StatelessWidget {
//   final PointageController controller = Get.put(PointageController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Sélection du périphérique',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Theme.of(context).colorScheme.primary,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Message d’état
//             Obx(() => _buildStatusMessage(context)),

//             const SizedBox(height: 20),

//             // Sélecteur de mode de scan
//             _buildScanModeSwitch(context),

//             const SizedBox(height: 24),

//             // Bouton de scan
//             _buildScanButton(context),

//             const SizedBox(height: 24),

//             // Liste des appareils détectés
//             _buildDevicesList(context),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Message d’état
//   Widget _buildStatusMessage(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _getMessageColor(context),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           Icon(_getMessageIcon(), color: Colors.white),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               controller.message.value.isNotEmpty
//                   ? controller.message.value
//                   : "Aucun message pour le moment",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Switch pour choisir le mode de scan
//   Widget _buildScanModeSwitch(BuildContext context) {
//     return Obx(
//       () => Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(
//               controller.filterAuthorizedOnly.value
//                   ? "Mode : Portiques autorisés uniquement"
//                   : "Mode : Tous les périphériques Bluetooth",
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//               ),
//             ),
//           ),
//           Switch(
//             value: controller.filterAuthorizedOnly.value,
//             activeColor: Theme.of(context).colorScheme.primary,
//             onChanged: (value) {
//               controller.filterAuthorizedOnly.value = value;
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   /// Bouton de scan
//   Widget _buildScanButton(BuildContext context) {
//     return Obx(
//       () => SizedBox(
//         width: double.infinity,
//         height: 52,
//         child: ElevatedButton(
//           onPressed: controller.isScanning.value
//               ? null
//               : () => controller.scanDevices(
//                   filterOnly: controller.filterAuthorizedOnly.value,
//                 ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Theme.of(context).colorScheme.primary,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: controller.isScanning.value
//               ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: const [
//                     SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Text("Scan en cours..."),
//                   ],
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: const [
//                     Icon(Icons.bluetooth_searching),
//                     SizedBox(width: 10),
//                     Text("Scanner les périphériques"),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }

//   /// Liste des appareils détectés
//   Widget _buildDevicesList(BuildContext context) {
//     return Obx(() {
//       if (controller.devicesList.isEmpty) {
//         return Expanded(
//           child: Center(
//             child: Text(
//               controller.isScanning.value
//                   ? "Recherche en cours..."
//                   : "Aucun périphérique trouvé",
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
//               ),
//             ),
//           ),
//         );
//       }

//       return Expanded(
//         child: ListView.builder(
//           itemCount: controller.devicesList.length,
//           itemBuilder: (context, index) {
//             final device = controller.devicesList[index];
//             final isSelected =
//                 controller.selectedDevice.value?.remoteId == device.remoteId;

//             return Card(
//               margin: const EdgeInsets.symmetric(vertical: 6),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               elevation: 2,
//               child: ListTile(
//                 leading: Icon(
//                   Icons.bluetooth,
//                   color: isSelected
//                       ? Theme.of(context).colorScheme.primary
//                       : Theme.of(
//                           context,
//                         ).colorScheme.onSurface.withOpacity(0.6),
//                 ),
//                 title: Text(
//                   device.platformName.isNotEmpty
//                       ? device.platformName
//                       : "Périphérique inconnu",
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Text(device.remoteId.str),
//                 trailing: ElevatedButton(
//                   onPressed: isSelected
//                       ? null
//                       : () => controller.connectToDevice(device),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isSelected
//                         ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
//                         : Theme.of(context).colorScheme.primary,
//                     foregroundColor: isSelected
//                         ? Theme.of(context).colorScheme.primary
//                         : Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(isSelected ? "Connecté" : "Connecter"),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     });
//   }

//   Color _getMessageColor(BuildContext context) {
//     final msg = controller.message.value.toLowerCase();
//     if (msg.contains("erreur") || msg.contains("échec"))
//       return Colors.redAccent;
//     if (msg.contains("connecté") || msg.contains("succès")) return Colors.green;
//     return Theme.of(context).colorScheme.primary;
//   }

//   IconData _getMessageIcon() {
//     final msg = controller.message.value.toLowerCase();
//     if (msg.contains("erreur") || msg.contains("échec")) return Icons.error;
//     if (msg.contains("connecté") || msg.contains("succès"))
//       return Icons.check_circle;
//     return Icons.info_outline;
//   }
// }
// screens/home/pointage_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pointage_controller.dart';

class PointageScreen extends StatelessWidget {
  final PointageController controller = Get.find<PointageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pointage"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Message d'état
            Obx(() => _buildStatusCard(context)),

            const SizedBox(height: 20),

            // Dernier pointage
            Obx(() => _buildLastPointage(context)),

            const SizedBox(height: 30),

            // Boutons Entrée / Sortie
            Row(
              children: [
                Expanded(child: _buildActionButton(context, "entrée", Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildActionButton(context, "sortie", Colors.red)),
              ],
            ),

            const Spacer(),

            // Zone GPS (remplace la carte)
            _buildGpsZoneInfo(context),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 1. Carte d'état (succès / erreur / chargement)
  // ──────────────────────────────────────────────────────────────
  Widget _buildStatusCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getMessageColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(_getMessageIcon(), color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.message.value.isNotEmpty
                  ? controller.message.value
                  : "Prêt à pointer",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          if (controller.isLoading.value)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 2. Dernier pointage
  // ──────────────────────────────────────────────────────────────
  Widget _buildLastPointage(BuildContext context) {
    final pointage = controller.lastPointage.value;
    if (pointage == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.history, color: Colors.grey),
          title: Text("Aucun pointage"),
          subtitle: Text("Première fois aujourd'hui ?"),
        ),
      );
    }

    final type = pointage['type'] == 'entrée' ? 'Entrée' : 'Sortie';
    final heure = pointage['date_heure'].split(' ')[1].substring(0, 5);

    return Card(
      child: ListTile(
        leading: Icon(
          pointage['type'] == 'entrée' ? Icons.login : Icons.logout,
          color: pointage['type'] == 'entrée' ? Colors.green : Colors.red,
        ),
        title: Text("Dernier : $type"),
        subtitle: Text("à $heure"),
        trailing: const Icon(Icons.access_time),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Boutons Entrée / Sortie
  // ──────────────────────────────────────────────────────────────
  Widget _buildActionButton(BuildContext context, String type, Color color) {
    final label = type == 'entrée' ? "Entrée" : "Sortie";
    final icon = type == 'entrée' ? Icons.login : Icons.logout;

    return Obx(() => SizedBox(
          height: 100,
          child: ElevatedButton.icon(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.pointer(type),
            icon: Icon(icon, size: 32),
            label: Text(label, style: const TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
            ),
          ),
        ));
  }

  // ──────────────────────────────────────────────────────────────
  // 4. Zone GPS (remplace la carte)
  // ──────────────────────────────────────────────────────────────
  Widget _buildGpsZoneInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.isInsideZone.value ? Icons.location_on : Icons.location_off,
                color: controller.isInsideZone.value ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                controller.isInsideZone.value
                    ? "Dans la zone autorisée"
                    : "Hors zone",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: controller.isInsideZone.value ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Zone : 100m autour de l'entreprise",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 5. Couleurs & icônes dynamiques
  // ──────────────────────────────────────────────────────────────
  Color _getMessageColor(BuildContext context) {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("hors zone") || msg.contains("impossible")) return Colors.redAccent;
    if (msg.contains("enregistré") || msg.contains("succès")) return Colors.green;
    if (msg.contains("position")) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getMessageIcon() {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("hors zone") || msg.contains("refusée")) return Icons.location_off;
    if (msg.contains("enregistré")) return Icons.check_circle;
    if (msg.contains("position")) return Icons.location_searching;
    return Icons.info;
  }
}