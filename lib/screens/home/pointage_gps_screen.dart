import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../controllers/pointage_controller.dart';
import '../../controllers/auth_controller.dart';

class PointageScreen extends StatelessWidget {
  final PointageController controller = Get.find();

  PointageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pointage"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout, size: 26),
            tooltip: "Se déconnecter",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchLastPointage,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Carte d'état avec animation
              Obx(() => _buildStatusCard(context)),
              
              const SizedBox(height: 24),

              // 2. Dernier pointage avec indicateur visuel
              _buildLastPointageSection(),

              const SizedBox(height: 32),

              // 3. Boutons d'action principaux
              _buildActionButtons(context),

              const SizedBox(height: 32),

              // 4. Carte d'information GPS
              _buildGpsCard(),

              // 5. Historique récent (optionnel)
              const SizedBox(height: 24),
              _buildRecentHistory(),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 1. CARTE D'ÉTAT AMÉLIORÉE
  // ──────────────────────────────────────────────────────────────
  Widget _buildStatusCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getMessageGradient(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getMessageColor().withOpacity(0.3),
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
              _getMessageIcon(),
              key: ValueKey(controller.message.value),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.message.value.isNotEmpty
                      ? controller.message.value
                      : "Prêt à pointer",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusTitle() {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("hors zone")) return "HORS ZONE";
    if (msg.contains("enregistré")) return "SUCCÈS";
    if (msg.contains("position")) return "GPS";
    return "STATUT";
  }

