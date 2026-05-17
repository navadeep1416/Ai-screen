import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = "Loading...";
  String _avatarUrl = "";
  int _totalSessions = 0;
  int _totalReplies = 0;
  String _favMode = "Crush 💖";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() { _name = "Guest User"; _isLoading = false; });
      return;
    }

    _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _name = data['name'] ?? user.displayName ?? "User";
          _avatarUrl = data['avatarUrl'] ?? user.photoURL ?? "";
          _totalSessions = data['totalSessions'] ?? 0;
          _totalReplies = data['totalReplies'] ?? 0;
          _favMode = data['favMode'] ?? "Crush 💖";
          _isLoading = false;
        });
      }
    });
  }

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: _name);
    final photoUrlController = TextEditingController(text: _avatarUrl);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11091E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Profile", style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFDDE3EB))),
            const SizedBox(height: 20),
            TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Name", labelStyle: const TextStyle(color: Color(0xFF9F8B9D)), enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primaryPink), borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: photoUrlController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Photo URL", labelStyle: const TextStyle(color: Color(0xFF9F8B9D)), enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primaryPink), borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  final user = _auth.currentUser;
                  if (user != null) await _firestore.collection('users').doc(user.uid).set({'name': nameController.text.trim(), 'avatarUrl': photoUrlController.text.trim()}, SetOptions(merge: true));
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Save Changes", style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/splash');
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Column(children: [
                  _buildProfileHeaderBento(),
                  const SizedBox(height: 32),
                  _buildAccountMenu(),
                ]),
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
      decoration: BoxDecoration(color: AppColors.background.withOpacity(0.8), boxShadow: [BoxShadow(color: const Color(0xFFFBABFF).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.menu, color: Color(0xFFDDE3EB)), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(width: 16),
              const Text('NAVA SCREEN AI', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFBABFF), letterSpacing: -0.5)),
            ],
          ),
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF2F353C), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF524251))), child: const Icon(Icons.person, color: Color(0xFFD6C0D3))),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderBento() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 768;
        return isDesktop
            ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(flex: 1, child: _buildAvatarCard()), const SizedBox(width: 16), Expanded(flex: 2, child: _buildStatsRow())])
            : Column(children: [_buildAvatarCard(), const SizedBox(height: 16), _buildStatsRow()]);
      },
    );
  }

  Widget _buildAvatarCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.glassCard(backgroundColor: const Color(0xFF11091E), borderColor: AppColors.border),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFFFBABFF).withOpacity(0.1), Colors.transparent])))),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient, boxShadow: [BoxShadow(color: AppColors.primaryPink.withOpacity(0.4), blurRadius: 15)]),
                child: CircleAvatar(backgroundColor: const Color(0xFF11091E), backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null),
              ),
              const SizedBox(height: 12),
              Text(_isLoading ? "Loading..." : _name, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFDDE3EB))),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF2F353C).withOpacity(0.5), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)), child: const Text("Open Source User 🔓", style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFBABFF)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(icon: Icons.analytics, iconColor: const Color(0xFF9B7FED), value: _isLoading ? "-" : _totalSessions.toString(), label: "Analyzed")),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(icon: Icons.forum, iconColor: const Color(0xFFFBABFF), value: _isLoading ? "-" : _totalReplies.toString(), label: "Replies")),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(icon: Icons.favorite, iconColor: const Color(0xFFFFB4AB), value: _isLoading ? "-" : _favMode, label: "Fav Mode", hasGlow: true)),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required Color iconColor, required String value, required String label, bool hasGlow = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassCard(backgroundColor: const Color(0xFF11091E)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasGlow) Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [const Color(0xFFFBABFF).withOpacity(0.1), Colors.transparent])))),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 28, shadows: hasGlow ? [Shadow(color: iconColor.withOpacity(0.5), blurRadius: 8)] : null),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFDDE3EB)), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD6C0D3))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("ACCOUNT", style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFFD6C0D3)))),
        const SizedBox(height: 16),
        Container(
          decoration: AppDecorations.glassCard(backgroundColor: const Color(0xFF11091E)),
          child: Column(
            children: [
              _buildMenuItem(icon: Icons.edit, title: "Edit Profile", onTap: _showEditProfileSheet),
              Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
              _buildMenuItem(icon: Icons.notifications, title: "Notifications", onTap: () => Navigator.pushNamed(context, '/settings')),
              Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
              _buildMenuItem(icon: Icons.help_outline, title: "Help & Support", onTap: () => _launchUrl('https://navascreen.ai/support')),
              Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
              _buildMenuItem(icon: Icons.code, title: "GitHub Integration", onTap: () => _launchUrl('https://github.com'), iconColor: Colors.white),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFA78BFA)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            onPressed: _logout,
            child: const Text("Log Out", style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF9B7FED))),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF2F353C).withOpacity(0.5), shape: BoxShape.circle), child: Icon(icon, color: iconColor ?? const Color(0xFFFBABFF), size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFFDDE3EB)))),
            const Icon(Icons.chevron_right, color: Color(0xFFD6C0D3)),
          ],
        ),
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
          _buildNavItem(Icons.history, 'History', false, () => Navigator.pushReplacementNamed(context, '/history')),
          _buildNavItem(Icons.psychology, 'Brain', false, () => Navigator.pushNamed(context, '/brain')),
          _buildNavItem(Icons.settings, 'Settings', true, () {}),
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