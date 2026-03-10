import 'package:flutter/material.dart';

import 'login_screen.dart';


class RegisterScreen extends StatefulWidget {
  static String pageRouteName= "RegisterScreen";
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? errorMessage;

  /// EMAIL VALIDATION
  bool isValidEmail(String email) {
    final emailRegex =
    RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// STRONG PASSWORD
  bool isStrongPassword(String password) {
    final passwordRegex =
    RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  /// BASIC SANITIZATION
  String sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>{};]'), '');
  }

  void register() {

    final email = sanitize(emailController.text.trim());
    final password = sanitize(passwordController.text.trim());
    final confirmPassword = sanitize(confirmPasswordController.text.trim());

    if (!isValidEmail(email)) {
      setState(() {
        errorMessage = "Please enter a valid email address";
      });
      return;
    }

    if (!isStrongPassword(password)) {
      setState(() {
        errorMessage =
        "Password must contain upper, lower, number, symbol and be 8+ chars";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match";
      });
      return;
    }

    setState(() {
      errorMessage = null;
    });

    /// continue registration process
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    var Themes = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

                const SizedBox(height: 40),

                /// LOGO (Adaptive)
                LayoutBuilder(
                  builder: (context, constraints) {

                    double size = constraints.maxWidth * 0.22;
                    size = size.clamp(70, 110);

                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Themes.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: size * 0.45,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  "Create your GASIS account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),



                const SizedBox(height: 30),

                /// ERROR MESSAGE
                if (errorMessage != null)
                  Container(
                    width: width,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Themes.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                /// EMAIL
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email"),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "example@gmail.com",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Password"),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: "********",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// CONFIRM PASSWORD
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Confirm Password"),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: "********",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword =
                          !obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: register,
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// BACK TO LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text("Already have an account? "),

                    GestureDetector(
                      onTap: () {
                       Navigator.pushReplacementNamed(context, LoginScreen.pageRouteName);
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Themes.primary,
                          fontWeight: FontWeight.bold,
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
    );
  }
}