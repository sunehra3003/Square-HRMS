import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/Pages/main_page.dart';
import 'package:new_app/Pages/forgot_password_page.dart';
import 'package:new_app/Pages/profile_setup_page.dart';
import 'package:new_app/providers/login_provider.dart';
import 'package:new_app/models/login_state.dart';

const kNavy = Color(0xFF1B2E5E);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _goToMain() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainPage()),
  );
  void _goToProfileSetup() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
  );

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Image.asset('assets/image.png', width: 80, height: 80),
        const Text(
          'Square HRMS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kNavy,
          ),
        ),
        const Text('Welcome to Square'),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Full Name'),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter full name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email'),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordField(bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password'),
        const SizedBox(height: 8),
        TextField(
          controller: _passController,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.remove_red_eye_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: false,
                onChanged: (val) {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Remember me', style: TextStyle(fontSize: 13)),
          ],
        ),
        TextButton(
          onPressed: () => () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Forgot password?', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        error,
        style: const TextStyle(color: Colors.red, fontSize: 13),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading, VoidCallback onTap, String label) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: kNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
          : Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
    );
  }

  Widget _buildToggle(bool isLogin, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            children: [
              TextSpan(
                text: isLogin
                    ? "Don't have an account? "
                    : 'Already have an account? ',
              ),
              TextSpan(
                text: isLogin ? 'Sign Up' : 'Login',
                style: const TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard(LoginState state, LoginNotifier notifier) {
    final isLogin = state.step == AuthStep.login;

    return Card(
      margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLogin ? 'Login' : 'Sign up',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 16),
            if (!isLogin) _buildNameField(),
            _buildEmailField(),
            _buildPasswordField(state.obscurePassword, notifier.togglePassword),
            if (isLogin) ...[const SizedBox(height: 8), _buildRememberMeRow()],
            _buildErrorMessage(state.error),
            const SizedBox(height: 16),
            _buildSubmitButton(state.isLoading, () {
              if (isLogin) {
                notifier.login(
                  _emailController.text.trim(),
                  _passController.text.trim(),
                  _goToMain,
                );
              } else {
                notifier.signup(
                  _emailController.text.trim(),
                  _passController.text.trim(),
                );
              }
            }, isLogin ? "Login" : "signup"),
            const SizedBox(height: 12),
            _buildToggle(isLogin, notifier.toggleAuthStep),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCard(LoginState state, LoginNotifier notifier) {
    return Card(
      margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──────────────────────────────
            const Text(
              'Verify Email',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'OTP sent to ${state.email}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // ── OTP Field ──────────────────────────
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'Enter 6-digit OTP',
                prefixIcon: const Icon(Icons.lock_clock_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // ── Error ──────────────────────────────
            _buildErrorMessage(state.error),

            const SizedBox(height: 12),

            // ── Verify Button ───────────────────────
            _buildSubmitButton(
              state.isLoading,
              () => notifier.verifyOTP(
                _otpController.text.trim(),
                _goToProfileSetup, // ← goes to profile setup after OTP
              ),
              'Verify OTP',
            ),

            const SizedBox(height: 12),

            // ── Resend OTP ──────────────────────────
            Center(
              child: TextButton(
                onPressed: state.isLoading ? null : notifier.resendOtp,
                child: const Text('Resend OTP', style: TextStyle(color: kNavy)),
              ),
            ),

            // ── Back ────────────────────────────────
            Center(
              child: TextButton(
                onPressed: notifier.toggleAuthStep,
                child: const Text(
                  '← Back',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color.fromARGB(255, 189, 225, 252), Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header ─────────────────────────
                _buildHeader(),

                const SizedBox(height: 10),

                // ── Show OTP or Auth card ───────────
                if (state.step == AuthStep.otp)
                  _buildOtpCard(state, notifier)
                else
                  _buildAuthCard(state, notifier),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
