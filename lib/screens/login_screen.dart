import 'package:flutter/material.dart';

import 'package:clg_admin/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    required this.onLoginSuccess,
  });

  final AuthService authService;
  final VoidCallback onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorText;
  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Small delay for UX feel
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final isValid = widget.authService.authenticate(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!isValid) {
      setState(() {
        _errorText = 'Invalid username or password. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Check your credentials.')),
      );
      return;
    }

    setState(() => _errorText = null);
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF3730A3), Color(0xFF4338CA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Decorative shapes
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo area
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                        blurRadius: 24,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'College Canteen',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Admin Portal',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          // Card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E1B4B).withValues(alpha: 0.25),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Welcome back',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sign in to manage your canteen',
                                    style: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        _buildField(
                                          controller: _usernameController,
                                          label: 'Username',
                                          hint: 'Enter your username',
                                          icon: Icons.person_rounded,
                                          action: TextInputAction.next,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return 'Username is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        _buildField(
                                          controller: _passwordController,
                                          label: 'Password',
                                          hint: 'Enter your password',
                                          icon: Icons.lock_rounded,
                                          obscure: _obscurePassword,
                                          action: TextInputAction.done,
                                          onFieldSubmitted: (_) => _submit(),
                                          suffix: IconButton(
                                            onPressed: () => setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            }),
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_rounded
                                                  : Icons.visibility_off_rounded,
                                              size: 20,
                                              color: cs.primary.withValues(alpha: 0.6),
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return 'Password is required';
                                            }
                                            if (v.trim().length < 6) {
                                              return 'Password must be at least 6 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_errorText != null) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFECACA)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_rounded,
                                            color: Color(0xFFEF4444),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorText!,
                                              style: const TextStyle(
                                                color: Color(0xFFDC2626),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  // Login button
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 52,
                                    child: FilledButton(
                                      onPressed: _isLoading ? null : _submit,
                                      style: FilledButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                                SizedBox(width: 8),
                                                Icon(Icons.arrow_forward_rounded, size: 18),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Demo credentials chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: cs.primary.withValues(alpha: 0.12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          size: 15,
                                          color: cs.primary.withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Demo credentials: ',
                                          style: TextStyle(
                                            color: cs.primary.withValues(alpha: 0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'admin / admin@123',
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputAction action = TextInputAction.next,
    Widget? suffix,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: cs.primary),
        ),
        suffixIcon: suffix,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w400),
      ),
      validator: validator,
    );
  }
}