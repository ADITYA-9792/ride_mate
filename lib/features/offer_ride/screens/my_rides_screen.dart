import 'package:flutter/material.dart';

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

  static const Color primary = Color(0xFF5B4CF0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Offered Rides"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          rideCard(),

          rideCard(),

          rideCard(),

        ],
      ),
    );
  }

  Widget rideCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "ABES College → Noida Sector 62",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text("Tomorrow • 9:30 AM"),

            const SizedBox(height: 5),

            const Text("₹80 / Seat"),

            const SizedBox(height: 5),

            const Text("3 Seats Available"),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {

                    },

                    icon: const Icon(Icons.edit),

                    label: const Text("Edit"),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),

                    onPressed: () {

                    },

                    icon: const Icon(Icons.cancel),

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
}