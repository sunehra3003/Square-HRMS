enum AuthStep { login, signup, otp }

class LoginState {
  final bool isLoading;
  final String? error;
  final bool obscurePassword;
  final AuthStep step;
  final String email;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.obscurePassword = true,
    this.step = AuthStep.login,
    this.email = '',
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? obscurePassword,
    AuthStep? step,
    String? email,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      step: step ?? this.step,
      email: email ?? this.email,
    );
  }
}
