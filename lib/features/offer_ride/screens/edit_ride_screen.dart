import 'package:flutter/material.dart';

import '../models/ride_model.dart';
import '../services/ride_service.dart';

class EditRideScreen extends StatefulWidget {
  final RideModel ride;

  const EditRideScreen({
    super.key,
    required this.ride,
  });

  @override
  State<EditRideScreen> createState() => _EditRideScreenState();
}

class _EditRideScreenState extends State<EditRideScreen> {
  static const Color primary = Color(0xFF5B4CF0);

  final RideService rideService = RideService();

  late final TextEditingController pickupController;
  late final TextEditingController destinationController;
  late final TextEditingController dateController;
  late final TextEditingController timeController;
  late final TextEditingController priceController;
  late final TextEditingController descriptionController;

  late String vehicle;
  late int seats;

  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    pickupController = TextEditingController(
      text: widget.ride.pickup,
    );

    destinationController = TextEditingController(
      text: widget.ride.destination,
    );

    dateController = TextEditingController(
      text: widget.ride.date,
    );

    timeController = TextEditingController(
      text: widget.ride.time,
    );

    priceController = TextEditingController(
      text: widget.ride.price.toString(),
    );

    descriptionController = TextEditingController(
      text: widget.ride.description,
    );

    vehicle = widget.ride.vehicle;
    seats = widget.ride.seats;
  }

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
        title: const Text("Edit Ride"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTextField(
              controller: pickupController,
              label: "Pickup Location",
              icon: Icons.my_location,
            ),

            const SizedBox(height: 18),

            buildTextField(
              controller: destinationController,
              label: "Destination",
              icon: Icons.location_on,
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
              onChanged: isUpdating
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
                    onPressed: isUpdating
                        ? null
                        : () {
                      if (seats > 1) {
                        setState(() {
                          seats--;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.remove_circle_outline,
                    ),
                  ),
                  Text(
                    seats.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: isUpdating
                        ? null
                        : () {
                      if (seats < 8) {
                        setState(() {
                          seats++;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                    ),
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
                onPressed: isUpdating ? null : updateRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: isUpdating
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(
                  isUpdating ? "Updating..." : "Update Ride",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateRide() async {
    final pickup = pickupController.text.trim();
    final destination = destinationController.text.trim();
    final date = dateController.text.trim();
    final time = timeController.text.trim();
    final priceText = priceController.text.trim();
    final description = descriptionController.text.trim();

    if (pickup.isEmpty ||
        destination.isEmpty ||
        date.isEmpty ||
        time.isEmpty ||
        priceText.isEmpty ||
        description.isEmpty) {
      showMessage("Please fill all required fields.");
      return;
    }

    final int? price = int.tryParse(priceText);

    if (price == null || price <= 0) {
      showMessage("Please enter a valid price.");
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      await rideService.updateRide(
        widget.ride.id,
        {
          "pickup": pickup,
          "destination": destination,
          "date": date,
          "time": time,
          "vehicle": vehicle,
          "seats": seats,
          "price": price,
          "description": description,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ride updated successfully."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      showMessage("Failed to update ride.");
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
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
      enabled: !isUpdating,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
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