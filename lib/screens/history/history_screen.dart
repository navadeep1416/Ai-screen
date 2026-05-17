import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  final List<String> _filterOptions = ['All', 'Love', 'Crush', 'Friend', 'Colleague'];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    final user = _auth.currentUser;
    if (user == null) return;

    Query query = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .orderBy('timestamp', descending: true);

    if (_selectedFilter != 'All') {
      query = query.where('mode', isEqualTo: _selectedFilter);
    }

    query.snapshots().listen((snapshot) {
      if (mounted) {
        setState(() {
          _sessions = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'contactName': data['contactName'] ?? 'Unknown',
              'avatarUrl': data['avatarUrl'],
              'mode': data['mode'] ?? 'Friend',
              'aiPreview': data['aiPreview'] ?? 'Analyzing conversation...',
              'matchPercent': data['matchPercent'] ?? 0,
              'energyLevel': data['energyLevel'] ?? 'Medium',
              'vibe': data['vibe'] ?? 'Neutral',
              'timestamp': data['timestamp'] as Timestamp?,
            };
          }).toList();
          _isLoading = false;
        });
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _isLoading = true;
    });
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryPink),
                    )
                  : _sessions.isEmpty
                      ? _buildEmptyState()
                      : _buildSessionsList(),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFFDDE3EB)),
                onPressed: () {},
              ),
              ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'NAVA SCREEN AI',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: NetworkImage('')),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('History', style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFDDE3EB))),
          IconButton(icon: const Icon(Icons.filter_list, color: Color(0xFFD6C0D3)), onPressed: _showSortSheet),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11091E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort by', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFDDE3EB))),
            const SizedBox(height: 16),
            _buildSortOption('Most Recent', true),
            _buildSortOption('Highest Match', false),
            _buildSortOption('Oldest First', false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, bool isSelected) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primaryPink : const Color(0xFFD6C0D3),
      ),
      title: Text(title, style: TextStyle(fontFamily: 'Inter', color: isSelected ? const Color(0xFFDDE3EB) : const Color(0xFFD6C0D3))),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Color(0xFFD6C0D3)),
          SizedBox(height: 16),
          Text('No sessions yet', style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Color(0xFFD6C0D3))),
          SizedBox(height: 8),
          Text('Start a conversation to see history', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF9F8B9D))),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _sessions.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildSessionCard(_sessions[index]),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final contactName = session['contactName'] ?? 'Unknown';
    final mode = session['mode'] ?? 'Friend';
    final aiPreview = session['aiPreview'] ?? 'Analyzing...';
    final matchPercent = session['matchPercent'] ?? 0;
    final energyLevel = session['energyLevel'] ?? 'Medium';
    final timestamp = session['timestamp'] as Timestamp?;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/session-detail', arguments: session['id']),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.glassCard(backgroundColor: const Color(0xFF11091E)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(contactName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(contactName, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFDDE3EB))),
                          Text(TimeUtils.formatDay(timestamp), style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFD6C0D3))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildModeBadge(mode),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(aiPreview, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFFD6C0D3), height: 1.4)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatPill(Icons.trending_up, '$matchPercent%', const Color(0xFFFBABFF)),
                const SizedBox(width: 8),
                _buildStatPill(Icons.bolt, energyLevel, const Color(0xFFA78BFA)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2F353C)),
      child: Center(
        child: Text(initial, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFFBABFF))),
      ),
    );
  }

  Widget _buildModeBadge(String mode) {
    final modeColors = {'Love': AppColors.primaryPink, 'Crush': AppColors.primaryPink, 'Friend': AppColors.primaryPurple};
    final color = modeColors[mode] ?? AppColors.primaryPurple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(mode.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.1, color: color)),
    );
  }

  Widget _buildStatPill(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF05050A), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(color: Color(0xFF0D0720), border: Border(top: BorderSide(color: Color(0xFF1E1035), width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', false, () => Navigator.pushReplacementNamed(context, '/home')),
          _buildNavItem(Icons.history, 'History', true, () {}),
          _buildNavItem(Icons.psychology, 'Brain', false, () => Navigator.pushNamed(context, '/brain')),
          _buildNavItem(Icons.settings, 'Settings', false, () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isActive ? const Color(0xFFFBABFF).withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? const Color(0xFFFBABFF) : const Color(0xFFD6C0D3), size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, color: isActive ? const Color(0xFFFBABFF) : const Color(0xFFD6C0D3))),
          ],
        ),
      ),
    );
  }
}