  // ──────────────────────────────────────────────────────────────
  // 2. SECTION DERNIER POINTAGE
  // ──────────────────────────────────────────────────────────────
  Widget _buildLastPointageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            "DERNIER POINTAGE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        Obx(() => _buildLastPointageCard()),
      ],
    );
  }

  Widget _buildLastPointageCard() {
    final pointage = controller.lastPointage.value;

    if (pointage == null || pointage['date_heure'] == null) {
      return _buildEmptyPointageCard();
    }

    final type = pointage['type'] == 'entrée' ? 'Entrée' : 'Sortie';
    final dateHeure = _formatDateTime(pointage['date_heure']);
    final isEntree = type == 'Entrée';

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              isEntree ? Colors.green.shade50 : Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isEntree ? Colors.green : Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isEntree ? Colors.green : Colors.red).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              isEntree ? Icons.login_rounded : Icons.logout_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            type,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isEntree ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
          subtitle: Text(
            dateHeure,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isEntree ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isEntree ? "ARRIVÉE" : "DÉPART",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isEntree ? Colors.green.shade800 : Colors.red.shade800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPointageCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.history_rounded, color: Colors.grey),
        ),
        title: const Text(
          "Aucun pointage",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Aucun pointage enregistré aujourd'hui",
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 3. BOUTONS D'ACTION PRINCIPAUX
  // ──────────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            "POINTER MAINTENANT",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                type: "entree",
                color: Colors.green,
                label: "Entrée",
                icon: Icons.login_rounded,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildActionButton(
                context: context,
                type: "sortie",
                color: Colors.red,
                label: "Sortie",
                icon: Icons.logout_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String type,
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: controller.isLoading.value
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ElevatedButton.icon(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.pointer(type),
          icon: Icon(icon, size: 28),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 4. CARTE GPS AMÉLIORÉE
  // ──────────────────────────────────────────────────────────────
  Widget _buildGpsCard() {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: controller.isInsideZone.value
                  ? [
                      Colors.green.shade50,
                      Colors.lightGreen.shade50,
                    ]
                  : [
                      Colors.orange.shade50,
                      Colors.red.shade50,
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: controller.isInsideZone.value
                  ? Colors.green.shade200
                  : Colors.red.shade200,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: controller.isInsideZone.value
                          ? Colors.green
                          : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (controller.isInsideZone.value
                                  ? Colors.green
                                  : Colors.red)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.isInsideZone.value
                          ? Icons.location_on_rounded
                          : Icons.location_off_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.isInsideZone.value
                              ? "Dans la zone autorisée"
                              : "Hors de la zone",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: controller.isInsideZone.value
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.isInsideZone.value
                              ? "Vous pouvez pointer normalement"
                              : "Rapprochez-vous du bureau pour pointer",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!controller.isInsideZone.value) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Colors.orange.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Le pointage n'est possible que dans la zone désignée",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ));
  }

  // ──────────────────────────────────────────────────────────────
  // 5. HISTORIQUE RÉCENT (SECTION OPTIONNELLE)
  // ──────────────────────────────────────────────────────────────
  Widget _buildRecentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Text(
                "HISTORIQUE RÉCENT",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigation vers l'historique complet
                  Get.snackbar(
                    "Historique",
                    "Fonctionnalité à venir",
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                },
                child: Text(
                  "VOIR TOUT",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(Get.context!).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildHistoryList(),
      ],
    );
  }

  Widget _buildHistoryList() {
    // Exemple de données d'historique - à remplacer par vos données réelles
    final recentHistory = [
      {'type': 'entrée', 'time': '08:30', 'date': 'Aujourd\'hui'},
      {'type': 'sortie', 'time': '12:00', 'date': 'Aujourd\'hui'},
      {'type': 'entrée', 'time': '13:30', 'date': 'Aujourd\'hui'},
    ];

    return Column(
      children: recentHistory.map((pointage) {
        final isEntree = pointage['type'] == 'entrée';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isEntree ? Colors.green.shade100 : Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEntree ? Icons.login_rounded : Icons.logout_rounded,
                color: isEntree ? Colors.green : Colors.red,
                size: 18,
              ),
            ),
            title: Text(
              isEntree ? "Entrée" : "Sortie",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isEntree ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
            subtitle: Text(
              "${pointage['date']} à ${pointage['time']}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Text(
              pointage['time']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        );
      }).toList(),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // DIALOG DE DÉCONNEXION (AMÉLIORÉ)
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Déconnexion",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Voulez-vous vraiment vous déconnecter ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Annuler"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Déconnexion"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() async {
    final box = GetStorage();
    await box.remove('token');

    if (Get.isRegistered<PointageController>()) {
      await Get.delete<PointageController>(force: true);
    }

    Get.offAllNamed('/login');

    Get.snackbar(
      "Déconnexion",
      "Vous êtes déconnecté avec succès",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // FONCTIONS UTILITAIRES
  // ──────────────────────────────────────────────────────────────
  String _formatDateTime(String dateHeure) {
    try {
      final dt = DateTime.parse(dateHeure).toLocal();
      final now = DateTime.now();

      String datePart;
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        datePart = "Aujourd'hui";
      } else {
        datePart = DateFormat('dd/MM/yyyy').format(dt);
      }

      final heurePart = DateFormat('HH:mm').format(dt);
      return "$datePart à $heurePart";
    } catch (e) {
      return "??:??";
    }
  }

  LinearGradient _getMessageGradient() {
    final color = _getMessageColor();
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, Color.lerp(color, Colors.black, 0.1)!],
    );
  }

  Color _getMessageColor() {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("hors zone") ||
        msg.contains("impossible") ||
        msg.contains("refus")) {
      return Colors.redAccent;
    }
    if (msg.contains("enregistré") || msg.contains("succès")) {
      return Colors.green;
    }
    if (msg.contains("position") || msg.contains("gps")) {
      return Colors.orange;
    }
    return Theme.of(Get.context!).colorScheme.primary;
  }

  IconData _getMessageIcon() {
    final msg = controller.message.value.toLowerCase();
    if (msg.contains("hors zone") || msg.contains("refus"))
      return Icons.location_off_rounded;
    if (msg.contains("enregistré")) return Icons.check_circle_rounded;
    if (msg.contains("position") || msg.contains("gps"))
      return Icons.location_searching_rounded;
    return Icons.info_outline_rounded;
  }
}