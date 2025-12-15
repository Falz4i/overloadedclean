import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import 'map_view.dart';
import 'order_form_view.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

  final AppController controller = Get.find<AppController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OverloadedClean'),
        actions: [
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            tooltip: "Toggle Theme",
            onPressed: () {
               controller.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.token),
            tooltip: "Get FCM Token",
            onPressed: () async {
               try {
                 String? token = await FirebaseMessaging.instance.getToken();
                 print('=== FCM TOKEN ===');
                 print(token);
                 print('=================');
                 if (token != null) {
                   await Clipboard.setData(ClipboardData(text: token));
                   Get.snackbar('Success', 'Token Copied to Clipboard!');
                 }
               } catch (e) {
                 print('Error getting token: $e');
                 Get.snackbar('Error', 'Failed to get token');
               }
            },
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              controller.getCurrentLocation();
              Get.to(() => MapView());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modul 1 & 2: Promo Banner with Animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Container(
                      height: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                           colors: Get.isDarkMode 
                             ? [Colors.tealAccent[700]!, Colors.teal[900]!]
                             : [Colors.tealAccent, Colors.teal],
                           begin: Alignment.topLeft,
                           end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.2),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           )
                        ]
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '50% OFF - Use Code: CLEAN50',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              
              // Last Ordered Service (Local Storage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Obx(() => Text(
                  'Last Ordered (Local): ${controller.lastOrderedService.value}',
                  style: TextStyle(
                      fontSize: 16, 
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).textTheme.bodySmall?.color
                  ),
                )),
              ),
              
              const SizedBox(height: 16),
              const Divider(thickness: 1, indent: 16, endIndent: 16),

              // --- Realtime Orders List (Supabase) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'My Orders',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              
              Obx(() {
                if (controller.isOrdersLoading.value) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (controller.orders.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No orders found. Add one!"),
                  ));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    final status = order['status'] ?? 'Pending';
                    Color statusColor;
                    if (status == 'Selesai') {
                      statusColor = Colors.green;
                    } else if (status == 'Sedang Dicuci') {
                       statusColor = Colors.orange;
                    } else {
                       statusColor = Colors.grey;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${order['service_name']} - ${order['shoe_brand']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Customer: ${order['customer_name'] ?? 'N/A'}'),
                                  Text('Notes: ${order['notes'] ?? '-'}'),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text("Edit"),
                                  onPressed: () {
                                    Get.to(() => OrderFormView(existingOrder: order));
                                  },
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                  label: const Text("Delete", style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Get.defaultDialog(
                                      title: "Delete Order",
                                      middleText: "Are you sure you want to delete this order?",
                                      textCancel: "Cancel",
                                      textConfirm: "Delete",
                                      confirmTextColor: Colors.white,
                                      buttonColor: Colors.red,
                                      onConfirm: () {
                                        controller.deleteOrder(order['id']);
                                        Get.back();
                                      }
                                    );
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           Get.to(() => const OrderFormView());
        },
        icon: const Icon(Icons.add),
        label: const Text("New Order"),
      ),
    );
  }
}
