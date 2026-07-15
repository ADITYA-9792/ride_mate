import 'package:flutter/material.dart';
import '../fogot_password/forgot_password_screen.dart';
import '../signup/signup_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final _formKey = GlobalKey<FormState>();

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

bool obscurePassword = true;
bool rememberMe = false;
bool isLoading = false;

@override
void dispose() {
emailController.dispose();
passwordController.dispose();
super.dispose();
}

void login() {
if (!_formKey.currentState!.validate()) return;

setState(() {
isLoading = true;
});

Future.delayed(const Duration(seconds: 2), () {
if (!mounted) return;

setState(() {
isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Login successful (Demo)"),
),
);
});
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
vertical: 30,
),
child: Form(
key: _formKey,
child: Column(
children: [
const SizedBox(height: 40),

Container(
height: 90,
width: 90,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
),
child: const Icon(
Icons.directions_car,
size: 50,
color: Color(0xff203A43),
),
),

const SizedBox(height: 30),

const Text(
"Welcome Back 👋",
style: TextStyle(
color: Colors.white,
fontSize: 30,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

const Text(
"Login to continue your RideMate journey",
style: TextStyle(
color: Colors.white70,
fontSize: 15,
),
),

const SizedBox(height: 40),

TextFormField(
controller: emailController,
keyboardType: TextInputType.emailAddress,
style: const TextStyle(color: Colors.white),
decoration: InputDecoration(
hintText: "Email Address",
hintStyle: const TextStyle(color: Colors.white54),
prefixIcon: const Icon(
Icons.email_outlined,
color: Colors.white,
),
filled: true,
fillColor: Colors.white12,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
validator: (value) {
if (value == null || value.isEmpty) {
return "Enter your email";
}

if (!value.contains("@")) {
return "Enter a valid email";
}

return null;
},
),

const SizedBox(height: 20),

TextFormField(
controller: passwordController,
obscureText: obscurePassword,
style: const TextStyle(color: Colors.white),
decoration: InputDecoration(
hintText: "Password",
hintStyle: const TextStyle(color: Colors.white54),
prefixIcon: const Icon(
Icons.lock_outline,
color: Colors.white,
),
suffixIcon: IconButton(
onPressed: () {
setState(() {
obscurePassword = !obscurePassword;
});
},
icon: Icon(
obscurePassword
? Icons.visibility_off
: Icons.visibility,
color: Colors.white,
),
),
filled: true,
fillColor: Colors.white12,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
validator: (value) {
if (value == null || value.isEmpty) {
return "Enter your password";
}

if (value.length < 6) {
return "Password must contain at least 6 characters";
}

return null;
},
),

const SizedBox(height: 12),

Row(
children: [
Checkbox(
value: rememberMe,
activeColor: Colors.white,
checkColor: Colors.black,
onChanged: (value) {
setState(() {
rememberMe = value ?? false;
});
},
),
const Text(
"Remember Me",
style: TextStyle(color: Colors.white),
),
],
),

const SizedBox(height: 18),

SizedBox(
width: double.infinity,
height: 55,
child: ElevatedButton(
onPressed: isLoading ? null : login,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.white,
foregroundColor: const Color(0xff203A43),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
child: isLoading
? const SizedBox(
width: 22,
height: 22,
child: CircularProgressIndicator(
strokeWidth: 2.5,
),
)
: const Text(
"LOGIN",
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
),
),

// ========= PART 2 WILL START FROM HERE =========
const SizedBox(height: 25),

Row(
children: const [
Expanded(
child: Divider(color: Colors.white38),
),
Padding(
padding: EdgeInsets.symmetric(horizontal: 12),
child: Text(
"OR",
style: TextStyle(
color: Colors.white70,
fontWeight: FontWeight.w600,
),
),
),
Expanded(
child: Divider(color: Colors.white38),
),
],
),

const SizedBox(height: 25),

SizedBox(
width: double.infinity,
height: 55,
child: OutlinedButton.icon(
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Google Sign-In will be added later.",
),
),
);
},
icon: const Icon(
Icons.g_mobiledata,
size: 30,
color: Colors.white,
),
label: const Text(
"Continue with Google",
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.w600,
fontSize: 16,
),
),
style: OutlinedButton.styleFrom(
side: const BorderSide(color: Colors.white54),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
),
),

const SizedBox(height: 15),

SizedBox(
width: double.infinity,
height: 55,
child: OutlinedButton.icon(
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Phone Login will be added later.",
),
),
);
},
icon: const Icon(
Icons.phone_android,
color: Colors.white,
),
label: const Text(
"Continue with Phone",
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.w600,
fontSize: 16,
),
),
style: OutlinedButton.styleFrom(
side: const BorderSide(color: Colors.white54),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
),
),

const SizedBox(height: 20),

TextButton(
onPressed: () {
Navigator.push(
   context,
   MaterialPageRoute(
     builder: (_) => const ForgotPasswordScreen(),
   ),
 );
},
child: const Text(
"Forgot Password?",
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(height: 15),

Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
"Don't have an account?",
style: TextStyle(
color: Colors.white70,
),
),
TextButton(
onPressed: () {
Navigator.push(
   context,
    MaterialPageRoute(
    builder: (_) => const SignupScreen(),
   ),
 );
},
child: const Text(
"Sign Up",
style: TextStyle(
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
),
],
),

const SizedBox(height: 30),
],
),
),
),
),
),
);
}
}