import 'package:firebase_app/lib/User%20Side/home_screen.dart';
import 'package:firebase_app/lib/User%20Side/service_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetServices extends StatefulWidget {
  final String docid;
  const GetServices({super.key, required this.docid});

  @override
  _GetServicesState createState() => _GetServicesState();
}

class _GetServicesState extends State<GetServices> {
  String? selectedService;
  bool isLoading = false;

  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    fetchSelectedService();
  }

  void fetchSelectedService() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.docid)
          .get();

      if (doc.exists) {
        setState(() {
          data = doc.data() as Map<String, dynamic>?;
         selectedService = doc['selected_service'];
        });
      } else {
        print("No service found in Firestore");
      }
      print(data);
    } catch (e) {
      print("Error fetching service: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

 void sendRequest(companyData) async {
  setState(() {
    isLoading = true; // show loading
  });

  try {
    DocumentSnapshot requestDoc = await FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.docid)
        .get();

    if (requestDoc.exists) {
      Map<String, dynamic> requestData =
          requestDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.docid)
          .update({
        'timestamp': FieldValue.serverTimestamp(),
        'companyId': companyData["uid"],
        "companyAddress": companyData["address"],
        "companyName": companyData["name"],
        "status":"pending"
      });
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request Sent Successfully")),
      );

      // Delay before navigating
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    } else {
      print("Request document not found!");
    }
  } catch (e) {
    print("Error sending request: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to send request")),
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false; // hide loading
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Get Services",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF001E62),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else ...[
            selectedService != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ServiceCard(
                              icon: Icons.build_circle,
                              title: selectedService!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Text(
                    "No selected service found",
                    style: TextStyle(fontSize: 16),
                  ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Services Available Nearby',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Company')
                    .where('isAvailable', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No available services at the moment."));
                  }

                  final companies = snapshot.data!.docs;

                  return ListView.builder(
                    physics:
                        NeverScrollableScrollPhysics(), // Important for inside scroll view
                    shrinkWrap: true,
                    itemCount: companies.length,
                    itemBuilder: (context, index) {
                      var company = companies[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.store,
                                    color: Color(0xFF001E62)),
                                title: Text(
                                  company['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(company['address']),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF001E62),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.send,
                                      color: Colors.amber),
                                  label: const Text(
                                    "Send Request",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    try {
                                      print(widget.docid);
                                      sendRequest(company.data());
                                      // Your Firestore send logic here
                                    } catch (e) {
                                      print("Error sending request: $e");
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text("Failed to send request"),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ],
      ),
    );
  }
}
