import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../features/home/screens/home_screen.dart';
import '../login/login_screen.dart';

class SignupScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const SignupScreen({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptTerms = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!acceptTerms) {
      _showMessage(
        "Please accept the Terms & Conditions.",
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    User? createdUser;

    try {
      final UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      createdUser = userCredential.user;

      if (createdUser == null) {
        throw FirebaseAuthException(
          code: "user-not-created",
          message: "Firebase could not create the user.",
        );
      }

      await createdUser.updateDisplayName(nameController.text.trim());

      await _firestore.collection("users").doc(createdUser.uid).set({
        "uid": createdUser.uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "photoUrl": "",
        "role": "user",
        "authProvider": "email",
        "profileCompleted": false,
        "termsAccepted": true,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showMessage("Account created successfully.");

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            themeMode: widget.themeMode,
            toggleTheme: widget.toggleTheme,
          ),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      _showMessage(
        _getFirebaseAuthMessage(error),
        isError: true,
      );
    } on FirebaseException catch (error) {
      // If authentication succeeded but Firestore failed,
      // remove the newly created account to avoid incomplete users.
      try {
        await createdUser?.delete();
      } catch (_) {}

      _showMessage(
        error.message ?? "Unable to save your account details.",
        isError: true,
      );
    } catch (error) {
      _showMessage(
        "Something went wrong. Please try again.",
        isError: true,
      );
      debugPrint("Signup error: $error");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getFirebaseAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case "email-already-in-use":
        return "An account already exists with this email.";

      case "invalid-email":
        return "Please enter a valid email address.";

      case "weak-password":
        return "Please use a stronger password.";

      case "operation-not-allowed":
        return "Email/password signup is not enabled in Firebase.";

      case "network-request-failed":
        return "Check your internet connection and try again.";

      case "too-many-requests":
        return "Too many attempts. Please try again later.";

      default:
        return error.message ?? "Account creation failed.";
    }
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration inputDecoration(
      String hint,
      IconData icon, {
        Widget? suffixIcon,
      }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(
        icon,
        color: Colors.white,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white12,
      errorStyle: const TextStyle(
        color: Color(0xFFFFCDD2),
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed:
                      isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 50,
                      color: Color(0xFF203A43),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Join RideMate and start sharing rides",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: nameController,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      "Full Name",
                      Icons.person_outline,
                    ),
                    validator: (value) {
                      final name = value?.trim() ?? "";

                      if (name.isEmpty) {
                        return "Enter your full name";
                      }

                      if (name.length < 3) {
                        return "Name must contain at least 3 characters";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: emailController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      "Email Address",
                      Icons.email_outlined,
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? "";

                      if (email.isEmpty) {
                        return "Enter your email";
                      }

                      final emailPattern = RegExp(
                        r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$",
                      );

                      if (!emailPattern.hasMatch(email)) {
                        return "Enter a valid email address";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: phoneController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      "10-digit Phone Number",
                      Icons.phone_outlined,
                    ).copyWith(
                      counterText: "",
                    ),
                    validator: (value) {
                      final phone = value?.trim() ?? "";

                      if (phone.isEmpty) {
                        return "Enter your phone number";
                      }

                      if (!RegExp(r"^[6-9]\d{9}$").hasMatch(phone)) {
                        return "Enter a valid Indian phone number";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: passwordController,
                    enabled: !isLoading,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      "Password",
                      Icons.lock_outline,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    validator: (value) {
                      final password = value ?? "";

                      if (password.isEmpty) {
                        return "Enter your password";
                      }

                      if (password.length < 6) {
                        return "Password must contain at least 6 characters";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: confirmPasswordController,
                    enabled: !isLoading,
                    obscureText: obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    onFieldSubmitted: (_) {
                      if (!isLoading) {
                        signUp();
                      }
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      "Confirm Password",
                      Icons.lock_reset_outlined,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword =
                            !obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm your password";
                      }

                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: acceptTerms,
                    enabled: !isLoading,
                    activeColor: Colors.white,
                    checkColor: const Color(0xFF203A43),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) {
                      setState(() {
                        acceptTerms = value ?? false;
                      });
                    },
                    title: const Text(
                      "I accept the Terms & Conditions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF203A43),
                        disabledBackgroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF203A43),
                        ),
                      )
                          : const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(
                                themeMode: widget.themeMode,
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}