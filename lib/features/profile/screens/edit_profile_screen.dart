import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color primaryColor = Color(0xFF5B4CF0);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _vehicleController;
  late final TextEditingController _licenseController;
  late final TextEditingController _bioController;

  String _photoUrl = '';

  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();

    _photoUrl = widget.user.photoUrl;

    _nameController = TextEditingController(
      text: widget.user.name,
    );

    _phoneController = TextEditingController(
      text: widget.user.phone,
    );

    _vehicleController = TextEditingController(
      text: widget.user.vehicle,
    );

    _licenseController = TextEditingController(
      text: widget.user.licenseNumber,
    );

    _bioController = TextEditingController(
      text: widget.user.bio,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _licenseController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  Future<void> _uploadProfilePhoto() async {
    if (_isUploadingPhoto || _isSaving) {
      return;
    }

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final String? uploadedUrl =
      await _profileService.uploadProfilePhoto();

      if (uploadedUrl == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _photoUrl = uploadedUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile photo uploaded successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Unable to upload profile photo.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong while uploading the photo.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    final bool isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid || _isSaving || _isUploadingPhoto) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final UserModel updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        vehicle: _vehicleController.text.trim(),
        licenseNumber:
        _licenseController.text.trim().toUpperCase(),
        bio: _bioController.text.trim(),
        photoUrl: _photoUrl,
      );

      await _profileService.updateProfile(updatedUser);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Unable to update profile.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong while updating the profile.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateName(String? value) {
    final String name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your name.';
    }

    if (name.length < 2) {
      return 'Name must contain at least 2 characters.';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final String phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return null;
    }

    final String cleanedPhone = phone.replaceAll(
      RegExp(r'[\s\-()]'),
      '',
    );

    if (!RegExp(r'^\+?[0-9]{10,13}$')
        .hasMatch(cleanedPhone)) {
      return 'Enter a valid phone number.';
    }

    return null;
  }

  String? _validateLicense(String? value) {
    final String license = value?.trim() ?? '';

    if (license.isEmpty) {
      return null;
    }

    if (license.length < 5) {
      return 'Enter a valid license number.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving && !_isUploadingPhoto,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfilePicture(),
                  const SizedBox(height: 28),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: _validateName,
                    textInputAction: TextInputAction.next,
                    textCapitalization:
                    TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  _buildReadOnlyEmailField(),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hintText: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _vehicleController,
                    label: 'Vehicle',
                    hintText: 'Example: Honda City',
                    icon: Icons.directions_car_outlined,
                    textInputAction: TextInputAction.next,
                    textCapitalization:
                    TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _licenseController,
                    label: 'License Number',
                    hintText: 'Example: UP32 20260012345',
                    icon: Icons.badge_outlined,
                    validator: _validateLicense,
                    textInputAction: TextInputAction.next,
                    textCapitalization:
                    TextCapitalization.characters,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _bioController,
                    label: 'Bio',
                    hintText:
                    'Write something about yourself',
                    icon: Icons.info_outline,
                    maxLines: 4,
                    maxLength: 150,
                    textInputAction: TextInputAction.done,
                    textCapitalization:
                    TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 28),

                  _buildSaveButton(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    final bool hasPhoto = _photoUrl.trim().isNotEmpty;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 58,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: hasPhoto
                    ? NetworkImage(_photoUrl.trim())
                    : null,
                child: hasPhoto
                    ? null
                    : const Icon(
                  Icons.person,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: _isUploadingPhoto
                  ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Upload profile photo',
                onPressed: _uploadProfilePhoto,
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  size: 21,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _isUploadingPhoto
              ? 'Uploading photo...'
              : 'Tap the camera icon to change photo',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyEmailField() {
    return TextFormField(
      initialValue: widget.user.email,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: primaryColor,
        ),
        suffixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: !_isSaving && !_isUploadingPhoto,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: primaryColor,
        ),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final bool isBusy =
        _isSaving || _isUploadingPhoto;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isBusy ? null : _saveProfile,
        icon: _isSaving
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.save_outlined),
        label: Text(
          _isSaving
              ? 'Saving...'
              : _isUploadingPhoto
              ? 'Uploading Photo...'
              : 'Save Changes',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          primaryColor.withValues(alpha: 0.60),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}