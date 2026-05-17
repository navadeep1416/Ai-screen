import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_theme.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  int _currentStep = 0;
  bool _overlayGranted = false;
  bool _screenGranted = false;
  bool _notificationsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.systemAlertWindow.status;
    setState(() {
      _overlayGranted = status.isGranted;
    });
  }

  Future<void> _requestOverlayPermission() async {
    await Permission.systemAlertWindow.request();
    final status = await Permission.systemAlertWindow.status;
    setState(() {
      _overlayGranted = status.isGranted;
      if (_overlayGranted && _currentStep == 0) {
        _currentStep = 1;
      }
    });
  }

  Future<void> _requestScreenPermission() async {
    if (!_overlayGranted) return;

    if (Platform.isAndroid) {
      await Permission.ignoreBatteryOptimizations.request();
      final mediaStatus = await Permission.videos.request();
      final status = await Permission.systemAlertWindow.request();

      setState(() {
        _screenGranted = mediaStatus.isGranted || status.isGranted;
        if (_screenGranted && _currentStep == 1) {
          _currentStep = 2;
        }
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (!_screenGranted) return;

    await Permission.notification.request();
    final status = await Permission.notification.status;
    setState(() {
      _notificationsGranted = status.isGranted;
      if (_notificationsGranted && _currentStep == 2) {
        _currentStep = 3;
      }
    });
  }

  bool get _allPermissionsGranted =>
      _overlayGranted && _screenGranted && _notificationsGranted;

  void _navigateToHome() {
    if (_allPermissionsGranted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFDDE3EB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Setup Permissions',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFDDE3EB),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInstructions(),
                  const SizedBox(height: 32),
                  _buildPermissionCards(),
                ],
              ),
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Overlay', _currentStep >= 0),
              _buildStepLabel('Screen', _currentStep >= 1),
              _buildStepLabel('Notify', _currentStep >= 2),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: _currentStep >= 0 ? AppColors.primaryGradient : null,
                    color: _currentStep == 0 ? null : const Color(0xFF1E1035),
                    boxShadow: _currentStep >= 0
                        ? [
                            BoxShadow(
                              color: const Color(0xFFD946EF).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: _currentStep >= 1 ? AppColors.primaryGradient : null,
                    color: _currentStep <= 0 ? const Color(0xFF1E1035) : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: _currentStep >= 2 ? AppColors.primaryGradient : null,
                    color: _currentStep <= 1 ? const Color(0xFF1E1035) : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, bool isActive) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        color: isActive ? const Color(0xFFFBABFF) : const Color(0xFFD6C0D3),
      ),
    );
  }

  Widget _buildInstructions() {
    return const Text(
      'NAVA requires specific system access to analyze on-screen content and deliver real-time AI insights seamlessly.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: Color(0xFFD6C0D3),
        height: 1.5,
      ),
    );
  }

  Widget _buildPermissionCards() {
    return Column(
      children: [
        _buildOverlayCard(),
        const SizedBox(height: 16),
        _buildScreenCard(),
        const SizedBox(height: 16),
        _buildNotificationCard(),
      ],
    );
  }

  Widget _buildOverlayCard() {
    final isUnlocked = true;
    final isGranted = _overlayGranted;

    return GestureDetector(
      onTap: isUnlocked && !isGranted ? _requestOverlayPermission : null,
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF11091E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGranted ? AppColors.accentGreen : const Color(0xFF2A1A4A),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isGranted
                      ? const LinearGradient(
                          colors: [AppColors.accentGreen, Color(0xFF059669)],
                        )
                      : AppColors.primaryGradient,
                  boxShadow: isGranted
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFFD946EF).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 0,
                          ),
                        ],
                ),
                child: Icon(
                  isGranted ? Icons.check : Icons.layers,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Draw Over Apps',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFDDE3EB),
                          ),
                        ),
                        _buildStatusBadge(isGranted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Allows NAVA to display AI insights directly on top of your active applications.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFFD6C0D3),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGranted ? 'Granted' : 'Tap to Enable',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: isGranted
                            ? AppColors.accentGreen
                            : const Color(0xFFD946EF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenCard() {
    final isUnlocked = _overlayGranted;
    final isGranted = _screenGranted;

    return GestureDetector(
      onTap: isUnlocked && !isGranted ? _requestScreenPermission : null,
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF11091E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGranted ? AppColors.accentGreen : const Color(0xFF2A1A4A),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1035),
                  border: Border.all(
                    color: isGranted ? AppColors.accentGreen : const Color(0xFF2A1A4A),
                  ),
                ),
                child: Icon(
                  isGranted ? Icons.check : Icons.monitor,
                  color: isGranted ? AppColors.accentGreen : const Color(0xFFD6C0D3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Screen Reading',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFDDE3EB),
                          ),
                        ),
                        _buildStatusBadge(isGranted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Necessary to capture and analyze the content currently visible on your display.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFFD6C0D3),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGranted ? 'Granted' : (isUnlocked ? 'Tap to Enable' : 'Locked'),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: isGranted
                            ? AppColors.accentGreen
                            : const Color(0xFF9F8B9D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    final isUnlocked = _screenGranted;
    final isGranted = _notificationsGranted;

    return GestureDetector(
      onTap: isUnlocked && !isGranted ? _requestNotificationPermission : null,
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF11091E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGranted ? AppColors.accentGreen : const Color(0xFF2A1A4A),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1035),
                  border: Border.all(
                    color: isGranted ? AppColors.accentGreen : const Color(0xFF2A1A4A),
                  ),
                ),
                child: Icon(
                  isGranted ? Icons.check : Icons.notifications,
                  color: isGranted ? AppColors.accentGreen : const Color(0xFFD6C0D3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFDDE3EB),
                          ),
                        ),
                        _buildStatusBadge(isGranted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keeps NAVA running in the background to ensure uninterrupted analysis.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFFD6C0D3),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGranted ? 'Granted' : (isUnlocked ? 'Tap to Enable' : 'Locked'),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: isGranted
                            ? AppColors.accentGreen
                            : const Color(0xFF9F8B9D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isGranted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isGranted
            ? AppColors.accentGreen.withOpacity(0.2)
            : const Color(0xFF1E1035),
        border: Border.all(
          color: isGranted ? AppColors.accentGreen : const Color(0xFF2A1A4A),
        ),
      ),
      child: Text(
        isGranted ? 'Granted' : 'Pending',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isGranted ? AppColors.accentGreen : const Color(0xFFD6C0D3),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A14),
        border: Border(
          top: BorderSide(
            color: Color(0xFF1E1035),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _allPermissionsGranted ? _navigateToHome : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
          ),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: _allPermissionsGranted ? AppColors.primaryGradient : null,
              color: _allPermissionsGranted ? null : const Color(0xFF1E1035),
              boxShadow: _allPermissionsGranted
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD946EF).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _allPermissionsGranted
                      ? Colors.white
                      : const Color(0xFFD6C0D3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}