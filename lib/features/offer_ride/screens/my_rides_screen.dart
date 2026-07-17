import 'package:flutter/material.dart';

import '../models/ride_model.dart';
import '../services/ride_service.dart';
import 'edit_ride_screen.dart';

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

  static const Color primary = Color(0xFF5B4CF0);

  @override
  Widget build(BuildContext context) {
    final RideService rideService = RideService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Offered Rides"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<RideModel>>(
        stream: rideService.getMyRides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Failed to load rides.\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final List<RideModel> rides = snapshot.data ?? [];

          if (rides.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No offered rides yet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Publish a ride and it will appear here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final RideModel ride = rides[index];

              return buildRideCard(
                context: context,
                ride: ride,
                rideService: rideService,
              );
            },
          );
        },
      ),
    );
  }

  Widget buildRideCard({
    required BuildContext context,
    required RideModel ride,
    required RideService rideService,
  }) {
    final bool isCancelled = ride.status == "cancelled";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${ride.pickup} → ${ride.destination}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? Colors.red.withValues(alpha: 0.12)
                        : Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCancelled ? "Cancelled" : "Active",
                    style: TextStyle(
                      color: isCancelled ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            buildInfoRow(
              Icons.calendar_today,
              ride.date,
            ),

            buildInfoRow(
              Icons.access_time,
              ride.time,
            ),

            buildInfoRow(
              Icons.directions_car,
              ride.vehicle,
            ),

            buildInfoRow(
              Icons.event_seat,
              "${ride.seats} seats available",
            ),

            buildInfoRow(
              Icons.currency_rupee,
              "₹${ride.price} per seat",
            ),

            if (ride.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                ride.description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isCancelled
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditRideScreen(
                            ride: ride,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text("Edit"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isCancelled
                        ? null
                        : () {
                      showCancelDialog(
                        context: context,
                        ride: ride,
                        rideService: rideService,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(
      IconData icon,
      String text,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Future<void> showCancelDialog({
    required BuildContext context,
    required RideModel ride,
    required RideService rideService,
  }) async {
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Ride"),
          content: Text(
            "Do you want to cancel the ride from "
                "${ride.pickup} to ${ride.destination}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("No"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Yes, Cancel"),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    try {
      await rideService.cancelRide(ride.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ride cancelled successfully."),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to cancel ride."),
        ),
      );
    }
  }
}