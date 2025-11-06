// // screens/auth/login_screen.dart
// import 'package:appointement_app/controllers/auth_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class LoginScreen extends StatelessWidget {
//   final AuthController controller = Get.find<AuthController>();
//   final _formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text("Connexion"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Theme.of(context).colorScheme.primary,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 40),

//                 // Logo ou icône
//                 Icon(
//                   Icons.fingerprint,
//                   size: 100,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(height: 20),

//                 const Text(
//                   "Pointage GPS",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Connectez-vous pour pointer",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),

//                 const SizedBox(height: 50),

//                 // Email
//                 TextFormField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   textInputAction: TextInputAction.next,
//                   decoration: InputDecoration(
//                     labelText: "Email",
//                     prefixIcon: const Icon(Icons.email_outlined),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "L'email est requis";
//                     }
//                     if (!GetUtils.isEmail(value)) {
//                       return "Email invalide";
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 // Mot de passe
//                 Obx(() => TextFormField(
//                   controller: passwordController,
//                   obscureText: !controller.showPassword.value,
//                   decoration: InputDecoration(
//                     labelText: "Mot de passe",
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         controller.showPassword.value
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                       ),
//                       onPressed: controller.togglePassword,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Le mot de passe est requis";
//                     }
//                     if (value.length < 6) {
//                       return "6 caractères minimum";
//                     }
//                     return null;
//                   },
//                 )),

//                 const SizedBox(height: 10),

//                 // Mot de passe oublié
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       Get.snackbar(
//                         "Info",
//                         "Contactez votre administrateur",
//                         backgroundColor: Colors.blue,
//                         colorText: Colors.white,
//                       );
//                     },
//                     child: const Text("Mot de passe oublié ?"),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Bouton Connexion
//                 Obx(() => SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: controller.isLoading.value
//                         ? null
//                         : () {
//                             if (_formKey.currentState!.validate()) {
//                               controller.login(
//                                 emailController.text.trim(),
//                                 passwordController.text,
//                               );
//                             }
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).colorScheme.primary,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 6,
//                     ),
//                     child: controller.isLoading.value
//                         ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2.5,
//                             ),
//                           )
//                         : const Text(
//                             "Se connecter",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 )),

//                 const SizedBox(height: 20),

//                 // Message d'erreur
//                 Obx(() => AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.symmetric(horizontal: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     border: Border.all(color: Colors.red.shade200),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     controller.errorMessage.value,
//                     style: TextStyle(color: Colors.red.shade700),
//                     textAlign: TextAlign.center,
//                   ),
//                   height: controller.errorMessage.value.isNotEmpty ? null : 0,
//                   onEnd: () {
//                     if (controller.errorMessage.value.isEmpty) {
//                       // Cache le message
//                     }
//                   },
//                 )),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// screens/auth/login_screen.dart
import 'package:appointement_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header avec gradient
            SliverToBoxAdapter(
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      isDarkMode ? Colors.grey[900]! : Colors.grey[50]!,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animé
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fingerprint,
                        size: 50,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Titre principal
                    Text(
                      "Pointage GPS",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Sous-titre
                    Text(
                      "Connectez-vous pour commencer",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Formulaire
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Carte du formulaire
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Champ Email
                            _buildEmailField(context),
                            const SizedBox(height: 20),
                            
                            // Champ Mot de passe
                            _buildPasswordField(context),
                            const SizedBox(height: 16),
                            
                            // Mot de passe oublié
                            _buildForgotPassword(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Bouton de connexion
                      _buildLoginButton(context),
                      
                      const SizedBox(height: 24),
                      
                      // Message d'erreur
                      _buildErrorMessage(),
                      
                      // Indicateur de sécurité
                      const SizedBox(height: 40),
                      _buildSecurityInfo(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "votre@email.com",
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              child: Icon(
                Icons.email_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "L'email est requis";
            }
            if (!GetUtils.isEmail(value)) {
              return "Format d'email invalide";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mot de passe",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => TextFormField(
          controller: passwordController,
          obscureText: !controller.showPassword.value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "••••••",
            hintStyle: const TextStyle(
              letterSpacing: 4,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              child: Icon(
                Icons.lock_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.showPassword.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              onPressed: controller.togglePassword,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Le mot de passe est requis";
            }
            if (value.length < 6) {
              return "6 caractères minimum requis";
            }
            return null;
          },
        )),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Get.snackbar(
            "Assistance requise",
            "Contactez votre administrateur pour réinitialiser votre mot de passe",
            backgroundColor: Theme.of(Get.context!).colorScheme.primary,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          "Mot de passe oublié ?",
          style: TextStyle(
            color: Theme.of(Get.context!).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: controller.isLoading.value
              ? null
              : LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: controller.isLoading.value
              ? []
              : [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
                  // Fermer le clavier
                  FocusScope.of(context).unfocus();
                  if (_formKey.currentState!.validate()) {
                    controller.login(
                      emailController.text.trim(),
                      passwordController.text,
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: controller.isLoading.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Connexion...",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Se connecter",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    ));
  }

  Widget _buildErrorMessage() {
    return Obx(() => AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: controller.errorMessage.value.isNotEmpty
          ? Container(
              key: ValueKey(controller.errorMessage.value),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.red.shade600,
                      size: 16,
                    ),
                    onPressed: () {
                      controller.errorMessage.value = '';
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    ));
  }

  Widget _buildSecurityInfo() {
    final isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;
    
    return Column(
      children: [
        Icon(
          Icons.security_rounded,
          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          "Connexion sécurisée",
          style: TextStyle(
            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}