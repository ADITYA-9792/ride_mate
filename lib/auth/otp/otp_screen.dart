import 'dart:async';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
final List<TextEditingController> _controllers =
List.generate(6, (_) => TextEditingController());

final List<FocusNode> _focusNodes =
List.generate(6, (_) => FocusNode());

Timer? _timer;
int _seconds = 60;
bool _canResend = false;

@override
void initState() {
super.initState();
_startTimer();
}

void _startTimer() {
_timer?.cancel();

setState(() {
_seconds = 60;
_canResend = false;
});

_timer = Timer.periodic(
const Duration(seconds: 1),
(timer) {
if (_seconds > 0) {
setState(() {
_seconds--;
});
} else {
timer.cancel();

setState(() {
_canResend = true;
});
}
},
);
}

String get otp =>
_controllers.map((e) => e.text).join();

void _verifyOtp() {
if (otp.length != 6) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Please enter all 6 digits."),
),
);
return;
}

debugPrint("Entered OTP: $otp");

// TODO:
// Firebase OTP Verification
// Navigate to Reset Password / Home
}

@override
void dispose() {
_timer?.cancel();

for (final c in _controllers) {
c.dispose();
}

for (final f in _focusNodes) {
f.dispose();
}

super.dispose();
}

Widget _otpBox(int index) {
return SizedBox(
width: 48,
child: TextField(
controller: _controllers[index],
focusNode: _focusNodes[index],
keyboardType: TextInputType.number,
textAlign: TextAlign.center,
maxLength: 1,
style: const TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
fontSize: 22,
),
decoration: InputDecoration(
counterText: "",
filled: true,
fillColor: Colors.white12,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: BorderSide.none,
),
),
onChanged: (value) {
if (value.isNotEmpty && index < 5) {
FocusScope.of(context)
.requestFocus(_focusNodes[index + 1]);
}

if (value.isEmpty && index > 0) {
FocusScope.of(context)
.requestFocus(_focusNodes[index - 1]);
}
},
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
vertical: 20,
),
child: Column(
children: [
Align(
alignment: Alignment.centerLeft,
child: IconButton(
onPressed: () => Navigator.pop(context),
icon: const Icon(
Icons.arrow_back_ios,
color: Colors.white,
),
),
),

const SizedBox(height: 20),

Container(
height: 90,
width: 90,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(25),
),
child: const Icon(
Icons.lock_clock,
color: Color(0xff203A43),
size: 45,
),
),

const SizedBox(height: 25),

const Text(
"Verify OTP",
style: TextStyle(
color: Colors.white,
fontSize: 30,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

Text(
"Enter the 6-digit code sent to\n${widget.phoneNumber}",
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.white70,
fontSize: 16,
),
),

const SizedBox(height: 40),

Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: List.generate(
6,
(index) => _otpBox(index),
),
),

const SizedBox(height: 35),
  Text(
    "00:${_seconds.toString().padLeft(2, '0')}",
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 15),

  TextButton(
    onPressed: _canResend
        ? () {
      for (final c in _controllers) {
        c.clear();
      }

      FocusScope.of(context)
          .requestFocus(_focusNodes[0]);

      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP Sent Again"),
        ),
      );
    }
        : null,
    child: Text(
      "Resend OTP",
      style: TextStyle(
        color: _canResend
            ? Colors.white
            : Colors.white38,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  const SizedBox(height: 40),

  SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: _verifyOtp,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor:
        const Color(0xff203A43),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
      ),
      child: const Text(
        "VERIFY OTP",
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),

  const SizedBox(height: 20),
],
),
),
),
),
);
}
}