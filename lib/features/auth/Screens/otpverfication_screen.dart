import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationScreen extends StatefulWidget {
  static String pageRouteName= "OTP";
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {

  final TextEditingController codeController = TextEditingController();

  String? errorMessage;

  String sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>{};]'), '').trim();
  }

  void verifyCode() {

    final code = sanitize(codeController.text);

    if (code.isEmpty) {
      setState(() {
        errorMessage = "Please enter the verification code.";
      });
      return;
    }

    setState(() {
      errorMessage = null;
    });

    debugPrint("Code verified: $code");
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            children: [

              const SizedBox(height: 20),

              /// BACK BUTTON
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              const SizedBox(height: 10),

              /// LOGO
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: theme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 30),

              /// TITLE (CENTERED)
              const Text(
                "Email OTP Verification",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE (LIGHTER / SMALLER)
              const Text(
                "Enter the verification code we just sent to your email",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              /// ERROR MESSAGE (hidden by default)
              if (errorMessage != null)
                Container(
                  width: width,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: theme.error.withOpacity(.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: theme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              /// SINGLE INPUT BOX
              TextField(
                controller: codeController,
                textAlign: TextAlign.center,

                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[<>{};]')),
                ],

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),

                decoration: InputDecoration(
                  hintText: "Enter code",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// RESEND
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text(
                    "Didn't receive code? ",
                    style: TextStyle(color: Colors.grey),
                  ),

                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Resend",
                      style: TextStyle(
                        color: theme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// VERIFY BUTTON
              SizedBox(
                width: width,
                height: 55,
                child: ElevatedButton(
                  onPressed: verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}