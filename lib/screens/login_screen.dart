import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hasUpperCase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;
  bool hasMinLength = false;
  bool isLoading = false;

  void validatePassword(String password) {
    setState(() {
      hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
      hasDigit = RegExp(r'[0-9]').hasMatch(password);
      hasSpecialChar =
          RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
      hasMinLength = password.length >= 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: SingleChildScrollView(
  child: SizedBox(
    height: MediaQuery.of(context).size.height + 150,
    child: Stack(
      children: [
          // Background
          Container(color: const Color(0xFFF5F7FC)),

          // Large Back Curve
          Positioned(
            top: -275,
            left: -260,
            child: Container(
              width: 600,
              height: 400,
              decoration: const BoxDecoration(
                color: Color(0xFFDCE8FF),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Front Curve
          Positioned(
            top: -150,
            left: -180,
            child: Container(
              width: 400,
              height: 250,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 178, 195, 227),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 10,
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  SizedBox(
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circular Background
                        Positioned(
                          right: -325,
                          child: Container(
                            width: 800,
                            height: 220,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFD4E2FF),
                                  Color(0xFFE7EEFF),
                                  Color(0xFFF7FAFF),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Storage
                        Positioned(
                          right: 35,
                          top: 30,
                          child: Image.asset(
                            "lib/assets/images/storage.png",
                            height: 280,
                          ),
                        ),

                        // Chart

                        // Commode
                        Positioned(
                          right: 110,
                          bottom: 10,
                          child: Image.asset(
                            "lib/assets/images/cammode.png",
                            height: 120,
                          ),
                        ),

                        // Wash Basin
                        Positioned(
                          right: -20,
                          bottom: 50,
                          child: Image.asset(
                            "lib/assets/images/washbasin.png",
                            height: 190,
                          ),
                        ),

                        // Pipes
                        Positioned(
                          right: -30,
                          bottom: 0,
                          child: Image.asset(
                            "lib/assets/images/pipes.png",
                            height: 210,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

Positioned(
  top: 320,
  left: 20,
  right: 20,
  child: Container(
    padding: const EdgeInsets.only(
      top: 40,
      left: 24,
      right: 24,
      bottom: 24,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 20,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Flow",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "Sync",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 52, 102, 220),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1),
              Text(
                "Smart Business. Smooth Flow.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),

        Text(
          "Email_id",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Enter your email",
            prefixIcon: Icon(
              Icons.email,
              color: Color(0xFF2F80FF),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),

        SizedBox(height: 20),

        Text(
          "Password",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),

        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          onChanged: validatePassword,
          decoration: InputDecoration(
            hintText: "Enter your password",
            prefixIcon: Icon(
              Icons.lock,
              color: Color(0xFF2F80FF),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),

        SizedBox(height: 5),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text("Forgot Password?"),
          ),
        ),

        SizedBox(height: 10),

        SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    onPressed: isLoading
        ? null
        : () async {
            setState(() {
              isLoading = true;
            });

            try {
              await AuthService().login(
                email: emailController.text.trim(),
                password: passwordController.text,
              );

              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainScreen(),
                ),
              );
            } on DioException catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    e.response?.data["message"] ?? "Login Failed",
                  ),
                ),
              );
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                ),
              );
            } finally {
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            }
          },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2F80FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    child: isLoading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : const Text(
            "Login",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
  ),
),

        SizedBox(height: 15),

        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "OR",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),

        SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              );
            },
            icon: const SizedBox.shrink(),
            label: Text(
              "Register",
              style: TextStyle(
                color: Color(0xFF2F80FF),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Color(0xFF2F80FF),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),

if (MediaQuery.of(context).viewInsets.bottom == 0)
  Positioned(
    bottom: 175,
    left: 0,
    right: 0,
    child: Column(
      children: const [
        Icon(
          Icons.verified_user,
          color: Color(0xFF2F80FF),
          size: 20,
        ),
        SizedBox(height: 10),
        Text(
          "Your data is safe and secure with us",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      ],
    ),
  ),

Positioned(
  top: 230,
  left: MediaQuery.of(context).size.width / 2 - 55,
  child: Container(
    width: 130,
    height: 130,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 25,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(6),
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: Image.asset(
            "lib/assets/images/logo1.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
  ),
),

SafeArea(
  child: SingleChildScrollView(
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 60,
            left: 25,
            right: 25,
            bottom: 20,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Login to manage your\nsanitary business",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 7, 89, 219),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
)
        ],
    ),
  ),
),
    );

  }
}
  