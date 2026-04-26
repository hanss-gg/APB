import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ============================================================
// MODEL
// ============================================================

enum DeviceStatus { online, offline, idle }

class Device {
  String id;
  String name;
  DeviceStatus status;
  double latitude;
  double longitude;

  Device({
    required this.id,
    required this.name,
    required this.status,
    required this.latitude,
    required this.longitude,
  });
}

class LocationHistory {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime time; // [FIX] Gunakan DateTime, bukan String

  LocationHistory({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.time,
  });
}

// ============================================================
// DATA
// ============================================================

Device trackedDevice = Device(
  id: 'dev-001',
  name: 'Kacamata VoxSight',
  status: DeviceStatus.online,
  latitude: -7.310887753118097,
  longitude: 112.72894337595493,
);

// ============================================================
// HELPER FUNCTIONS
// ============================================================

String getStatusText(DeviceStatus status) {
  if (status == DeviceStatus.online) return 'Online';
  if (status == DeviceStatus.offline) return 'Offline';
  return 'Idle';
}

Color getStatusColor(DeviceStatus status) {
  if (status == DeviceStatus.online) return Colors.green;
  if (status == DeviceStatus.offline) return Colors.grey;
  return Colors.amber;
}

// [FIX] Format DateTime ke string yang mudah dibaca
String formatTime(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')} '
      '${_monthName(dt.month)} ${dt.year}, '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return months[month - 1];
}

Future<String> getAddress(double lat, double lng) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemarks.first;
    return '${place.street}, ${place.subLocality}, ${place.locality}';
  } catch (e) {
    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }
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

  String currentAddress = 'Memuat alamat...';
  DateTime? lastUpdated; // [FIX] Simpan sebagai DateTime
  List<LocationHistory> locationHistory = [];

  @override
  void initState() {
    super.initState();
    loadAddress();
  }

  // [FIX] Satu fungsi terpusat untuk fetch alamat & catat riwayat
  Future<void> loadAddress() async {
    // Snapshot koordinat & waktu SEBELUM fetch (hindari race condition)
    final double lat = trackedDevice.latitude;
    final double lng = trackedDevice.longitude;
    final DateTime now = DateTime.now();

    String address = await getAddress(lat, lng);

    setState(() {
      currentAddress = address;
      lastUpdated = now;

      locationHistory.add(LocationHistory(
        latitude: lat,
        longitude: lng,
        address: address,
        time: now,
      ));
    });
  }

  void simulateMovement() {
    setState(() {
      trackedDevice.latitude += (random.nextDouble() - 0.5) * 0.002;
      trackedDevice.longitude += (random.nextDouble() - 0.5) * 0.002;
      currentAddress = 'Memuat alamat...';
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(trackedDevice.latitude, trackedDevice.longitude),
      ),
    );

    loadAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Tracker Location'),
        backgroundColor: const Color(0xFF2F486D),
        foregroundColor: const Color(0xFFF3EAE0),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Lokasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(history: locationHistory),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Simulasi Pergerakan',
            onPressed: simulateMovement,
          ),
        ],
      ),
      body: Column(
        children: [
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

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2F486D),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trackedDevice.name,
                  style: const TextStyle(
                    color: Color(0xFFF3EAE0),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getStatusText(trackedDevice.status),
                  style: TextStyle(
                    color: getStatusColor(trackedDevice.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentAddress,
                  style: const TextStyle(color: Color(0xFFF3EAE0), fontSize: 12),
                ),
                const SizedBox(height: 4),
                // [FIX] Tampilkan waktu real dari DateTime
                Text(
                  lastUpdated != null
                      ? 'Diperbarui: ${formatTime(lastUpdated!)}'
                      : 'Memuat waktu...',
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

// ============================================================
// HISTORY SCREEN
// ============================================================

class HistoryScreen extends StatelessWidget {
  final List<LocationHistory> history;

  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Lokasi'),
        backgroundColor: const Color(0xFF2F486D),
        foregroundColor: const Color(0xFFF3EAE0),
      ),
      body: history.isEmpty
          ? const Center(child: Text('Belum ada riwayat lokasi.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                // Terbaru di atas
                final entry = history[history.length - 1 - index];

                return ListTile(
                  leading: const Icon(Icons.location_on, color: Color(0xFF2F486D)),
                  title: Text(entry.address, style: const TextStyle(fontSize: 13)),
                  // [FIX] Format DateTime ke string saat ditampilkan
                  subtitle: Text(
                    formatTime(entry.time),
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
    );
  }
}
