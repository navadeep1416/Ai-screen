import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _defaultMode = 'Balanced';
  String _replyStyle = 'Concise';
  String _language = 'English';
  String _popupSize = 'Medium';
  bool _edgeSnapping = true;
  bool _autoMinimize = false;
  String _popupPosition = 'Bottom Right';
  bool _saveHistory = true;
  int _autoClearDays = 30;
  String _accentColor = '#8b5cf6';
  bool _isLoading = true;

  final List<String> _modeOptions = ['Balanced', 'Love', 'Crush', 'Friend', 'Fight', 'Enemy'];
  final List<String> _replyStyleOptions = ['Concise', 'Detailed', 'Emoji', 'Formal'];
  final List<String> _languageOptions = ['English', 'Hindi', 'Telugu', 'Tamil'];
  final List<String> _sizeOptions = ['Small', 'Medium', 'Large'];
  final List<String> _positionOptions = ['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right', 'Center'];
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Pink', 'value': '#ec4899'},
    {'name': 'Purple', 'value': '#8b5cf6'},
    {'name': 'Cyan', 'value': '#06b6d4'},
    {'name': 'Green', 'value': '#10b981'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('settings').doc(user.uid).get();
    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _defaultMode = data['defaultMode'] ?? 'Balanced';
        _replyStyle = data['replyStyle'] ?? 'Concise';
        _language = data['language'] ?? 'English';
        _popupSize = data['popupSize'] ?? 'Medium';
        _edgeSnapping = data['edgeSnapping'] ?? true;
        _autoMinimize = data['autoMinimize'] ?? false;
        _popupPosition = data['popupPosition'] ?? 'Bottom Right';
        _saveHistory = data['saveHistory'] ?? true;
        _autoClearDays = data['autoClearDays'] ?? 30;
        _accentColor = data['accentColor'] ?? '#8b5cf6';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('settings').doc(user.uid).set({key: value}, SetOptions(merge: true));
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
      );
    }

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
                    const Text('Settings', style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFDDE3EB))),
                    const SizedBox(height: 32),
                    _buildAISection(),
                    const SizedBox(height: 32),
                    _buildPopupSection(),
                    const SizedBox(height: 32),
                    _buildPrivacySection(),
                    const SizedBox(height: 32),
                    _buildAppearanceSection(),
                    const SizedBox(height: 32),
                    _buildAboutSection(),
                    const SizedBox(height: 24),
                    _buildSignOutButton(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.menu, color: Color(0xFFD6C0D3)), onPressed: () {}),
              ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                child: const Text('NAVA SCREEN AI', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
          Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF524251).withOpacity(0.5))), child: const CircleAvatar(backgroundColor: Colors.transparent)),
        ],
      ),
    );
  }

  Widget _buildGlassCard(List<Widget> children) {
    return Container(
      decoration: AppDecorations.glassCard(),
      child: Column(
        children: children
            .asMap()
            .entries
            .map((entry) => Column(children: [
                  entry.value,
                  if (entry.key < children.length - 1) Divider(height: 1, color: const Color(0xFF524251).withOpacity(0.3)),
                ]))
            .toList(),
      ),
    );
  }

  Widget _buildAISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI PREFERENCES', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Color(0xFFCEBDFF))),
        const SizedBox(height: 16),
        _buildGlassCard([
          _buildSettingRow(Icons.tune, 'Default Mode', _defaultMode, () => _showDropdown('defaultMode', _modeOptions, _defaultMode)),
          _buildSettingRow(Icons.forum, 'Reply Style', _replyStyle, () => _showDropdown('replyStyle', _replyStyleOptions, _replyStyle)),
          _buildSettingRow(Icons.language, 'Language', _language, () => _showDropdown('language', _languageOptions, _language)),
        ]),
      ],
    );
  }

  Widget _buildPopupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('POPUP BEHAVIOR', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Color(0xFFCEBDFF))),
        const SizedBox(height: 16),
        _buildGlassCard([
          _buildSettingRow(Icons.aspect_ratio, 'Size', _popupSize, () => _showDropdown('popupSize', _sizeOptions, _popupSize)),
          _buildToggleRow(Icons.drag_indicator, 'Edge Snapping', _edgeSnapping, (value) { setState(() => _edgeSnapping = value); _saveSetting('edgeSnapping', value); }),
          _buildToggleRow(Icons.close_fullscreen, 'Auto-minimize', _autoMinimize, (value) { setState(() => _autoMinimize = value); _saveSetting('autoMinimize', value); }),
          _buildSettingRow(Icons.picture_in_picture, 'Position', _popupPosition, () => _showDropdown('popupPosition', _positionOptions, _popupPosition)),
        ]),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRIVACY', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Color(0xFFCEBDFF))),
        const SizedBox(height: 16),
        _buildGlassCard([
          _buildToggleRow(Icons.history_toggle_off, 'Save History', _saveHistory, (value) { setState(() => _saveHistory = value); _saveSetting('saveHistory', value); }),
          _buildSettingRow(Icons.auto_delete, 'Auto-clear', '$_autoClearDays Days', () => _showDaysDropdown()),
        ]),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('APPEARANCE', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Color(0xFFCEBDFF))),
        const SizedBox(height: 16),
        _buildGlassCard([
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF2F353C), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.palette, color: Color(0xFFFBABFF), size: 20)),
                    const SizedBox(width: 16),
                    const Text('Accent Color', style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFFDDE3EB))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _colorOptions.map((color) {
                    final isSelected = _accentColor == color['value'];
                    return GestureDetector(
                      onTap: () { setState(() => _accentColor = color['value']); _saveSetting('accentColor', color['value']); },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(ValidationUtils.parseHexColor(color['value'])),
                          border: Border.all(color: isSelected ? const Color(0xFFDDE3EB) : const Color(0xFF524251).withOpacity(0.5), width: isSelected ? 2 : 1),
                          boxShadow: isSelected ? [BoxShadow(color: Color(ValidationUtils.parseHexColor(color['value'])).withOpacity(0.4), blurRadius: 15)] : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ABOUT', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Color(0xFFCEBDFF))),
        const SizedBox(height: 16),
        _buildGlassCard([
          _buildSettingRow(Icons.help, 'Help & Support', null, () {}, showArrow: true),
          _buildSettingRow(Icons.code, 'GitHub Repository', null, () {}, showArrow: true),
          _buildSettingRow(Icons.system_update, 'Version', 'v2.4.1', () {}),
        ]),
      ],
    );
  }

  Widget _buildSettingRow(IconData icon, String label, String? value, VoidCallback onTap, {bool showArrow = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF2F353C).withOpacity(0.5), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFFFBABFF), size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFFDDE3EB)))),
            if (value != null) Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFFD6C0D3))),
            if (showArrow) const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFD6C0D3)) else if (value != null) const Icon(Icons.chevron_right, size: 20, color: Color(0xFFD6C0D3)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(IconData icon, String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF2F353C).withOpacity(0.5), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF9B7FED), size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFFDDE3EB)))),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFFBABFF), activeTrackColor: const Color(0xFFFBABFF).withOpacity(0.5), inactiveThumbColor: const Color(0xFFD6C0D3), inactiveTrackColor: const Color(0xFF2F353C)),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _signOut,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, side: const BorderSide(color: Color(0xFFFFB4AB)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        icon: const Icon(Icons.logout, color: Color(0xFFFFB4AB)),
        label: const Text('Sign Out', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFFB4AB))),
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

  void _showDropdown(String key, List<String> options, String currentValue) {
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
            Text('Select ${key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')}', style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFDDE3EB))),
            const SizedBox(height: 16),
            ...options.map((option) => ListTile(
                  leading: Icon(option == currentValue ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: option == currentValue ? AppColors.primaryPink : const Color(0xFFD6C0D3)),
                  title: Text(option, style: TextStyle(fontFamily: 'Inter', color: option == currentValue ? const Color(0xFFDDE3EB) : const Color(0xFFD6C0D3))),
                  onTap: () {
                    setState(() {
                      switch (key) {
                        case 'defaultMode': _defaultMode = option; break;
                        case 'replyStyle': _replyStyle = option; break;
                        case 'language': _language = option; break;
                        case 'popupSize': _popupSize = option; break;
                        case 'popupPosition': _popupPosition = option; break;
                      }
                    });
                    _saveSetting(key, option);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDaysDropdown() {
    final daysOptions = [7, 14, 30, 60, 90];
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
            const Text('Auto-clear after', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFDDE3EB))),
            const SizedBox(height: 16),
            ...daysOptions.map((days) => ListTile(
                  leading: Icon(days == _autoClearDays ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: days == _autoClearDays ? AppColors.primaryPink : const Color(0xFFD6C0D3)),
                  title: Text('$days Days', style: TextStyle(fontFamily: 'Inter', color: days == _autoClearDays ? const Color(0xFFDDE3EB) : const Color(0xFFD6C0D3))),
                  onTap: () { setState(() => _autoClearDays = days); _saveSetting('autoClearDays', days); Navigator.pop(context); },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}