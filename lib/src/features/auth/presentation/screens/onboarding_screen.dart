import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.errorKey,
  });

  final String? errorKey;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<_OnboardingItem> _items(BuildContext context) {
    return [
      _OnboardingItem(
        icon: Icons.home_repair_service,
        title: context.tr('onboardingTitle1'),
        description: context.tr('onboardingDesc1'),
      ),
      _OnboardingItem(
        icon: Icons.fact_check_outlined,
        title: context.tr('onboardingTitle2'),
        description: context.tr('onboardingDesc2'),
      ),
      _OnboardingItem(
        icon: Icons.location_on_outlined,
        title: context.tr('onboardingTitle3'),
        description: context.tr('onboardingDesc3'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (widget.errorKey != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    context.tr(widget.errorKey!),
                    style: TextStyle(color: theme.error),
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      AppRouter.route(const LoginScreen()),
                    );
                  },
                  child: Text(context.tr('skip')),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 62,
                          backgroundColor: theme.primary.withOpacity(0.12),
                          foregroundColor: theme.primary,
                          child: Icon(item.icon, size: 62),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _currentIndex == index ? 28 : 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? theme.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _currentIndex == items.length - 1
                    ? context.tr('getStarted')
                    : context.tr('next'),
                onPressed: () {
                  if (_currentIndex == items.length - 1) {
                    Navigator.of(context).push(
                      AppRouter.route(const LoginScreen()),
                    );
                    return;
                  }

                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    AppRouter.route(const RegisterScreen()),
                  );
                },
                child: Text(context.tr('register')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
