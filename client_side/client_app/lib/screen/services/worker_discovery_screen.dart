import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../models/technician.dart';
import 'provider/technician_provider.dart';
import 'technician_detail_screen.dart';

class WorkerDiscoveryScreen extends StatefulWidget {
  final String serviceCategory;

  const WorkerDiscoveryScreen({
    super.key,
    required this.serviceCategory,
  });

  @override
  State<WorkerDiscoveryScreen> createState() => _WorkerDiscoveryScreenState();
}

class _WorkerDiscoveryScreenState extends State<WorkerDiscoveryScreen> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  bool _isMapView = true;
  bool _isLoadingLocation = true;
  Set<Marker> _markers = {};
  final double _searchRadius = 10.0; // km

  // Filters
  double _minRating = 0.0;
  double _maxPrice = 1000.0;
  bool _verifiedOnly = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          _showError('Location permission denied');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userPosition = position;
        _isLoadingLocation = false;
      });

      // Load technicians near user
      if (mounted) {
        await context.read<TechnicianProvider>().loadNearbyTechnicians(
              category: widget.serviceCategory,
              latitude: position.latitude,
              longitude: position.longitude,
              radiusKm: _searchRadius,
            );
      }

      _updateMarkers();
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      _showError('Error getting location: $e');
    }
  }

  void _updateMarkers() {
    if (_userPosition == null) return;

    final technicians = context.read<TechnicianProvider>().filteredTechnicians;
    final Set<Marker> markers = {};

    // User location marker
    markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'You are here'),
      ),
    );

    // Technician markers
    for (final tech in technicians) {
      if (tech.latitude != null && tech.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(tech.id),
            position: LatLng(tech.latitude!, tech.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              tech.verified
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: tech.name,
              snippet:
                  '⭐ ${tech.rating.toStringAsFixed(1)} • ${tech.skills.join(', ')}',
            ),
            onTap: () => _showTechnicianDetails(tech),
          ),
        );
      }
    }

    setState(() => _markers = markers);
  }

  void _showTechnicianDetails(Technician tech) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TechnicianDetailScreen(technician: tech),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serviceCategory} - Find Workers'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () => setState(() => _isMapView = !_isMapView),
            tooltip: _isMapView ? 'List View' : 'Map View',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : _isMapView
              ? _buildMapView()
              : _buildListView(),
    );
  }

  Widget _buildMapView() {
    if (_userPosition == null) {
      return const Center(
        child: Text('Unable to get your location'),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
        zoom: 13,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) => _mapController = controller,
    );
  }

  Widget _buildListView() {
    return Consumer<TechnicianProvider>(
      builder: (context, provider, _) {
        final technicians = provider.filteredTechnicians;

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (technicians.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No workers found nearby',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('Try adjusting your filters or search radius'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: technicians.length,
          itemBuilder: (context, index) {
            final tech = technicians[index];
            final distance = _userPosition != null
                ? tech.distanceFrom(
                    _userPosition!.latitude, _userPosition!.longitude)
                : null;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: tech.profileImage != null
                      ? NetworkImage(tech.profileImage!)
                      : null,
                  child: tech.profileImage == null
                      ? Text(tech.name[0].toUpperCase())
                      : null,
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(tech.name)),
                    if (tech.verified)
                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                            '${tech.rating.toStringAsFixed(1)} (${tech.totalJobs} jobs)'),
                      ],
                    ),
                    if (distance != null)
                      Text('📍 ${distance.toStringAsFixed(1)} km away'),
                    if (tech.pricePerHour != null)
                      Text('₹${tech.pricePerHour}/hr'),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showTechnicianDetails(tech),
              ),
            );
          },
        );
      },
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text('Minimum Rating: ${_minRating.toStringAsFixed(1)}'),
              Slider(
                value: _minRating,
                min: 0,
                max: 5,
                divisions: 10,
                onChanged: (value) => setState(() => _minRating = value),
              ),
              const SizedBox(height: 8),
              Text('Max Price: ₹${_maxPrice.toStringAsFixed(0)}/hr'),
              Slider(
                value: _maxPrice,
                min: 100,
                max: 2000,
                divisions: 38,
                onChanged: (value) => setState(() => _maxPrice = value),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Verified Only'),
                value: _verifiedOnly,
                onChanged: (value) => setState(() => _verifiedOnly = value),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    context.read<TechnicianProvider>().applyFilters(
          minRating: _minRating,
          maxPrice: _maxPrice,
          verifiedOnly: _verifiedOnly,
        );
    _updateMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
