import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/login_state.dart';

final supabase = Supabase.instance.client;

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());
  void togglePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleAuthStep() {
    state = state.copyWith(
      step: state.step == AuthStep.login ? AuthStep.signup : AuthStep.login,
      error: null,
    );
  }

  Future<void> login(
    String email,
    String password,
    VoidCallback onsuccess,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await supabase.auth.signInWithPassword(email: email, password: password);
      state = state.copyWith(isLoading: false);
      onsuccess();
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final identities = response.user?.identities;
      if (identities != null && identities.isEmpty) {
        // Email already belongs to a confirmed account
        state = state.copyWith(
          isLoading: false,
          error:
              'An account with this email already exists. Please log in instead.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        step: AuthStep.otp,
        email: email,
      );
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOTP(String otp, VoidCallback onsuccess) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await supabase.auth.verifyOTP(
        email: state.email,
        token: otp,
        type: OtpType.email,
      );
      state = state.copyWith(isLoading: false);
      onsuccess();
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resendOtp() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await supabase.auth.resend(type: OtpType.signup, email: state.email);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      print('❌ Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (_) => LoginNotifier(),
);
