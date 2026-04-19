import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ============================================================
// MODEL
// ============================================================

// Status koneksi perangkat
enum DeviceStatus { online, offline, idle }

// Model data perangkat GPS
class Device {
  String id;
  String name;
  DeviceStatus status;
  double latitude;
  double longitude;
  String lastUpdated;

  Device({
    required this.id,
    required this.name,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });
}

// ============================================================
// DATA
// ============================================================

// Satu perangkat yang akan di-tracking
Device trackedDevice = Device(
  id: 'dev-001',
  name: 'Kacamata VoxSight',
  status: DeviceStatus.online,
  latitude: -7.310887753118097,
  longitude: 112.72894337595493,
  lastUpdated: '15 Jan 2024, 08:30',
);

// ============================================================
// HELPER FUNCTIONS
// ============================================================

// Mengembalikan teks status perangkat
String getStatusText(DeviceStatus status) {
  if (status == DeviceStatus.online) return 'Online';
  if (status == DeviceStatus.offline) return 'Offline';
  return 'Idle';
}

// Mengembalikan warna sesuai status perangkat
Color getStatusColor(DeviceStatus status) {
  if (status == DeviceStatus.online) return Colors.green;
  if (status == DeviceStatus.offline) return Colors.grey;
  return Colors.amber;
}

// ============================================================
// MAIN
// ============================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    title: 'Device Tracking',
    home: TrackingScreen(),
  ));
}

// ============================================================
// TRACKING SCREEN
// ============================================================

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? mapController;
  final random = Random();

  // Simulasi update posisi GPS secara acak (±100 meter)
  void simulateMovement() {
    setState(() {
      trackedDevice.latitude += (random.nextDouble() - 0.5) * 0.002;
      trackedDevice.longitude += (random.nextDouble() - 0.5) * 0.002;
      trackedDevice.lastUpdated = 'Baru saja diperbarui';
    });

    // Gerakkan kamera ke posisi baru
    mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(trackedDevice.latitude, trackedDevice.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Tracker Location'),
        backgroundColor: const Color(0xFF2F486D),
        foregroundColor: const Color(0xFFF3EAE0),
        actions: [
          // Tombol untuk simulasi pergerakan posisi
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Simulasi Pergerakan',
            onPressed: simulateMovement,
          ),
        ],
      ),
      body: Column(
        children: [
          // Google Maps — mengisi sebagian besar layar
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(trackedDevice.latitude, trackedDevice.longitude),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(trackedDevice.id),
                  position: LatLng(trackedDevice.latitude, trackedDevice.longitude),
                  infoWindow: InfoWindow(title: trackedDevice.name),
                ),
              },
              onMapCreated: (controller) {
                mapController = controller;
              },
            ),
          ),

          // Info panel perangkat
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2F486D),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama perangkat
                Text(
                  trackedDevice.name,
                  style: const TextStyle(
                    color: Color(0xFFF3EAE0),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Status koneksi
                Text(
                  getStatusText(trackedDevice.status),
                  style: TextStyle(
                    color: getStatusColor(trackedDevice.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Koordinat GPS
                Text(
                  'Lat: ${trackedDevice.latitude.toStringAsFixed(6)}, '
                  'Lng: ${trackedDevice.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(color: Color(0xFFF3EAE0), fontSize: 12),
                ),
                const SizedBox(height: 4),

                // Waktu update terakhir
                Text(
                  trackedDevice.lastUpdated,
                  style: const TextStyle(color: Color(0xCCF3EAE0), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
