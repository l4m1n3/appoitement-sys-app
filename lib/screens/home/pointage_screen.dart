// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import '../../controllers/pointage_controller.dart';
// import '../../controllers/auth_controller.dart'; // Ajoute ça
// import 'package:intl/intl.dart';

// class PointageScreen extends StatelessWidget {
//   // final PointageController controller = Get.find<PointageController>();
//   //  final AuthController authController = Get.find<AuthController>(); // Pour logout

//   final PointageController controller = Get.find();

//   PointageScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pointage"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Colors.white,
//         actions: [
//           // Bouton Déconnexion
//           IconButton(
//             onPressed: () => _showLogoutDialog(context),
//             icon: const Icon(Icons.logout, size: 26),
//             tooltip: "Se déconnecter",
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: controller.fetchLastPointage,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               // 1. Message d'état
//               Obx(() => _buildStatusCard(context)),

//               const SizedBox(height: 20),

//               // 2. Dernier pointage
//               Obx(() => _buildLastPointage()),

//               const SizedBox(height: 32),

//               // 3. Boutons Entrée / Sortie
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildActionButton(
//                       context: context,
//                       type: "entree",
//                       color: Colors.green,
//                       label: "Entrée",
//                       icon: Icons.login,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: _buildActionButton(
//                       context: context,
//                       type: "sortie",
//                       color: Colors.red,
//                       label: "Sortie",
//                       icon: Icons.logout,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 40),

//               // 4. Zone GPS
//               Obx(() => _buildGpsZoneInfo()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // DIALOG DE DÉCONNEXION
//   // ──────────────────────────────────────────────────────────────
//   void _showLogoutDialog(BuildContext context) {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Row(
//           children: [
//             Icon(Icons.help_outline, color: Colors.orange),
//             SizedBox(width: 10),
//             Text("Déconnexion"),
//           ],
//         ),
//         content: const Text("Voulez-vous vraiment vous déconnecter ?"),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             onPressed: () {
//               Get.back(); // Ferme le dialog
//               _logout();
//             },
//             child: const Text("Déconnexion"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _logout() async {
//     final box = GetStorage();

//     // 1️⃣ Supprime le token d’authentification
//     await box.remove('token');

//     // 2️⃣ Supprime uniquement le contrôleur de pointage
//     // (AuthController sera réinitialisé automatiquement sur la page de login)
//     if (Get.isRegistered<PointageController>()) {
//       await Get.delete<PointageController>(force: true);
//     }

//     // 3️⃣ Redirige vers la page de login
//     Get.offAllNamed('/login');

//     // 4️⃣ Message de confirmation
//     Get.snackbar(
//       "Déconnexion",
//       "Vous êtes déconnecté avec succès",
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//       icon: const Icon(Icons.check_circle),
//       duration: const Duration(seconds: 2),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 1. Carte d'état
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildStatusCard(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _getMessageColor(),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(_getMessageIcon(), color: Colors.white, size: 28),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               controller.message.value.isNotEmpty
//                   ? controller.message.value
//                   : "Prêt à pointer",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           if (controller.isLoading.value)
//             const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2.5,
//                 valueColor: AlwaysStoppedAnimation(Colors.white),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 2. Dernier pointage
//   // ──────────────────────────────────────────────────────────────

//   Widget _buildLastPointage() {
//     final pointage = controller.lastPointage.value;

//     if (pointage == null || pointage['date_heure'] == null) {
//       return _emptyCard();
//     }

//     final type = pointage['type'] == 'entrée' ? 'Entrée' : 'Sortie';
//     final dateHeure = _formatDateTime(pointage['date_heure']);

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: type == 'Entrée' ? Colors.green : Colors.red,
//           child: Icon(
//             type == 'Entrée' ? Icons.login : Icons.logout,
//             color: Colors.white,
//           ),
//         ),
//         title: Text(
//           "Dernier : $type",
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           "à $dateHeure",
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//         trailing: const Icon(Icons.access_time, color: Colors.grey),
//       ),
//     );
//   }

//   /// Formate la date / heure en JJ/MM/YYYY HH:mm ou "Aujourd’hui HH:mm" si c’est le jour même
//   String _formatDateTime(String dateHeure) {
//     try {
//       final dt = DateTime.parse(
//         dateHeure,
//       ).toLocal(); // conversion en heure locale
//       final now = DateTime.now();

//       String datePart;
//       if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
//         datePart = "Aujourd'hui";
//       } else {
//         datePart = DateFormat('dd/MM/yyyy').format(dt);
//       }

//       final heurePart = DateFormat('HH:mm').format(dt);

//       return "$datePart $heurePart";
//     } catch (e) {
//       print("Erreur format date: $e");
//       return "??:??";
//     }
//   }

//   Widget _emptyCard() {
//     final now = DateTime.now();
//     final dateStr = DateFormat('dd/MM/yyyy').format(now);
//     final heureStr = DateFormat('HH:mm').format(now);

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ListTile(
//         leading: const Icon(Icons.history, color: Colors.grey),
//         title: const Text(
//           "Aucun pointage",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           "Aucun pointage pour aujourd'hui ($dateStr $heureStr)",
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontStyle: FontStyle.italic,
//           ),
//         ),
//         trailing: const Icon(Icons.access_time, color: Colors.grey),
//       ),
//     );
//   }

//   String _formatHeure(String dateHeure) {
//     try {
//       return dateHeure.split(' ')[1].substring(0, 5);
//     } catch (e) {
//       return "??:??";
//     }
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 3. Bouton d'action
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildActionButton({
//     required BuildContext context,
//     required String type,
//     required Color color,
//     required String label,
//     required IconData icon,
//   }) {
//     return Obx(
//       () => ElevatedButton.icon(
//         onPressed: controller.isLoading.value
//             ? null
//             : () => controller.pointer(type),
//         icon: Icon(icon, size: 32),
//         label: Text(
//           label,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 8,
//           shadowColor: color.withOpacity(0.4),
//         ),
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 4. Zone GPS
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildGpsZoneInfo() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade300, width: 1.5),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 child: Icon(
//                   controller.isInsideZone.value
//                       ? Icons.location_on
//                       : Icons.location_off,
//                   key: ValueKey(controller.isInsideZone.value),
//                   color: controller.isInsideZone.value
//                       ? Colors.green
//                       : Colors.red,
//                   size: 36,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 controller.isInsideZone.value
//                     ? "Dans la zone autorisée"
//                     : "Hors zone",
//                 style: TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                   color: controller.isInsideZone.value
//                       ? Colors.green
//                       : Colors.red,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             controller.isInsideZone.value
//                 ? "Vous pouvez pointer"
//                 : "Rapprochez-vous du bureau",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[700],
//               fontStyle: FontStyle.italic,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 5. Couleurs & icônes
//   // ──────────────────────────────────────────────────────────────
//   Color _getMessageColor() {
//     final msg = controller.message.value.toLowerCase();
//     if (msg.contains("hors zone") ||
//         msg.contains("impossible") ||
//         msg.contains("refus")) {
//       return Colors.redAccent;
//     }
//     if (msg.contains("enregistré") || msg.contains("succès")) {
//       return Colors.green;
//     }
//     if (msg.contains("position") || msg.contains("gps")) {
//       return Colors.orange;
//     }
//     return Get.theme.colorScheme.primary;
//   }

//   IconData _getMessageIcon() {
//     final msg = controller.message.value.toLowerCase();
//     if (msg.contains("hors zone") || msg.contains("refus"))
//       return Icons.location_off;
//     if (msg.contains("enregistré")) return Icons.check_circle;
//     if (msg.contains("position") || msg.contains("gps"))
//       return Icons.location_searching;
//     return Icons.info;
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import '../../controllers/pointage_controller.dart';
// import '../../controllers/auth_controller.dart';
// import 'package:intl/intl.dart';

// class PointageScreen extends StatelessWidget {
//   final PointageController controller = Get.find();
//   final AuthController authController = Get.find();

//   // Couleurs pastel de l'armoirie du Niger
//   static const Color nigerOrangePastel = Color(
//     0xFFFFB380,
//   ); // Orange pastel très clair
//   static const Color nigerGreenPastel = Color(
//     0xFF99E6A1,
//   ); // Vert pastel très clair
//   static const Color nigerWhite = Color(0xFFFFFFFF); // Blanc
//   static const Color nigerSunPastel = Color(0xFFFFE0B2); // Soleil pastel
//   static const Color nigerOrangeSoft = Color(0xFFFFA366); // Orange doux
//   static const Color nigerGreenSoft = Color(0xFF80D180); // Vert doux

//   // Couleurs de texte
//   static const Color textPrimary = Color(0xFF374151);
//   static const Color textSecondary = Color(0xFF6B7280);
//   static const Color backgroundPastel = Color(
//     0xFFFDF8F5,
//   ); // Fond très clair orangé

//   PointageScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundPastel,
//       appBar: AppBar(
//         title: const Text(
//           "Pointage GPS",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: nigerOrangeSoft,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             onPressed: () => _showLogoutDialog(context),
//             icon: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.logout, size: 20),
//             ),
//             tooltip: "Se déconnecter",
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: controller.fetchLastPointage,
//         backgroundColor: nigerWhite,
//         color: nigerOrangeSoft,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               // 1. Message d'état avec couleurs Niger
//               Obx(() => _buildStatusCard(context)),

//               const SizedBox(height: 24),

//               // 2. Dernier pointage
//               Obx(() => _buildLastPointage()),

//               const SizedBox(height: 32),

//               // 3. Boutons Entrée / Sortie
//               _buildActionButtons(),

//               const SizedBox(height: 40),

//               // 4. Zone GPS
//               Obx(() => _buildGpsZoneInfo()),

//               // 5. Bandeau patriotique
//               _buildNationalBanner(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // DIALOG DE DÉCONNEXION
//   // ──────────────────────────────────────────────────────────────
//   void _showLogoutDialog(BuildContext context) {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: nigerWhite,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Icône
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: nigerOrangePastel.withOpacity(0.3),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.logout, color: nigerOrangeSoft, size: 30),
//               ),
//               const SizedBox(height: 16),

//               // Titre
//               Text(
//                 "Déconnexion",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // Message
//               Text(
//                 "Voulez-vous vraiment vous déconnecter ?",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 14, color: textSecondary),
//               ),
//               const SizedBox(height: 24),

//               // Boutons
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: textSecondary,
//                         side: BorderSide(
//                           color: nigerOrangePastel.withOpacity(0.5),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text("Annuler"),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Get.back();
//                         _logout();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: nigerOrangeSoft,
//                         foregroundColor: nigerWhite,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Text("Déconnexion"),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _logout() async {
//     final box = GetStorage();
//     await box.remove('token');

//     if (Get.isRegistered<PointageController>()) {
//       await Get.delete<PointageController>(force: true);
//     }

//     Get.offAllNamed('/login');

//     Get.snackbar(
//       "Déconnexion",
//       "Vous êtes déconnecté avec succès",
//       backgroundColor: nigerGreenSoft,
//       colorText: nigerWhite,
//       icon: const Icon(Icons.check_circle, color: Colors.white),
//       borderRadius: 12,
//       margin: const EdgeInsets.all(16),
//       duration: const Duration(seconds: 2),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 1. CARTE D'ÉTAT
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildStatusCard(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 400),
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: _getMessageGradient(),
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: _getMessageColor().withOpacity(0.15),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Icône
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: nigerWhite.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(_getMessageIcon(), color: nigerWhite, size: 22),
//           ),
//           const SizedBox(width: 16),

//           // Message
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   controller.message.value.isNotEmpty
//                       ? controller.message.value
//                       : "Prêt à pointer",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                     height: 1.3,
//                   ),
//                 ),
//                 if (controller.message.value.isNotEmpty)
//                   const SizedBox(height: 4),
//                 if (controller.message.value.isNotEmpty)
//                   Text(
//                     _getMessageSubtitle(),
//                     style: TextStyle(
//                       color: nigerWhite.withOpacity(0.9),
//                       fontSize: 12,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // Indicateur de chargement
//           if (controller.isLoading.value)
//             Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: nigerWhite.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: const SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation(Colors.white),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 2. DERNIER POINTAGE
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildLastPointage() {
//     final pointage = controller.lastPointage.value;

//     if (pointage == null || pointage['date_heure'] == null) {
//       return _emptyCard();
//     }

//     final type = pointage['type'] == 'entrée' ? 'Entrée' : 'Sortie';
//     final dateHeure = _formatDateTime(pointage['date_heure']);
//     final isEntree = type == 'Entrée';

//     return Container(
//       decoration: BoxDecoration(
//         color: nigerWhite,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: nigerOrangePastel.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//         border: Border.all(color: nigerOrangePastel.withOpacity(0.3), width: 1),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(20),
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: isEntree
//                 ? nigerGreenPastel.withOpacity(0.3)
//                 : nigerOrangePastel.withOpacity(0.3),
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: isEntree ? nigerGreenSoft : nigerOrangeSoft,
//               width: 2,
//             ),
//           ),
//           child: Icon(
//             isEntree ? Icons.login_rounded : Icons.logout_rounded,
//             color: isEntree ? nigerGreenSoft : nigerOrangeSoft,
//             size: 24,
//           ),
//         ),
//         title: Text(
//           "Dernier pointage",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: textPrimary,
//             fontSize: 16,
//           ),
//         ),
//         subtitle: Text(
//           dateHeure,
//           style: TextStyle(color: textSecondary, fontSize: 14),
//         ),
//         trailing: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: isEntree
//                 ? nigerGreenPastel.withOpacity(0.2)
//                 : nigerOrangePastel.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isEntree ? nigerGreenSoft : nigerOrangeSoft,
//               width: 1,
//             ),
//           ),
//           child: Text(
//             type,
//             style: TextStyle(
//               color: isEntree ? nigerGreenSoft : nigerOrangeSoft,
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _emptyCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: nigerWhite,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: nigerOrangePastel.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//         border: Border.all(color: nigerOrangePastel.withOpacity(0.2), width: 1),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(20),
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: nigerOrangePastel.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(Icons.history_rounded, color: nigerOrangeSoft, size: 24),
//         ),
//         title: Text(
//           "Aucun pointage",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: textPrimary,
//             fontSize: 16,
//           ),
//         ),
//         subtitle: Text(
//           "Aucun pointage enregistré aujourd'hui",
//           style: TextStyle(color: textSecondary, fontSize: 14),
//         ),
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 3. BOUTONS D'ACTION
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildActionButtons() {
//     return Obx(
//       () => Row(
//         children: [
//           Expanded(
//             child: _buildActionButton(
//               type: "entree",
//               label: "Entrée",
//               icon: Icons.login_rounded,
//               color: nigerGreenSoft,
//               pastelColor: nigerGreenPastel,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: _buildActionButton(
//               type: "sortie",
//               label: "Sortie",
//               icon: Icons.logout_rounded,
//               color: nigerOrangeSoft,
//               pastelColor: nigerOrangePastel,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required String type,
//     required String label,
//     required IconData icon,
//     required Color color,
//     required Color pastelColor,
//   }) {
//     return ElevatedButton(
//       onPressed: controller.isLoading.value
//           ? null
//           : () => controller.pointer(type),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: pastelColor.withOpacity(0.3),
//         foregroundColor: color,
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         elevation: 0,
//         shadowColor: Colors.transparent,
//         side: BorderSide(color: color.withOpacity(0.3), width: 2),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 32, color: color),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 4. ZONE GPS
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildGpsZoneInfo() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: nigerWhite,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: nigerOrangePastel.withOpacity(0.1),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//         border: Border.all(
//           color: nigerOrangePastel.withOpacity(0.3),
//           width: 1.5,
//         ),
//       ),
//       child: Column(
//         children: [
//           // Statut de la zone
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 400),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: controller.isInsideZone.value
//                       ? nigerGreenPastel.withOpacity(0.2)
//                       : nigerOrangePastel.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: controller.isInsideZone.value
//                         ? nigerGreenSoft
//                         : nigerOrangeSoft,
//                     width: 2,
//                   ),
//                 ),
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 400),
//                   child: Icon(
//                     controller.isInsideZone.value
//                         ? Icons.location_on_rounded
//                         : Icons.location_off_rounded,
//                     key: ValueKey(controller.isInsideZone.value),
//                     color: controller.isInsideZone.value
//                         ? nigerGreenSoft
//                         : nigerOrangeSoft,
//                     size: 28,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       controller.isInsideZone.value
//                           ? "Dans la zone autorisée"
//                           : "Hors zone",
//                       style: TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                         color: controller.isInsideZone.value
//                             ? nigerGreenSoft
//                             : nigerOrangeSoft,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       controller.isInsideZone.value
//                           ? "Vous pouvez pointer"
//                           : "Rapprochez-vous du bureau",
//                       style: TextStyle(fontSize: 14, color: textSecondary),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // 5. BANDEAU PATRIOTIQUE
//   // ──────────────────────────────────────────────────────────────
//   Widget _buildNationalBanner() {
//     return Container(
//       margin: const EdgeInsets.only(top: 30),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: nigerWhite,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: nigerOrangePastel.withOpacity(0.3), width: 1),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Dégradé des couleurs nationales
//           Container(
//             width: 80,
//             height: 6,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [nigerOrangeSoft, nigerWhite, nigerGreenSoft],
//                 stops: const [0.33, 0.66, 1.0],
//               ),
//               borderRadius: BorderRadius.circular(3),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Icon(Icons.flag_rounded, color: nigerOrangeSoft, size: 16),
//           const SizedBox(width: 8),
//           Text(
//             "République du Niger",
//             style: TextStyle(
//               color: textSecondary,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ──────────────────────────────────────────────────────────────
//   // MÉTHODES D'AIDE - COULEURS ET ICÔNES
//   // ──────────────────────────────────────────────────────────────
//   List<Color> _getMessageGradient() {
//     final msg = controller.message.value.toLowerCase();
//     if (msg.contains("hors zone") ||
//         msg.contains("impossible") ||
//         msg.contains("refus")) {
//       return [
//         nigerOrangePastel.withOpacity(0.8),
//         nigerOrangeSoft.withOpacity(0.6),
//       ];
//     }
//     if (msg.contains("enregistré") || msg.contains("succès")) {
//       return [
//         nigerGreenPastel.withOpacity(0.8),
//         nigerGreenSoft.withOpacity(0.6),
//       ];
//     }
//     if (msg.contains("position") || msg.contains("gps")) {
//       return [
//         nigerSunPastel.withOpacity(0.8),
//         nigerOrangeSoft.withOpacity(0.6),
//       ];
//     }
//     return [
//       nigerOrangePastel.withOpacity(0.6),
//       nigerOrangeSoft.withOpacity(0.4),
//     ];
//   }

//   Color _getMessageColor() {
//     final msg = controller.message.value.toLowerCase();
//     if (msg.contains("hors zone") ||
//         msg.contains("impossible") ||
//         msg.contains("refus")) {
//       return nigerOrangeSoft;
//     }
//     if (msg.contains("enregistré") || msg.contains("succès")) {
//       return nigerGreenSoft;
//     }
//     if (msg.contains("position") || msg.contains("gps")) {
//       return nigerOrangeSoft;
//     }
//     return nigerOrangeSoft;
//   }

//   IconData _getMessageIcon() {
//     final msg = controller.message.value.toLowerCase();
//     if (msg.contains("hors zone") || msg.contains("refus"))
//       return Icons.location_off_rounded;
//     if (msg.contains("enregistré")) return Icons.check_circle_rounded;
//     if (msg.contains("position") || msg.contains("gps"))
//       return Icons.location_searching_rounded;
//     return Icons.info_outline_rounded;
//   }

//   String _getMessageSubtitle() {
//     final msg = controller.message.value.toLowerCase();
//     if (msg.contains("hors zone"))
//       return "Rapprochez-vous de votre lieu de travail";
//     if (msg.contains("enregistré")) return "Pointage enregistré avec succès";
//     if (msg.contains("position")) return "Recherche de votre position...";
//     return "Système de pointage GPS Niger";
//   }

//   String _formatDateTime(String dateHeure) {
//     try {
//       final dt = DateTime.parse(dateHeure).toLocal();
//       final now = DateTime.now();

//       String datePart;
//       if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
//         datePart = "Aujourd'hui";
//       } else {
//         datePart = DateFormat('dd/MM/yyyy').format(dt);
//       }

//       final heurePart = DateFormat('HH:mm').format(dt);
//       return "$datePart à $heurePart";
//     } catch (e) {
//       return "Heure inconnue";
//     }
//   }
// }
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