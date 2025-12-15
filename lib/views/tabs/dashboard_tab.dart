import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../order_form_view.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find<AppController>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Obx(() => Text(
                'Selamat Datang,\n${controller.userEmail.value}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              )),
          const SizedBox(height: 24),

          // Grid Menu
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildGridItem(
                  icon: Icons.add_circle_outline,
                  title: 'Buat Pesanan',
                  color: Colors.teal,
                  onTap: () => Get.to(() => const OrderFormView()),
                ),
                _buildGridItem(
                  icon: Icons.map_outlined,
                  title: 'Lokasi Laundry',
                  color: Colors.orange,
                  onTap: () {
                    // Logic to switch tab to Map handled in HomeView usually, 
                    // but if it's external view:
                     // For now, let's just use Get.to since MapView is separate or 
                     // change tab index if map was a tab. 
                     // Requirement says "Lokasi Laundry" grid item.
                     // Assuming we want to navigate to the separate Map View or similar.
                     // But wait, "Maps Logic" task implies a view.
                     // Let's check if we should navigate to MapsView.
                     // The user asked to Update lib/views/maps_view.dart.
                     // So we navigate there.
                     // However, the tab navigation is Home, Pesanan, Profil. 
                     // So Map is likely a separate screen or part of Home?
                     // Let's assume separate screen for "Lokasi Laundry" based on typical flow.
                     // Actually, in HomeView task: "BottomNavigationBar with 3 items: Home, Pesanan, Profil".
                     // So Map is not a tab.
                     Get.toNamed('/maps'); // Or direct navigation if route not set
                  },
                ),
                _buildGridItem(
                  icon: Icons.refresh,
                  title: 'Refresh Data',
                  color: Colors.blue,
                  onTap: () {
                    controller.fetchOrders();
                    controller.getCurrentLocation();
                    Get.snackbar('Success', 'Data Refreshed');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
