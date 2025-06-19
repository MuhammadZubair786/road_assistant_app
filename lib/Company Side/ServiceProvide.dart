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
    ],
  };

  void updateAvailableServices(String type) {
    setState(() {
      selectedServiceType = type;
      selectedService = null; // Reset selected service
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF001E62),
                Color(0xFF001E62).withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            title: Text(
              'Service Provider',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompanyNotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Vehicle Type",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001E62),
                ),
              ),
              const SizedBox(height: 20),
              
              // Vehicle Type Selection
              Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         _serviceType("Car", "assets/car.png"),
                         _serviceType("Van", "assets/motorcycle.png"),
                         _serviceType("Truck", "assets/rickshaw.png"),
                       ],
                     ),
              
              const SizedBox(height: 30),
              
              if (selectedServiceType != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Available Services",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001E62),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF001E62).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        selectedServiceType!,
                        style: TextStyle(
                          color: Color(0xFF001E62),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Services Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: serviceOptions[selectedServiceType]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final service = serviceOptions[selectedServiceType]![index];
                    return _buildServiceCard(service["name"], service["icon"]);
                  },
                ),
              ] else ...[
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Please select a vehicle type",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
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


  Widget _vehicleTypeCard(String title, String imagePath) {
    bool isSelected = selectedServiceType == title;
    return GestureDetector(
      onTap: () => updateAvailableServices(title),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF001E62) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 140,
              padding: EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Color(0xFF001E62),
              ),
            ),
            SizedBox(height: 8),
            if (isSelected)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, String icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              selectedService = title;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Selected: $title"),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF001E62).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    icon,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001E62),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Available',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
