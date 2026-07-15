import 'package:flutter/material.dart';

import 'create_ride_screen.dart';
import 'my_rides_screen.dart';
import 'ride_preferences_screen.dart';
import 'ride_stats_screen.dart';

class OfferRideScreen extends StatelessWidget {
  const OfferRideScreen({super.key});

  static const Color primary = Color(0xFF5B4CF0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offer Ride"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          const Text(
            "Ready to Share Your Ride?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Manage your rides from one place.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 30),

          buildCard(
            context,
            Icons.add_circle,
            "Offer New Ride",
            "Create and publish a ride",
            const CreateRideScreen(),
          ),

          buildCard(
            context,
            Icons.directions_car,
            "My Offered Rides",
            "View all your rides",
            const MyRidesScreen(),
          ),

          buildCard(
            context,
            Icons.bar_chart,
            "Ride Statistics",
            "Bookings & Earnings",
            const RideStatsScreen(),
          ),

          buildCard(
            context,
            Icons.settings,
            "Ride Preferences",
            "Manage your preferences",
            const RidePreferencesScreen(),
          ),
        ],
      ),
    );
  }

  Widget buildCard(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      Widget page,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),

      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          radius: 25,
          backgroundColor: primary.withOpacity(.12),
          child: Icon(icon, color: primary),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(subtitle),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }
}