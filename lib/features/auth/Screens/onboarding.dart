import 'package:flutter/material.dart';

import 'login_screen.dart';


class OnboardingScreen extends StatefulWidget {
  static String pageRouteName= "onboarding";
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController pageController = PageController();

  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "lib/assets/onboarding/onboarding1.png",
      "title": "Welcome to GASIS",
      "description": "Manage your gas services quickly and safely."
    },
    {
      "image": "lib/assets/onboarding/onboarding2.png",
      "title": "Track Your Services",
      "description": "Request maintenance, inspections, and track technicians."
    },
    {
      "image": "lib/assets/onboarding/onboarding3.png",
      "title": "Emergency Support",
      "description": "Report gas emergencies instantly with location sharing."
    },
  ];

  void nextPage() {
    if (currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            /// SKIP BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, LoginScreen.pageRouteName);
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: theme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            /// PAGE VIEW
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {

                  final page = pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        /// IMAGE
                        SizedBox(
                          height: size.height * 0.35,
                          child: Image.asset(
                            page["image"]!,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 40),

                        /// TITLE
                        Text(
                          page["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// DESCRIPTION
                        Text(
                          page["description"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// DOT INDICATORS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 8,
                  width: currentPage == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? theme.primary
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// NEXT / GET STARTED BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {

                    if (currentPage == pages.length - 1) {
                      Navigator.pushReplacementNamed(context, LoginScreen.pageRouteName);
                    } else {
                      nextPage();
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    currentPage == pages.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }
}