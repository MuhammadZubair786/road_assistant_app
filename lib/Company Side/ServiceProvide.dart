import 'package:flutter/material.dart';
import 'CompanyNotification.dart';
import 'Drawer.dart';

class ServiceProvide extends StatefulWidget {
  @override
  _ServiceProvideState createState() => _ServiceProvideState();
}

class _ServiceProvideState extends State<ServiceProvide> {
  String? selectedServiceType;
  String? selectedService;

  // ✅ Local services (no Firebase)
  Map<String, List<Map<String, dynamic>>> serviceOptions = {
   "Car": [
      {"name": "Towing Service", "icon": "assets/HelpSupport.png"},
      {"name": "Flat Tire", "icon": "assets/flat_trye.png"},
      {"name": "Battery Jump Start", "icon": "assets/batter_jump.png"},
      {"name": "Engine Overheating", "icon":"assets/download (1).jfif"},
      {"name": "Brake Issue", "icon": "assets/brak.png"},
      {"name": "Oil Change", "icon": "assets/oil change.png"},
      {"name": "AC Repair", "icon": "assets/ac.png"},
    ],
    "Van": [
       {"name": "Towing Service", "icon": "assets/HelpSupport.png"},
      {"name": "Flat Tire", "icon": "assets/flat_trye.png"},
      {"name": "Battery Jump Start", "icon": "assets/batter_jump.png"},
      {"name": "Engine Overheating", "icon":"assets/download (1).jfif"},
      {"name": "Brake Issue", "icon": "assets/brak.png"},
      {"name": "Oil Change", "icon": "assets/oil change.png"},
      {"name": "AC Repair", "icon": "assets/ac.png"},
    ],
    "Truck": [
     {"name": "Towing Service", "icon": "assets/HelpSupport.png"},
      {"name": "Flat Tire", "icon": "assets/flat_trye.png"},
      {"name": "Battery Jump Start", "icon": "assets/batter_jump.png"},
      {"name": "Engine Overheating", "icon":"assets/download (1).jfif"},
      {"name": "Brake Issue", "icon": "assets/brak.png"},
      {"name": "Oil Change", "icon": "assets/oil change.png"},
      {"name": "AC Repair", "icon": "assets/ac.png"},
    ],  };

  void updateAvailableServices(String type) {
    setState(() {
      selectedServiceType = type;
      selectedService = null; // Reset selected service
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF001E62), Colors.white],
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CompanyNotificationsScreen(),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("Service Provide For",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _serviceType("Car", "assets/car.png"),
              _serviceType("Van", "assets/motorcycle.png"),
              _serviceType("Truck", "assets/rickshaw.png"),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Your Service",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: (serviceOptions[selectedServiceType] ?? [])
                  .map((service) =>
                      _serviceCard(service["name"], service["icon"]))
                  .toList(),
            ),
          ),
        ],
      ),
      drawer: CompanyDrawer(),
    );
  }

  Widget _serviceType(String title, String imagePath) {
    bool isSelected = selectedServiceType == title;
    return GestureDetector(
      onTap: () => updateAvailableServices(title),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Image.asset(imagePath, width: 100, height: 50),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(String title,  icon) {
    bool isSelected = selectedService == title;
    return GestureDetector(
      // onTap: () {
      //   setState(() {
      //     selectedService = title;
      //   });
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Selected: $title")),
      //   );
      // },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Image.asset(icon,
                width: 100,
                height: 50,
                fit: BoxFit.contain,
                // color: Colors.white,
                ),
              const SizedBox(height: 10),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Icon(Icons.check_circle,
                  color:Colors.green ),
            ],
          ),
        ),
      ),
    );
  }
}
