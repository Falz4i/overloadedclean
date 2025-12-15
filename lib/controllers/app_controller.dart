import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../views/widgets/success_dialog.dart';

class AppController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // Observables
  var laundryServices = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isOrdersLoading = false.obs;
  var lastOrderedService = ''.obs;
  var currentLocation = Rxn<Position>();
  var locationError = ''.obs;
  var orders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
    loadLastOrderedService();
    // Only fetch orders if user is already logged in
    if (_supabase.auth.currentUser != null) {
      fetchOrders();
    }
  }
  
  // Toggle Theme
  void toggleTheme() {
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
    }
  }

  // --- Services & Location (Existing) ---
  
  Future<void> fetchServices() async {
    // Standardized Service Menu with Prices
    laundryServices.assignAll([
      {'name': 'Deep Clean', 'price': 40000},
      {'name': 'Fast Clean', 'price': 25000},
      {'name': 'Repaint', 'price': 85000},
      {'name': 'Reglue', 'price': 35000},
    ]);
  }

  Future<void> loadLastOrderedService() async {
    final prefs = await SharedPreferences.getInstance();
    lastOrderedService.value = prefs.getString('last_order') ?? 'No orders yet';
  }

  Future<void> saveLastOrderedService(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_order', serviceName);
    lastOrderedService.value = serviceName;
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading(true);
      final position = await LocationService.to.getCurrentLocation();
      currentLocation.value = position;
      locationError.value = '';
    } catch (e) {
      locationError.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  // --- CRUD Operations (Updated) ---

  Future<void> fetchOrders() async {
    try {
      isOrdersLoading(true);
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('id', ascending: false);
          
      orders.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching orders: $e');
      Get.snackbar('Error', 'Failed to fetch orders');
    } finally {
      isOrdersLoading(false);
    }
  }

  // Updated: Accept customerName
  Future<void> addOrder(String customerName, String service, String brand, String notes, double price) async {
    try {
      isLoading(true);
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar('Error', 'You must be logged in');
        return;
      }

      await _supabase.from('orders').insert({
        'user_id': userId,
        'customer_name': customerName,
        'service_name': service,
        'shoe_brand': brand,
        'notes': notes,
        'price': price,
        'status': 'Pending'
      });
      
      await fetchOrders(); // Refresh list
      
      // Success Animation Logic
      Get.dialog(const SuccessDialog());
      await Future.delayed(const Duration(seconds: 2));
      Get.back(); // Close dialog
      Get.back(); // Close form
      
    } catch (e) {
      print('Error adding order: $e');
      Get.snackbar('Error', 'Failed to add order');
    } finally {
      isLoading(false);
    }
  }

  // Updated: Accept customerName
  Future<void> updateOrder(int id, String customerName, String brand, String notes, String service, String status) async {
    try {
      isLoading(true);
      await _supabase.from('orders').update({
        'customer_name': customerName,
        'shoe_brand': brand,
        'notes': notes,
        'service_name': service,
        'status': status,
      }).eq('id', id);

      await fetchOrders();

      // Notification Logic for "Selesai" status
      if (status == 'Selesai') {
        NotificationService.to.showNotification(
          title: "Sepatu Kamu Sudah Kinclong! ✨",
          body: "Halo $customerName, sepatu $brand kamu sudah selesai dicuci. Silahkan diambil!"
        );
      }

      // Success Animation Logic
      Get.dialog(const SuccessDialog());
      await Future.delayed(const Duration(seconds: 2));
      Get.back(); // Close dialog
      Get.back(); // Close form

    } catch (e) {
      print('Error updating order: $e');
      Get.snackbar('Error', 'Failed to update order');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      isLoading(true);
      await _supabase.from('orders').delete().eq('id', id);
      
      // Update local list instantly for better UX
      orders.removeWhere((order) => order['id'] == id);
      Get.snackbar('Success', 'Order deleted');
    } catch (e) {
      print('Error deleting order: $e');
      Get.snackbar('Error', 'Failed to delete order');
    } finally {
      isLoading(false);
    }
  }
}
