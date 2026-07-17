import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/login/login_screen.dart';
import '../find_ride/find_ride_screen.dart';
import '../map/screens/open_street_map_screen.dart';
import '../offer_ride/screens/offer_ride_screen.dart';

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
  static const Color mapColor = Color(0xFFEF6C00);

  final TextEditingController leavingFromController =
  TextEditingController();

  final TextEditingController goingToController =
  TextEditingController();

  int selectedIndex = 0;

  @override
  void dispose() {
    leavingFromController.dispose();
    goingToController.dispose();
    super.dispose();
  }

  void openFindRide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FindRideScreen(),
      ),
    );
  }

  void openOfferRide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OfferRideScreen(),
      ),
    );
  }

  Future<void> openMap() async {
    final Map<String, dynamic>? result =
    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const OpenStreetMapScreen(),
      ),
    );

    if (!mounted || result == null) return;

    final double? pickupLatitude =
    result['pickupLatitude'] as double?;

    final double? pickupLongitude =
    result['pickupLongitude'] as double?;

    final double? destinationLatitude =
    result['destinationLatitude'] as double?;

    final double? destinationLongitude =
    result['destinationLongitude'] as double?;

    showMessage(
      'Route selected\n'
          'Pickup: $pickupLatitude, $pickupLongitude\n'
          'Destination: $destinationLatitude, $destinationLongitude',
    );
  }

  void searchRides() {
    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FindRideScreen(),
      ),
    );
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> logout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout from RideMate?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            themeMode: widget.themeMode,
            toggleTheme: widget.toggleTheme,
          ),
        ),
            (route) => false,
      );
    } catch (error) {
      showMessage('Logout failed: $error');
    }
  }

  void onBottomNavigationSelected(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;

      case 1:
        openFindRide();
        break;

      case 2:
        showMessage(
          'My Rides screen will show offered and booked rides.',
        );
        break;

      case 3:
        showMessage('Profile screen will be added here.');
        break;
    }

    if (index != 0 && mounted) {
      setState(() {
        selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark =
        theme.brightness == Brightness.dark;

    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    final String displayName =
    currentUser?.displayName?.trim().isNotEmpty == true
        ? currentUser!.displayName!
        : 'Aditya';

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
            tooltip: isDark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            onPressed: widget.toggleTheme,
            icon: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 300,
              ),
              child: Icon(
                isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              showMessage(
                'You have no new notifications.',
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
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          35,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $displayName 👋',
              style: TextStyle(
                color: theme
                    .colorScheme.onSurfaceVariant,
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
                    subtitle: 'Search available rides',
                    color: primary,
                    onTap: openFindRide,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: buildActionCard(
                    icon: Icons.add_road_rounded,
                    title: 'Offer Ride',
                    subtitle: 'Share your trip',
                    color: green,
                    onTap: openOfferRide,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            buildWideActionCard(
              icon: Icons.map_rounded,
              title: 'Open Live Map',
              subtitle:
              'Select pickup and destination on OpenStreetMap',
              color: mapColor,
              onTap: openMap,
            ),

            const SizedBox(height: 32),

            buildSectionHeader(
              title: 'Popular Routes',
              action: 'See all',
              onActionPressed: openFindRide,
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
              title: 'Why RideMate?',
              action: '',
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: buildFeatureCard(
                    icon:
                    Icons.verified_user_rounded,
                    title: 'Verified',
                    subtitle: 'Trusted users',
                    onTap: () {
                      showMessage(
                        'User verification feature.',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: buildFeatureCard(
                    icon:
                    Icons.location_on_rounded,
                    title: 'Live Track',
                    subtitle: 'Track your ride',
                    onTap: openMap,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: buildFeatureCard(
                    icon:
                    Icons.currency_rupee_rounded,
                    title: 'Zero Fee',
                    subtitle: 'No platform fee',
                    onTap: () {
                      showMessage(
                        'RideMate does not charge platform fees.',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: buildFeatureCard(
                    icon:
                    Icons.chat_bubble_rounded,
                    title: 'Chat',
                    subtitle: 'Connect easily',
                    onTap: () {
                      showMessage(
                        'Chat feature will open after booking.',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: buildFeatureCard(
                    icon: Icons.star_rounded,
                    title: 'Ratings',
                    subtitle: 'Trusted drivers',
                    onTap: () {
                      showMessage(
                        'Ratings and reviews will appear here.',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: buildFeatureCard(
                    icon: Icons.security_rounded,
                    title: 'Safe Ride',
                    subtitle: 'Secure travel',
                    onTap: () {
                      showMessage(
                        'RideMate safety features.',
                      );
                    },
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
        onDestinationSelected:
        onBottomNavigationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon:
            Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.directions_car_outlined,
            ),
            selectedIcon: Icon(
              Icons.directions_car_rounded,
            ),
            label: 'My Rides',
          ),
          NavigationDestination(
            icon:
            Icon(Icons.person_outline_rounded),
            selectedIcon:
            Icon(Icons.person_rounded),
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
              controller:
              leavingFromController,
              icon:
              Icons.radio_button_checked,
              color: primary,
              hint: 'Leaving from',
              textInputAction:
              TextInputAction.next,
            ),

            Padding(
              padding:
              const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin:
                  const EdgeInsets.only(left: 10),
                  width: 2,
                  height: 20,
                  color:
                  theme.colorScheme.outline,
                ),
              ),
            ),

            buildLocationField(
              controller: goingToController,
              icon:
              Icons.location_on_rounded,
              color: Colors.redAccent,
              hint: 'Going to',
              textInputAction:
              TextInputAction.search,
              onSubmitted: (_) => searchRides(),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed: searchRides,
                icon: const Icon(
                  Icons.search_rounded,
                ),
                label: const Text(
                  'Search Rides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: openMap,
                icon: const Icon(
                  Icons.map_outlined,
                ),
                label: const Text(
                  'Select Route on Map',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLocationField({
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required String hint,
    required TextInputAction textInputAction,
    ValueChanged<String>? onSubmitted,
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
            controller: controller,
            textCapitalization:
            TextCapitalization.words,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ),

        IconButton(
          tooltip: 'Select on map',
          onPressed: openMap,
          icon: const Icon(
            Icons.map_outlined,
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius:
          BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                Colors.white.withOpacity(0.20),
                borderRadius:
                BorderRadius.circular(12),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

  Widget buildWideActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius:
          BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color:
                Colors.white.withOpacity(0.20),
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionHeader({
    required String title,
    required String action,
    VoidCallback? onActionPressed,
  }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
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
            onPressed: onActionPressed,
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
        borderRadius:
        BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                primary.withOpacity(0.12),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.route_rounded,
                color: primary,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '$from → $to',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    seats,
                    style: TextStyle(
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: primary,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                FilledButton(
                  onPressed: openFindRide,
                  style:
                  FilledButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize:
                    const Size(70, 36),
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

  Widget buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius:
          BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
              primary.withOpacity(0.12),
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
                color: theme.colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer() {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    final String userName =
        currentUser?.displayName ??
            'Aditya Vikram Singh';

    final String userEmail =
        currentUser?.email ??
            'aditya@example.com';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: primary,
              ),
              currentAccountPicture:
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: primary,
                ),
              ),
              accountName: Text(userName),
              accountEmail: Text(userEmail),
            ),

            buildDrawerItem(
              icon: Icons.home_rounded,
              title: 'Home',
            ),

            buildDrawerItem(
              icon: Icons.search_rounded,
              title: 'Find Ride',
              onTap: openFindRide,
            ),

            buildDrawerItem(
              icon: Icons.add_road_rounded,
              title: 'Offer Ride',
              onTap: openOfferRide,
            ),

            buildDrawerItem(
              icon: Icons.map_rounded,
              title: 'Open Map',
              onTap: openMap,
            ),

            buildDrawerItem(
              icon:
              Icons.directions_car_rounded,
              title: 'My Rides',
              onTap: () {
                showMessage(
                  'My Rides screen will be added here.',
                );
              },
            ),

            buildDrawerItem(
              icon: Icons.history,
              title: 'Ride History',
              onTap: () {
                showMessage(
                  'Ride History screen will be added here.',
                );
              },
            ),

            buildDrawerItem(
              icon: Icons.favorite,
              title: 'Saved Rides',
              onTap: () {
                showMessage(
                  'Saved Rides screen will be added here.',
                );
              },
            ),

            buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                showMessage(
                  'Settings screen will be added here.',
                );
              },
            ),

            const Spacer(),

            const Divider(),

            buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: logout,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem({
    required IconData icon,
    required String title,
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
          Future.delayed(
            const Duration(milliseconds: 150),
            onTap,
          );
        }
      },
    );
  }
}