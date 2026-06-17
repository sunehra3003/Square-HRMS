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
      await supabase.auth.signUp(email: email, password: password);
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
      await supabase.auth.resend(type: OtpType.email, email: state.email);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (_) => LoginNotifier(),
);
