import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.45).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _progressController.repeat(reverse: true);

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();

      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('firstLaunch') ?? true;

      if (isFirstLaunch) {
        await prefs.setBool('firstLaunch', false);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      debugPrint('Auth error: $e');
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 8),
              _buildCenterHub(),
              _buildBottomLoading(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterHub() {
    return Expanded(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRadialGlow(),
                const SizedBox(height: 32),
                _buildAIcon(),
                const SizedBox(height: 24),
                _buildBrandIdentity(),
                const SizedBox(height: 16),
                _buildTagline(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadialGlow() {
    return Container(
      width: 300,
      height: 300,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0x33571BC1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildAIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE14EF6).withOpacity(0.3),
            const Color(0xFF571BC1).withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE14EF6).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => AppColors.purpleGradient.createShader(bounds),
          child: Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBrandIdentity() {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.purpleGradient.createShader(bounds),
      child: const Text(
        'NAVA SCREEN AI',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return const Text(
      'thinks like a friend, replies like you',
      textAlign: TextAlign.center,
      maxLines: 2,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: Color(0xFFD6C0D3),
        height: 1.5,
      ),
    );
  }

  Widget _buildBottomLoading() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              width: 180,
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF2F353C),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE14EF6).withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE14EF6).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'BY NAVADEEP',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
            color: Color(0xFF9F8B9D),
          ),
        ),
      ],
    );
  }
}