import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/app_controller.dart';

class MapsView extends StatelessWidget {
  const MapsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lokasi Laundry"),
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.currentLocation.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final userPos = LatLng(
              controller.currentLocation.value!.latitude,
              controller.currentLocation.value!.longitude,
            );

            return FlutterMap(
              options: MapOptions(
                initialCenter: userPos,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.routePoints.toList(),
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // User Marker
                    Marker(
                      point: userPos,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                    // Laundry Marker
                    Marker(
                      point: controller.laundryLocation,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            );
          }),

          // Bottom Info Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Lokasi Laundry: Mulyoagung",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                      "Jarak: ${controller.distanceToLaundry.value}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
