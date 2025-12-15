import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';

class MapView extends StatelessWidget {
  MapView({Key? key}) : super(key: key);

  final AppController controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Location')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.locationError.isNotEmpty) {
          return Center(
            child: Text('Error: ${controller.locationError.value}'),
          );
        }

        final position = controller.currentLocation.value;
        if (position == null) {
          return const Center(child: Text('Location not available'));
        }

        final userLocation = LatLng(position.latitude, position.longitude);

        return FlutterMap(
          options: MapOptions(
            initialCenter: userLocation,
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.overloadedclean',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: userLocation,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
