import 'package:flutter/material.dart';

import '../../find_ride/find_ride_screen.dart';
import '../../offer_ride/screens/offer_ride_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primary = Color(0xFF5B4CF0);
  static const Color green = Color(0xFF00A884);

  int selectedIndex = 0;

  void _openFindRide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FindRideScreen(),
      ),
    );
  }

  void _openOfferRide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OfferRideScreen(),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    if (index == 0) {
      setState(() {
        selectedIndex = 0;
      });
      return;
    }

    switch (index) {
      case 1:
        _openFindRide();
        break;

      case 2:
        _openOfferRide();
        break;

      case 3:
        _openProfile();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.directions_car_rounded,
              color: primary,
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'RideMate',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            onPressed: widget.toggleTheme,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notifications will be added later.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello 👋',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Where are you going?',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 25),
            buildSearchCard(),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: buildActionCard(
                    icon: Icons.search_rounded,
                    title: 'Find Ride',
                    subtitle: 'Search rides',
                    color: primary,
                    onTap: _openFindRide,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildActionCard(
                    icon: Icons.add_road_rounded,
                    title: 'Offer Ride',
                    subtitle: 'Share your trip',
                    color: green,
                    onTap: _openOfferRide,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            buildSectionHeader(
              'Popular Routes',
              'See all',
            ),
            const SizedBox(height: 15),
            buildRouteCard(
              from: 'ABES College',
              to: 'Noida',
              price: '₹60',
              seats: '4 seats available',
            ),
            buildRouteCard(
              from: 'Crossing Republik',
              to: 'Sector 62',
              price: '₹100',
              seats: '2 seats available',
            ),
            buildRouteCard(
              from: 'Arihant',
              to: 'ArthaMart',
              price: '₹80',
              seats: '3 seats available',
            ),
            const SizedBox(height: 30),
            buildSectionHeader(
              'Why RideMate?',
              '',
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: buildFeatureCard(
                    Icons.verified_user_rounded,
                    'Verified',
                    'Trusted users',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildFeatureCard(
                    Icons.location_on_rounded,
                    'Live Track',
                    'Track your ride',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildFeatureCard(
                    Icons.currency_rupee_rounded,
                    'Zero Fee',
                    'No platform fee',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildFeatureCard(
                    Icons.chat_bubble_rounded,
                    'Chat',
                    'Connect easily',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildFeatureCard(
                    Icons.star_rounded,
                    'Ratings',
                    'Trusted drivers',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildFeatureCard(
                    Icons.security_rounded,
                    'Safe Ride',
                    'Secure travel',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _handleBottomNavigation,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(
              Icons.directions_car_rounded,
            ),
            label: 'My Rides',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildSearchCard() {
    final ThemeData theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildLocationField(
              icon: Icons.radio_button_checked,
              color: primary,
              hint: 'Leaving from',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 2,
                  height: 20,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            buildLocationField(
              icon: Icons.location_on_rounded,
              color: Colors.redAccent,
              hint: 'Going to',
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed: _openFindRide,
                icon: const Icon(Icons.search_rounded),
                label: const Text(
                  'Search Rides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLocationField({
    required IconData icon,
    required Color color,
    required String hint,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.20,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionHeader(
      String title,
      String action,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (action.isNotEmpty)
          TextButton(
            onPressed: _openFindRide,
            child: Text(action),
          ),
      ],
    );
  }

  Widget buildRouteCard({
    required String from,
    required String to,
    required String price,
    required String seats,
  }) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.route_rounded,
                color: primary,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$from → $to',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    seats,
                    style: TextStyle(
                      color:
                      theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                FilledButton(
                  onPressed: _openFindRide,
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: const Size(70, 36),
                  ),
                  child: const Text('Book'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeatureCard(
      IconData icon,
      String title,
      String subtitle,
      ) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
            primary.withValues(alpha: 0.12),
            child: Icon(
              icon,
              color: primary,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: primary,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: primary,
                ),
              ),
              accountName: Text('RideMate User'),
              accountEmail: Text('user@example.com'),
            ),
            buildDrawerItem(
              Icons.home_rounded,
              'Home',
            ),
            buildDrawerItem(
              Icons.search_rounded,
              'Find Ride',
              onTap: _openFindRide,
            ),
            buildDrawerItem(
              Icons.add_road_rounded,
              'Offer Ride',
              onTap: _openOfferRide,
            ),
            buildDrawerItem(
              Icons.person_rounded,
              'My Profile',
              onTap: _openProfile,
            ),
            buildDrawerItem(
              Icons.history,
              'Ride History',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Ride History will be added later.',
                    ),
                  ),
                );
              },
            ),
            buildDrawerItem(
              Icons.favorite,
              'Saved Rides',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Saved Rides will be added later.',
                    ),
                  ),
                );
              },
            ),
            buildDrawerItem(
              Icons.settings,
              'Settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Settings will be added later.',
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            buildDrawerItem(
              Icons.logout,
              'Logout',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logout will be connected later.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem(
      IconData icon,
      String title, {
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        Navigator.pop(context);

        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}