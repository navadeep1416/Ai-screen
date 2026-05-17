import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../overlay/overlay_service.dart';
import '../../services/api_service.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = 'User';
  int _todaySessions = 0;
  String _topMode = 'Crush';
  int _accuracy = 0;
  List<Map<String, dynamic>> _recentSessions = [];
  bool _isOverlayActive = false;

  StreamSubscription? _userSubscription;
  StreamSubscription? _sessionsSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _auth.currentUser;
    if (user == null) return;

    _userSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data()!;
        setState(() {
          _userName = data['name'] ?? 'User';
          _topMode = data['favMode'] ?? 'Crush';
          _todaySessions = data['totalSessions'] ?? 0;
          _accuracy = data['accuracy'] ?? 0;
        });
      }
    });

    _sessionsSubscription = _firestore
        .collection('sessions')
        .doc(user.uid)
        .collection('userSessions')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _recentSessions = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'name': data['sessionName'] ?? 'Chat',
              'timestamp': data['timestamp'] as Timestamp?,
              'mode': data['mode'] ?? 'Friend',
            };
          }).toList();
        });
      }
    });
  }

  Future<void> _launchOverlay() async {
    await OverlayService.startOverlay();
    setState(() {
      _isOverlayActive = true;
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _sessionsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeNote(),
                    const SizedBox(height: 24),
                    _buildHeroCard(),
                    const SizedBox(height: 24),
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.menu, color: Color(0xFFDDE3EB)),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'NAVA SCREEN AI',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFFDDE3EB)),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hey, $_userName 👋',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Color(0xFFDDE3EB),
            letterSpacing: -0.02,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.glassCard(
        backgroundColor: const Color(0xFF11091E),
        borderColor: AppColors.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF242B31),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF524251)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ready to activate',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD6C0D3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Activate Nava AI',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDDE3EB),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFBABFF),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Launch the AI assistant to analyze your screen, provide real-time suggestions, and boost your daily workflow.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Color(0xFFD6C0D3),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _launchOverlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
              ),
              child: Container(
                height: 48,
                decoration: AppDecorations.neonButton(),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🚀 Launch Popup',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // TEST BUTTON FOR API CONNECTIVITY
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                try {
                  debugPrint('--- TESTING BACKEND CONNECTION ---');
                  final api = ApiService();
                  final res = await api.analyzeChat(chatText: 'Hey, how are you?');
                  debugPrint('API Response: $res');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('API Success: ${res['analysis']?['detectedMode']}')),
                  );
                } catch (e) {
                  debugPrint('API Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('API Error: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF242B31),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                '🧪 Test Backend API',
                style: TextStyle(
                  color: Color(0xFFDDE3EB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final modeEmoji = _getModeEmoji(_topMode);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Today', '$_todaySessions', 'Sessions'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Top Mode', '$modeEmoji', _topMode, isEmoji: true),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Accuracy', '$_accuracy%', '', showTrend: true),
        ),
      ],
    );
  }

  String _getModeEmoji(String mode) {
    const modeEmojis = {
      'Love': '❤️',
      'OneSide': '🥺',
      'Friend': '😂',
      'Fight': '⚔️',
      'Enemy': '😤',
      'Stranger': '👋',
      'Male Friend': '🤜',
      'Female Frnd': '💅',
      'Crush': '💖',
      'Best Friend': '🔥',
      'Bestie': '👑',
    };
    return modeEmojis[mode] ?? '💬';
  }

  Widget _buildStatCard(
    String label,
    String value,
    String suffix, {
    bool isEmoji = false,
    bool showTrend = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassCard(
        backgroundColor: const Color(0xFF11091E),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05,
              color: Color(0xFFD6C0D3),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isEmoji ? 28 : 32,
                  fontWeight: FontWeight.w700,
                  color: isEmoji ? const Color(0xFFFBABFF) : const Color(0xFFDDE3EB),
                ),
              ),
              if (suffix.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  suffix,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Color(0xFFD6C0D3),
                  ),
                ),
              ],
              if (showTrend) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.trending_up,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.05,
            color: Color(0xFFD6C0D3),
          ),
        ),
        const SizedBox(height: 16),
        if (_recentSessions.isEmpty)
          _buildEmptySession()
        else
          ...(_recentSessions.asMap().entries.map((entry) {
            final index = entry.key;
            final session = entry.value;
            return Column(
              children: [
                _buildSessionRow(
                  session['name'] ?? 'Chat',
                  TimeUtils.getTimeAgo(session['timestamp']),
                  session['mode'] ?? 'Friend',
                ),
                if (index < _recentSessions.length - 1) const SizedBox(height: 12),
              ],
            );
          })),
      ],
    );
  }

  Widget _buildEmptySession() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassCard(
        backgroundColor: const Color(0xFF11091E),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.chat, color: Color(0xFFFBABFF)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No recent sessions',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDDE3EB),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Launch popup to start',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFFD6C0D3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionRow(String name, String timeAgo, String mode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF11091E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF242B31),
            ),
            child: const Icon(Icons.chat, color: Color(0xFFFBABFF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDDE3EB),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFFD6C0D3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF242B31),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF524251)),
            ),
            child: Text(
              mode,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDDE3EB),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFFD6C0D3),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0720),
        border: Border(top: BorderSide(color: Color(0xFF1E1035), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', true, () {}),
          _buildNavItem(Icons.history, 'History', false, () {
            Navigator.pushNamed(context, '/history');
          }),
          _buildNavItem(Icons.psychology, 'Brain', false, () {
            Navigator.pushNamed(context, '/brain');
          }),
          _buildNavItem(Icons.settings, 'Settings', false, () {
            Navigator.pushNamed(context, '/settings');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFBABFF).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? const Color(0xFFFBABFF) : const Color(0xFFD6C0D3), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFFFBABFF) : const Color(0xFFD6C0D3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}