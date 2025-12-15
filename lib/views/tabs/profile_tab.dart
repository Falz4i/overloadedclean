import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find<AppController>();
    final AuthController authController = Get.find<AuthController>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal[100],
              child: const Icon(Icons.person, size: 60, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            
            // Email
            Obx(() => Text(
              controller.userEmail.value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )),
            const SizedBox(height: 8),

            // Role Badge
            Obx(() {
              final isUserAdmin = controller.userRole.value == 'Admin';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isUserAdmin ? Colors.red[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUserAdmin ? Colors.red : Colors.blue,
                  ),
                ),
                child: Text(
                  controller.userRole.value,
                  style: TextStyle(
                    color: isUserAdmin ? Colors.red[900] : Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
            const SizedBox(height: 48),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  authController.signOut();
                },
              ),
            ),
            
            const SizedBox(height: 16),
             // Toggle Theme
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Get.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
                label: Text(Get.isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode"),
                onPressed: () {
                   controller.toggleTheme();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
