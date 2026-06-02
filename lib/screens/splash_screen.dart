import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      body: SafeArea(
        child: Stack(
          children: [

            // Top Pattern
            Positioned(
              top: -80,
              left: -80,
              right: -80,
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),

            // Bottom Wave
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE8EEFF),
                      Color(0xFFF5F7FF),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),

                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      // Logo
                      Image.asset(
                        "lib/assets/images/flowsync_logo.png",
                        height: 120,
                      ),

                      const SizedBox(height: 12),

                      // App Name
                      RichText(
                        text: const TextSpan(
                          children: [

                            TextSpan(
                              text: "Flow",
                              style: TextStyle(
                                color:
                                    Color(0xFF002B8F),
                                fontSize: 42,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            TextSpan(
                              text: "Sync",
                              style: TextStyle(
                                color:
                                    Color(0xFF2F80FF),
                                fontSize: 42,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2F80FF,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Manage your sanitary business\nsmarter, faster, better.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.4,
                          color: Color(0xFF70788C),
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Illustration
                      Image.asset(
                        "lib/assets/images/splash_illustration.png",
                        height: 260,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 40),

                      const SizedBox(
                        width: 40,
                        height: 40,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(
                            0xFF2F80FF,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Loading...",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(
                            0xFF2F80FF,
                          ),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}