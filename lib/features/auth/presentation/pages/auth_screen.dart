import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignIn = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailAuth(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (_isSignIn) {
      context.read<AuthBloc>().add(
            SignInWithEmailEvent(email: email, password: password),
          );
    } else {
      context.read<AuthBloc>().add(
            SignUpWithEmailEvent(email: email, password: password, name: name),
          );
    }
  }

  void _handleGoogleAuth(BuildContext context) {
    context.read<AuthBloc>().add(SignInWithGoogleEvent());
  }

  String _getBubbleText(bool isLoading) {
    if (isLoading) {
      return "Connecting to the vault... 🤫";
    }
    if (_isSignIn) {
      return "Welcome back, chief! Ready to save some coins?";
    } else {
      return "Join me and let's level up your savings! 🚀";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: isLight ? AppColors.bgLight : AppColors.bgDark,
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is AuthSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Authentication successful! 🎉'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoadingEmail = state is AuthLoading && !state.isGoogle;
              final isLoadingGoogle = state is AuthLoading && state.isGoogle;
              final anyLoading = state is AuthLoading;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Speech Bubble and Mascot
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SpeechBubble(text: _getBubbleText(anyLoading)),
                          const SizedBox(height: 18),
                          const FloatingMascot(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title Header
                    Text(
                      'FINGO',
                      style: AppTextStyles.display1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _isSignIn ? 'Sign in to track your wealth' : 'Create an account to start quests',
                      style: AppTextStyles.bodySM.copyWith(
                        color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // Tab Switcher
                    AuthTabSwitcher(
                      isSignIn: _isSignIn,
                      onChanged: (val) {
                        if (anyLoading) return;
                        setState(() {
                          _isSignIn = val;
                          _formKey.currentState?.reset();
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Form Fields
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_isSignIn) ...[
                            AppTextField(
                              controller: _nameController,
                              label: 'Username',
                              hint: 'Mithil',
                              prefixIcon: Icons.person_outline_rounded,
                              textInputAction: TextInputAction.next,
                              enabled: !anyLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          AppTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'yourname@example.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            enabled: !anyLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppPasswordField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleEmailAuth(context),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    App3DButton(
                      label: _isSignIn ? 'LET\'S GO!' : 'CREATE ACCOUNT',
                      onTap: anyLoading ? null : () => _handleEmailAuth(context),
                      color: AppColors.primary,
                      shadowColor: AppColors.primaryDark,
                      loading: isLoadingEmail,
                    ),

                    const SizedBox(height: 20),

                    // Divider "OR"
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1.5,
                            color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: AppTextStyles.overline.copyWith(
                              color: isLight ? AppColors.textTertiaryLight : AppColors.textTertiaryDark,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1.5,
                            color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Google Login Button
                    Google3DButton(
                      onTap: anyLoading ? () {} : () => _handleGoogleAuth(context),
                      loading: isLoadingGoogle,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── HELPER WIDGETS ──────────────────────────────────────────────────────────

class FloatingMascot extends StatefulWidget {
  const FloatingMascot({super.key});

  @override
  State<FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<FloatingMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: child,
        );
      },
      child: Image.asset(
        'assets/fingo_mascot.png',
        height: 110,
        width: 110,
        fit: BoxFit.contain,
      ),
    );
  }
}

class SpeechBubble extends StatelessWidget {
  final String text;
  const SpeechBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
          width: AppSizes.borderThick,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.2),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text(
            text,
            style: AppTextStyles.labelMD.copyWith(
              color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          Positioned(
            bottom: -20,
            left: 24,
            child: CustomPaint(
              painter: BubbleTrianglePainter(
                color: isLight ? Colors.white : AppColors.surfaceElevatedDark,
                borderColor: isLight ? AppColors.outlineLight : AppColors.outlineDark,
              ),
              size: const Size(16, 10),
            ),
          ),
        ],
      ),
    );
  }
}

class BubbleTrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  BubbleTrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
    
    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthTabSwitcher extends StatelessWidget {
  final bool isSignIn;
  final ValueChanged<bool> onChanged;

  const AuthTabSwitcher({
    super.key,
    required this.isSignIn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final containerColor = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;
    final borderColor = isLight ? AppColors.outlineLight : AppColors.outlineDark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: borderColor, width: AppSizes.borderThick),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSignIn ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD - 2),
                ),
                child: Text(
                  'SIGN IN',
                  style: AppTextStyles.labelMD.copyWith(
                    color: isSignIn
                        ? Colors.white
                        : (isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isSignIn ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD - 2),
                ),
                child: Text(
                  'SIGN UP',
                  style: AppTextStyles.labelMD.copyWith(
                    color: !isSignIn
                        ? Colors.white
                        : (isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Google3DButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool loading;
  const Google3DButton({super.key, required this.onTap, this.loading = false});

  @override
  State<Google3DButton> createState() => _Google3DButtonState();
}

class _Google3DButtonState extends State<Google3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final buttonColor = isLight ? Colors.white : AppColors.surfaceDark;
    final shadowColor = isLight ? const Color(0xFFE5E5E5) : const Color(0xFF131F24);
    final borderColor = isLight ? AppColors.outlineLight : AppColors.outlineDark;
    const double height = 54.0;
    const double shadowHeight = 4.0;

    final Widget buttonBody = Stack(
      children: [
        // Bevel layer
        Container(
          height: height + shadowHeight,
          decoration: BoxDecoration(
            color: shadowColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: borderColor,
              width: AppSizes.borderThick,
            ),
          ),
        ),
        // Active top layer
        AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          margin: EdgeInsets.only(
            top: _isPressed ? shadowHeight : 0,
            bottom: _isPressed ? 0 : shadowHeight,
          ),
          height: height,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: borderColor,
              width: AppSizes.borderThick,
            ),
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CONTINUE WITH GOOGLE',
                      style: AppTextStyles.labelMD.copyWith(
                        color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CustomPaint(
                      size: const Size(22, 22),
                      painter: GoogleLogoPainter(),
                    ),
                  ],
                ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: !widget.loading ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: !widget.loading ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: !widget.loading ? () => setState(() => _isPressed = false) : null,
      onTap: !widget.loading ? widget.onTap : null,
      child: buttonBody,
    );
  }
}

/// [GoogleLogoPainter] — draws the official Google G multi-color SVG icon using vector math.
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // scale to viewBox 0 0 48 48
    final double scaleX = size.width / 48.0;
    final double scaleY = size.height / 48.0;
    canvas.scale(scaleX, scaleY);

    // Path 1 (Red)
    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final pathRed = Path()
      ..moveTo(24, 9.5)
      ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
      ..lineTo(40.06, 6.25)
      ..cubicTo(35.9, 2.38, 30.47, 0, 24, 0)
      ..cubicTo(14.62, 0, 6.51, 5.38, 2.56, 13.22)
      ..lineTo(10.54, 19.41)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24, 9.5)
      ..close();
    canvas.drawPath(pathRed, paintRed);

    // Path 2 (Blue)
    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final pathBlue = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.98, 46.83, 21.46, 46.6, 20.0)
      ..lineTo(24, 20.0)
      ..lineTo(24, 29.02)
      ..lineTo(36.94, 29.02)
      ..cubicTo(36.36, 31.98, 34.68, 34.5, 32.16, 36.2)
      ..lineTo(39.89, 42.2)
      ..cubicTo(44.4, 38.02, 46.98, 31.84, 46.98, 24.55)
      ..close();
    canvas.drawPath(pathBlue, paintBlue);

    // Path 3 (Yellow)
    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final pathYellow = Path()
      ..moveTo(10.53, 28.59)
      ..cubicTo(10.05, 27.14, 9.77, 25.6, 9.77, 24.0)
      ..cubicTo(9.77, 22.4, 10.05, 20.86, 10.53, 19.41)
      ..lineTo(2.55, 13.22)
      ..cubicTo(0.92, 16.46, 0, 20.12, 0, 24.0)
      ..cubicTo(0, 27.88, 0.92, 31.54, 2.56, 34.78)
      ..lineTo(10.53, 28.59)
      ..close();
    canvas.drawPath(pathYellow, paintYellow);

    // Path 4 (Green)
    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final pathGreen = Path()
      ..moveTo(24, 48.0)
      ..cubicTo(30.48, 48.0, 35.93, 45.87, 39.89, 42.19)
      ..lineTo(32.16, 36.19)
      ..cubicTo(30.01, 37.64, 27.24, 38.49, 24.0, 38.49)
      ..cubicTo(17.74, 38.49, 12.43, 34.27, 10.53, 28.58)
      ..lineTo(2.55, 34.77)
      ..cubicTo(6.51, 42.62, 14.62, 48.0, 24, 48.0)
      ..close();
    canvas.drawPath(pathGreen, paintGreen);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
