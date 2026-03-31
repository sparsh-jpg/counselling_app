import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();

  int currentIndex = 0;

  final List<OnboardModel> pages = [
    OnboardModel(
      title: "Take Your First Step",
      subtitle:
          "Enter your JEE scores and preferences to get personalized guidance",
      icon: Icons.edit_note,
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    OnboardModel(
      title: "Choose Your Mentor",
      subtitle:
          "Smart predictions match you with the best colleges & branches",
      icon: Icons.analytics,
      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
    ),
    OnboardModel(
      title: "Connect With Mentors",
      subtitle:
          "Talk to real seniors from NITs, IITs & IIITs for authentic advice",
      icon: Icons.people_alt_rounded,
      colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
    ),
    OnboardModel(
      title: "Navigate Your Journey",
      subtitle:
          "Get continuous support through admissions and your entire first year",
      icon: Icons.rocket_launch,
      colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
    ),
  ];

  void next() {
    if (currentIndex == pages.length - 1) {
      Navigator.pushReplacementNamed(context, "/dashboard");
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    }
  }

  void previous() {
    _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// PAGE VIEW
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: pages[index].colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// Animated Icon
                      TweenAnimationBuilder(
                        tween: Tween(begin: 0.7, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder: (_, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Icon(
                          pages[index].icon,
                          size: 140,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 60),

                      /// Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          pages[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          pages[index].subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          /// DOTS + BUTTONS
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [

                /// DOT INDICATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == i ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [

                      /// Previous
                      if (currentIndex != 0)
                        TextButton(
                          onPressed: previous,
                          child: const Text("Back",
                              style: TextStyle(color: Colors.white)),
                        ),

                      const Spacer(),

                      /// Next / Get Started
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: next,
                        child: Text(
                          currentIndex == pages.length - 1
                              ? "Get Started"
                              : "Next",
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// MODEL
class OnboardModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  OnboardModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}
