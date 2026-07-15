import 'package:flutter/material.dart';

import '../login/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

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

  void signUp() {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept Terms & Conditions"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    });
  }

  InputDecoration inputDecoration(
      String hint,
      IconData icon,
      ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white12,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff0F2027),
              Color(0xff203A43),
              Color(0xff2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 25,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 15),

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
                      color: Color(0xff203A43),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Join RideMate today",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                    inputDecoration("Full Name", Icons.person),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your name";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                    inputDecoration("Email", Icons.email),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter email";
                      }

                      if (!value.contains("@")) {
                        return "Enter valid email";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                    inputDecoration("Phone Number", Icons.phone),
                    validator: (value) {
                      if (value == null || value.length != 10) {
                        return "Enter valid phone";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      "Password",
                      Icons.lock,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "Minimum 6 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      "Confirm Password",
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword =
                            !obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  CheckboxListTile(
                    value: acceptTerms,
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    title: const Text(
                      "I accept Terms & Conditions",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setState(() {
                        acceptTerms = value!;
                      });
                    },
                    controlAffinity:
                    ListTileControlAffinity.leading,
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                        const Color(0xff203A43),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const LoginScreen(),
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
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}