import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'main_screen.dart';
import 'signup_business_details_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool initialSignUp;

  const LoginScreen({super.key, this.initialSignUp = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _isSignUp;

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Sign up controllers
  final _signUpNameController = TextEditingController();
  final _signUpBusinessNameController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();

  final _authService = AuthService();

  bool _obscureLoginPassword = true;
  bool _obscureSignUpPassword = true;
  bool _obscureSignUpConfirmPassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialSignUp;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpBusinessNameController.dispose();
    _signUpPhoneController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
        ),
      ),
    );
  }

  void _navigatePostAuth() {
    try {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  Future<void> _handleSignIn() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter both email and password.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(email: email, password: password);
      if (!mounted) return;

      _showSnackBar(
        "Welcome back, ${user.name.isNotEmpty ? user.name : 'User'}!",
        isError: false,
      );

      if (user.businessName.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignupBusinessDetailsScreen(
              initialEmail: user.email,
              initialName: user.name,
              initialPhone: user.phone,
            ),
          ),
        );
      } else {
        _navigatePostAuth();
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AuthService.formatAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    final name = _signUpNameController.text.trim();
    final business = _signUpBusinessNameController.text.trim();
    final phone = _signUpPhoneController.text.trim();
    final email = _signUpEmailController.text.trim();
    final password = _signUpPasswordController.text;
    final confirmPassword = _signUpConfirmPasswordController.text;

    if (name.isEmpty) {
      _showSnackBar("Please enter your full name.", isError: true);
      return;
    }
    if (business.isEmpty) {
      _showSnackBar("Please enter your business or firm name.", isError: true);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar("Please enter a valid email address.", isError: true);
      return;
    }
    if (password.length < 6) {
      _showSnackBar("Password should be at least 6 characters.", isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.register(
        name: name,
        businessName: business,
        email: email,
        password: password,
        phone: phone.isNotEmpty ? phone : null,
      );

      if (!mounted) return;

      _showSnackBar(
        "Account created! Welcome to FlowSync, ${user.name}!",
        isError: false,
      );

      if (user.businessName.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignupBusinessDetailsScreen(
              initialEmail: user.email,
              initialName: user.name,
              initialPhone: user.phone,
            ),
          ),
        );
      } else {
        _navigatePostAuth();
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AuthService.formatAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _isGoogleLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (!mounted) return;
      if (userCredential == null) {
        return;
      }

      final email = userCredential.user?.email ?? '';
      _showSnackBar("Google authorization successful.", isError: false);

      final cachedUser = await _authService.getCachedUser();
      if (cachedUser == null || cachedUser.businessName.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignupBusinessDetailsScreen(
              initialEmail: email,
              initialName: userCredential.user?.displayName ?? '',
              initialPhone: userCredential.user?.phoneNumber ?? '',
            ),
          ),
        );
      } else {
        _navigatePostAuth();
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AuthService.formatAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController =
        TextEditingController(text: _loginEmailController.text.trim());
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
          ),
          title: Row(
            children: const [
              Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your registered email address to receive a secure password reset link.",
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  hintText: "e.g. user@flowsync.in",
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: AppColors.scaffoldBackground,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDecorations.inputRadius),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isResetting ? null : () => Navigator.pop(dialogCtx),
              child: const Text("Cancel",
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDecorations.buttonRadius),
                ),
              ),
              onPressed: isResetting
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        _showSnackBar("Please enter a valid email address.",
                            isError: true);
                        return;
                      }

                      setDialogState(() => isResetting = true);

                      try {
                        await _authService.sendPasswordResetEmail(email);
                        if (!mounted) return;
                        Navigator.pop(dialogCtx);
                        _showSnackBar(
                          "Password reset link sent to your email.",
                          isError: false,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        setDialogState(() => isResetting = false);
                        _showSnackBar(AuthService.formatAuthError(e),
                            isError: true);
                      }
                    },
              child: isResetting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Send Reset Link",
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF2563EB),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  Widget _buildFieldTitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildSliderToggle() {
    return Container(
      width: 220,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfWidth = (constraints.maxWidth - 8) / 2;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment:
                    _isSignUp ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: halfWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _isSignUp = false),
                      child: Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: !_isSignUp
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _isSignUp = true),
                      child: Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _isSignUp
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGoogleButton({required bool isSignUp}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _handleGoogleAuth,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2563EB),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    "https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg",
                    height: 20,
                    width: 20,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 26,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isSignUp ? "Sign up with Google" : "Sign in with Google",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "OR",
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle("Email_id"),
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hint: "Enter your email",
            prefixIcon: Icons.mail_rounded,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldTitle("Password"),
        TextField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
          decoration: _inputDecoration(
            hint: "Enter your password",
            prefixIcon: Icons.lock_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscureLoginPassword = !_obscureLoginPassword);
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text(
              "Forgot Password?",
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        _buildOrDivider(),
        const SizedBox(height: 16),
        _buildGoogleButton(isSignUp: false),
        
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle("Full Name"),
        TextField(
          controller: _signUpNameController,
          decoration: _inputDecoration(
            hint: "Enter your full name",
            prefixIcon: Icons.person_rounded,
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldTitle("Business / Firm Name"),
        TextField(
          controller: _signUpBusinessNameController,
          decoration: _inputDecoration(
            hint: "e.g. Royal Sanitary Stores",
            prefixIcon: Icons.storefront_rounded,
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldTitle("Contact Phone Number"),
        TextField(
          controller: _signUpPhoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(
            hint: "e.g. +91 98765 43210",
            prefixIcon: Icons.phone_rounded,
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldTitle("Email Address"),
        TextField(
          controller: _signUpEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hint: "Enter your email address",
            prefixIcon: Icons.mail_rounded,
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldTitle("Password"),
        TextField(
          controller: _signUpPasswordController,
          obscureText: _obscureSignUpPassword,
          decoration: _inputDecoration(
            hint: "Create a password (min 6 characters)",
            prefixIcon: Icons.lock_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignUpPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: () {
                setState(
                    () => _obscureSignUpPassword = !_obscureSignUpPassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldTitle("Confirm Password"),
        TextField(
          controller: _signUpConfirmPasswordController,
          obscureText: _obscureSignUpConfirmPassword,
          decoration: _inputDecoration(
            hint: "Re-enter your password",
            prefixIcon: Icons.lock_clock_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignUpConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscureSignUpConfirmPassword =
                    !_obscureSignUpConfirmPassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        _buildOrDivider(),
        const SizedBox(height: 16),
        _buildGoogleButton(isSignUp: true),
       
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          Container(color: const Color(0xFFF7F9FC)),

          Positioned(
            top: -275,
            left: -260,
            child: Container(
              width: 600,
              height: 400,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEF5),
                shape: BoxShape.circle,
              ),
            ),
          ),

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
                alignment: Alignment.center,
                children: [
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
                            Color(0xFFE8EEF5),
                            Color(0xFFE8EEF5),
                            Color(0xFFF7F9FC),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 35,
                    top: 30,
                    child: Image.asset(
                      "lib/assets/images/storage.png",
                      height: 280,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                  Positioned(
                    right: 110,
                    bottom: 10,
                    child: Image.asset(
                      "lib/assets/images/cammode.png",
                      height: 120,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    bottom: 50,
                    child: Image.asset(
                      "lib/assets/images/washbasin.png",
                      height: 190,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    bottom: 0,
                    child: Image.asset(
                      "lib/assets/images/pipes.png",
                      height: 210,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignUp ? "Get Started!" : "Welcome Back!",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp
                          ? "Register to manage your\nsanitary business"
                          : "Login to manage your\nsanitary business",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                  top: 270, left: 20, right: 20, bottom: 30),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
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
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Sync",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Smart Business. Smooth Flow.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                       const SizedBox(height: 20),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          firstCurve: Curves.easeInOut,
                          secondCurve: Curves.easeInOut,
                          crossFadeState: _isSignUp
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: _buildLoginForm(),
                          secondChild: _buildSignUpForm(),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                  
                              SizedBox(height: 4),
                              Text(
                                "Your data is safe and secure with us",
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.verified_user_rounded,
                                color: Color(0xFF2563EB),
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildSliderToggle(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}