import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final _supabase = Supabase.instance.client;
  RxBool isLoading = false.obs;
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      
      if (data.event == AuthChangeEvent.signedIn) {
         Get.offAllNamed('/home');
      } else if (data.event == AuthChangeEvent.signedOut) {
         Get.offAllNamed('/login');
      }
    });
    
    // Initial check
    currentUser.value = _supabase.auth.currentUser;
  }

  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      await _supabase.auth.signUp(email: email, password: password);
      Get.snackbar('Success', 'Account created! Please login.', 
        backgroundColor: Colors.green, colorText: Colors.white);
      Get.offNamed('/login');
    } on AuthException catch (e) {
      Get.snackbar('Error', e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      await _supabase.auth.signInWithPassword(email: email, password: password);
      // Navigation is handled by the auth state listener
    } on AuthException catch (e) {
      Get.snackbar('Error', e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
