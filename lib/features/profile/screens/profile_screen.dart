import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/profile_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryColor = Color(0xFF5B4CF0);

  final ProfileService _profileService = ProfileService();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'Please log in to view your profile.',
        );
      }

      UserModel? user = await _profileService.getProfile();

      if (user == null) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          vehicle: '',
          licenseNumber: '',
          bio: '',
          photoUrl: firebaseUser.photoURL ?? '',
          createdAt: DateTime.now(),
        );

        await _profileService.createProfile(newUser);
        user = newUser;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            error.message ?? 'Unable to load your profile information.';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Something went wrong while loading your profile.';
        _isLoading = false;
      });
    }
  }

  String _displayValue(String? value, String fallback) {
    final cleanedValue = value?.trim() ?? '';

    if (cleanedValue.isEmpty) {
      return fallback;
    }

    return cleanedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 70,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final user = _user;

    if (user == null) {
      return const Center(
        child: Text('Profile not found.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 22),
            _buildInformationCard(user),
            const SizedBox(height: 22),
            _buildStatisticsSection(),
            const SizedBox(height: 24),
            _buildEditProfileButton(),
            const SizedBox(height: 12),
            _buildRideHistoryButton(),
            const SizedBox(height: 12),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    final hasPhoto = user.photoUrl.trim().isNotEmpty;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 57,
            backgroundColor: Colors.grey.shade300,
            backgroundImage:
            hasPhoto ? NetworkImage(user.photoUrl.trim()) : null,
            child: hasPhoto
                ? null
                : const Icon(
              Icons.person,
              size: 70,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _displayValue(user.name, 'No Name Added'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _displayValue(user.email, 'Email not available'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard(UserModel user) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _buildInformationTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            value: _displayValue(user.phone, 'Not added'),
          ),
          const Divider(height: 1),
          _buildInformationTile(
            icon: Icons.directions_car_outlined,
            title: 'Vehicle',
            value: _displayValue(user.vehicle, 'Not added'),
          ),
          const Divider(height: 1),
          _buildInformationTile(
            icon: Icons.badge_outlined,
            title: 'License Number',
            value: _displayValue(user.licenseNumber, 'Not added'),
          ),
          const Divider(height: 1),
          _buildInformationTile(
            icon: Icons.info_outline,
            title: 'Bio',
            value: _displayValue(user.bio, 'No bio added'),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 6,
      ),
      leading: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: primaryColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        _buildStatCard(
          number: '0',
          title: 'Offered',
          icon: Icons.add_road,
        ),
        _buildStatCard(
          number: '0',
          title: 'Booked',
          icon: Icons.event_seat_outlined,
        ),
        _buildStatCard(
          number: '0',
          title: 'Completed',
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String number,
    required String title,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 1,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 5,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () async {
          final user = _user;

          if (user == null) {
            return;
          }

          final wasUpdated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                user: user,
              ),
            ),
          );

          if (!mounted) {
            return;
          }

          if (wasUpdated == true) {
            await _loadProfile();
          }
        },
        icon: const Icon(Icons.edit_outlined),
        label: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildRideHistoryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ride History screen is not connected yet.',
              ),
            ),
          );
        },
        icon: const Icon(Icons.history),
        label: const Text(
          'Ride History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(
            color: primaryColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) {
        return;
      }

      Navigator.of(context).popUntil(
            (route) => route.isFirst,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Unable to logout.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong during logout.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
