import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/ride_model.dart';
import '../services/ride_service.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  static const Color primary = Color(0xFF5B4CF0);

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController =
  TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController =
  TextEditingController();

  final RideService rideService = RideService();

  String vehicle = "Car";
  int seats = 1;
  bool isPublishing = false;

  @override
  void dispose() {
    pickupController.dispose();
    destinationController.dispose();
    dateController.dispose();
    timeController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offer New Ride"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Ride",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Fill the ride details below.",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            buildTextField(
              controller: pickupController,
              label: "Pickup Location",
              icon: Icons.my_location,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 18),

            buildTextField(
              controller: destinationController,
              label: "Destination",
              icon: Icons.location_on,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 18),

            TextField(
              controller: dateController,
              readOnly: true,
              onTap: selectDate,
              decoration: buildInputDecoration(
                label: "Travel Date",
                icon: Icons.calendar_today,
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: timeController,
              readOnly: true,
              onTap: selectTime,
              decoration: buildInputDecoration(
                label: "Departure Time",
                icon: Icons.access_time,
              ),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              initialValue: vehicle,
              decoration: buildInputDecoration(
                label: "Vehicle",
                icon: Icons.directions_car,
              ),
              items: const [
                DropdownMenuItem(
                  value: "Car",
                  child: Text("Car"),
                ),
                DropdownMenuItem(
                  value: "SUV",
                  child: Text("SUV"),
                ),
                DropdownMenuItem(
                  value: "Sedan",
                  child: Text("Sedan"),
                ),
                DropdownMenuItem(
                  value: "Hatchback",
                  child: Text("Hatchback"),
                ),
                DropdownMenuItem(
                  value: "Bike",
                  child: Text("Bike"),
                ),
              ],
              onChanged: isPublishing
                  ? null
                  : (value) {
                if (value == null) return;

                setState(() {
                  vehicle = value;
                });
              },
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_seat),
                  const SizedBox(width: 15),
                  const Text(
                    "Available Seats",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: isPublishing
                        ? null
                        : () {
                      if (seats > 1) {
                        setState(() {
                          seats--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    seats.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: isPublishing
                        ? null
                        : () {
                      if (seats < 8) {
                        setState(() {
                          seats++;
                        });
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            buildTextField(
              controller: priceController,
              label: "Price Per Seat (₹)",
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 20),

            buildTextField(
              controller: descriptionController,
              label: "Ride Description",
              icon: Icons.notes,
              maxLines: 4,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withValues(alpha: 0.6),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: isPublishing ? null : publishRide,
                icon: isPublishing
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.publish),
                label: Text(
                  isPublishing ? "Publishing..." : "Publish Ride",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> publishRide() async {
    FocusScope.of(context).unfocus();

    final String pickup = pickupController.text.trim();
    final String destination = destinationController.text.trim();
    final String date = dateController.text.trim();
    final String time = timeController.text.trim();
    final String priceText = priceController.text.trim();
    final String description = descriptionController.text.trim();

    if (pickup.isEmpty ||
        destination.isEmpty ||
        date.isEmpty ||
        time.isEmpty ||
        priceText.isEmpty ||
        description.isEmpty) {
      showMessage("Please fill all required fields.");
      return;
    }

    if (pickup.toLowerCase() == destination.toLowerCase()) {
      showMessage("Pickup and destination cannot be the same.");
      return;
    }

    final int? price = int.tryParse(priceText);

    if (price == null || price <= 0) {
      showMessage("Please enter a valid price.");
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage("Please log in before publishing a ride.");
      return;
    }

    final RideModel ride = RideModel(
      userId: user.uid,
      pickup: pickup,
      destination: destination,
      date: date,
      time: time,
      vehicle: vehicle,
      seats: seats,
      price: price,
      description: description,
      status: "active",
      createdAt: DateTime.now(),
    );

    setState(() {
      isPublishing = true;
    });

    try {
      await rideService.publishRide(ride);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ride published successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      showMessage(
        error.message ?? "Authentication error occurred.",
      );
    } catch (error) {
      if (!mounted) return;

      showMessage("Failed to publish ride. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          isPublishing = false;
        });
      }
    }
  }

  Future<void> selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (!mounted || picked == null) return;

    dateController.text =
    "${picked.day.toString().padLeft(2, '0')}/"
        "${picked.month.toString().padLeft(2, '0')}/"
        "${picked.year}";
  }

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted || picked == null) return;

    timeController.text = picked.format(context);
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      enabled: !isPublishing,
      decoration: buildInputDecoration(
        label: label,
        icon: icon,
      ),
    );
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: primary,
          width: 2,
        ),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}