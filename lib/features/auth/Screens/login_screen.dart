import 'package:flutter/material.dart';
import 'package:gasis_final/features/auth/Screens/register_screen.dart';



class LoginScreen extends StatefulWidget {
  static String pageRouteName= "Login";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isCustomer = true;

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

  /// BASIC INPUT SANITIZATION
  String sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>{};]'), '');
  }

  void login() {

    final email = sanitize(emailController.text.trim());
    final password = sanitize(passwordController.text.trim());

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

    setState(() {
      errorMessage = null;
    });

    /// continue login process
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    var themes  = Theme.of(context).colorScheme;
    return Scaffold(
      body:

      SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  const SizedBox(height: 40),

                  /// GASIS LOGO (ADAPTIVE)
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double size = constraints.maxWidth * 0.22;
                        size = size.clamp(70, 110);

                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: themes.primary,
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
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Welcome to GASIS",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// CUSTOMER / TECHNICIAN SWITCH
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isCustomer = true;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCustomer
                                    ? themes.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "Customer",
                                  style: TextStyle(
                                    color: isCustomer ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isCustomer = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: !isCustomer
                                    ? themes.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "Technician",
                                  style: TextStyle(
                                    color: !isCustomer ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ERROR MESSAGE PLACEHOLDER
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
                        style:  TextStyle(
                          color: themes.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  /// EMAIL FIELD
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text("Email"),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
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

                  /// PASSWORD FIELD
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text("Password"),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
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

                  const SizedBox(height: 30),

                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: login,
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// SIGN UP LINE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text("Don't have an account? "),

                      GestureDetector(
                        onTap: () {
                         Navigator.pushReplacementNamed(context, RegisterScreen.pageRouteName);
                          /// Navigate to signup screen
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: themes.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}