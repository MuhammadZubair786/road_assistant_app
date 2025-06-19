import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../home_screen.dart';
import 'RequestConfirmation.dart';

class RequestServiceScreen extends StatefulWidget {
  const RequestServiceScreen({super.key});

  @override
  _RequestServiceScreenState createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  var services = [];
  String? selectedService;
  String? selectedVehicle;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showVehicleSelectionDialog();
    });
  }

  void _showVehicleSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF001E62).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/HelpSupport.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Your Vehicle',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001E62),
                  ),
                ),
                const SizedBox(height: 24),
                _buildVehicleOption('Car', 'assets/car.png'),
                const Divider(height: 1),
                _buildVehicleOption('Van', 'assets/motorcycle.png'),
                const Divider(height: 1),
                _buildVehicleOption('Truck', 'assets/rickshaw.png'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleOption(String vehicle, String imagePath) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedVehicle = vehicle;
        });
        Navigator.pop(context);
        fetchServices(vehicle);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF001E62).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              vehicle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF001E62),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF001E62),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void fetchServices(String vehicleType) async {
    setState(() => isLoading = true);

    var fetchedServices = {
      "Car": [
        {"name": "Towing Service", "icon": "assets/HelpSupport.png"},
        {"name": "Flat Tire", "icon": "assets/flat_trye.png"},
        {"name": "Battery Jump Start", "icon": "assets/batter_jump.png"},
        {"name": "Engine Overheating", "icon": "assets/download (1).jfif"},
        {"name": "Brake Issue", "icon": "assets/brak.png"},
        {"name": "Oil Change", "icon": "assets/oil change.png"},
        {"name": "AC Repair", "icon": "assets/ac.png"},
      ],
      "Van": [
        {"name": "Towing Service", "icon": "assets/HelpSupport.png"},
        {"name": "Flat Tire", "icon": "assets/flat_trye.png"},
        {"name": "Battery Jump Start", "icon": "assets/batter_jump.png"},
        {"name": "Engine Overheating", "icon": "assets/download (1).jfif"},
        {"name": "Brake Issue", "icon": "assets/brak.png"},
        {"name": "Oil Change", "icon": "assets/oil change.png"},
        {"name": "AC Repair", "icon": "assets/ac.png"},
      ],
      "Truck": [
        {"name": "Towing Service", "icon": "assets/HelpSupport.png"},
        {"name": "Flat Tire", "icon": "assets/flat_trye.png"},
        {"name": "Battery Jump Start", "icon": "assets/batter_jump.png"},
        {"name": "Engine Overheating", "icon": "assets/download (1).jfif"},
        {"name": "Brake Issue", "icon": "assets/brak.png"},
        {"name": "Oil Change", "icon": "assets/oil change.png"},
        {"name": "AC Repair", "icon": "assets/ac.png"},
      ],
    };

    setState(() {
      services = fetchedServices[vehicleType] ?? [];
      isLoading = false;
    });
  }

  void saveSelectedService() async {
    if (selectedService != null) {
      await FirebaseFirestore.instance
          .collection('userSelectedService')
          .doc('currentService')
          .set({
        'service': selectedService,
        'vehicle': selectedVehicle,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF001E62).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.build_rounded,
                              color: Color(0xFF001E62),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Select Service',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF001E62),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose the service you need assistance with',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading ? _buildShimmerEffect() : _buildServiceGrid(),
                ),
              ],
            ),
          ),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF001E62),
            const Color(0xFF001E62).withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()));
                    },
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.car_repair, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          selectedVehicle ?? 'Select Vehicle',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Text(
              'Request a Service',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        bool isSelected = selectedService == service['name'];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedService = service['name'];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF001E62) : Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                    ? const Color(0xFF001E62).withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                  blurRadius: isSelected ? 15 : 10,
                  offset: const Offset(0, 5),
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFF001E62).withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ] : null,
                  ),
                  child: Image.asset(
                    service['icon'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    service['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF001E62),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.85,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: selectedService == null
            ? null
            : () {
                saveSelectedService();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestConfirmation(),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF001E62),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedService == null ? 'Select a Service' : 'Continue',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (selectedService != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
