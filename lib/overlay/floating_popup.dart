import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'overlay_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/reply_card.dart';
import '../widgets/neon_button.dart';

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: FloatingPopup()));
}

class FloatingPopup extends StatefulWidget {
  const FloatingPopup({super.key});

  @override
  State<FloatingPopup> createState() => _FloatingPopupState();
}

class _FloatingPopupState extends State<FloatingPopup> {
  PopupSizeMode _currentSize = PopupSizeMode.medium;
  bool _isWatching = true;
  String _activeMode = 'Crush';
  String _ocrText = "Waiting for screen context...";
  Map<String, dynamic>? _latestAnalysis;
  String? _sessionId;

  final List<String> _modes = RelationshipMode.values.map((m) => m.name).toList();

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is Map) {
        setState(() {
          if (event['status'] == 'watching') _isWatching = true;
          if (event['status'] == 'stopped') _isWatching = false;
          if (event['mode'] != null) _activeMode = event['mode'];
          if (event['event'] == 'ocr_update') _ocrText = event['text'] ?? _ocrText;
          if (event['event'] == 'analysis_complete') {
            _sessionId = event['sessionId'];
            _latestAnalysis = event['data'];
            _ocrText = event['data']['ocrText'] ?? _ocrText;
          }
        });
      }
    });
  }

  void _setSize(PopupSizeMode size) {
    setState(() => _currentSize = size);
    FlutterOverlayWindow.resizeOverlay(-1, size.height.toInt(), 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSize == PopupSizeMode.minimised) return _buildMinimisedBubble();

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: AppDecorations.overlayContainer(),
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentSize == PopupSizeMode.large) _buildSidebar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusIndicator(),
                          const SizedBox(height: 16),
                          if (_currentSize == PopupSizeMode.large || _currentSize == PopupSizeMode.medium)
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: Column(children: [_buildContextPanel(), const SizedBox(height: 16), Expanded(child: _buildRepliesPanel())])),
                                  if (_currentSize == PopupSizeMode.large) ...[const SizedBox(width: 16), Expanded(flex: 2, child: _buildAnalysisPanel())],
                                ],
                              ),
                            ),
                          if (_currentSize == PopupSizeMode.small) Expanded(child: _buildSmallView()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildMinimisedBubble() {
    return GestureDetector(
      onTap: () => _setSize(PopupSizeMode.medium),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.primaryPurple),
          boxShadow: [BoxShadow(color: AppColors.primaryPink.withOpacity(0.4), blurRadius: 15)],
        ),
        child: const Icon(Icons.auto_awesome, color: AppColors.primaryPink),
      ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2.seconds),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primaryPink, size: 20),
              const SizedBox(width: 8),
              const Text("NAVA SCREEN AI", style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(border: Border.all(color: AppColors.primaryPurple), borderRadius: BorderRadius.circular(12)),
                child: const Text("PRO", style: TextStyle(color: AppColors.primaryPurple, fontSize: 10)),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove, color: Colors.white54), onPressed: () => _setSize(PopupSizeMode.minimised)),
              IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: OverlayService.closeOverlay),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 140,
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.border))),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _modes.length,
        itemBuilder: (context, index) {
          final mode = _modes[index];
          final isActive = mode == _activeMode;
          final modeEnum = RelationshipMode.fromString(mode);
          return InkWell(
            onTap: () => OverlayService.updateMode(mode),
            child: AnimatedGlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              accentColor: isActive ? AppColors.primaryPink : null,
              child: Text(
                '${modeEnum.emoji} $mode',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: AppColors.card,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isWatching ? AppColors.accentGreen : Colors.red,
            ),
          ).animate(onPlay: (c) => c.repeat()).fade(duration: 1.seconds),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isWatching ? "AI is watching the screen" : "AI is paused",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isWatching ? "Reading chats, stories & reels in real time" : "Tap Start to resume reading",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          NeonOutlineButton(
            text: _isWatching ? "Stop" : "Start",
            height: 32,
            borderColor: _isWatching ? Colors.red : AppColors.accentGreen,
            onPressed: () => _isWatching ? OverlayService.stopWatching() : OverlayService.startWatching(_activeMode),
          ),
        ],
      ),
    );
  }

  Widget _buildContextPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CURRENT CONTEXT", style: TextStyle(color: AppColors.primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Latest Message:", style: TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            _ocrText.isNotEmpty ? _ocrText : "No text detected yet...",
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesPanel() {
    final replies = _latestAnalysis?['replies'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("SUGGESTED REPLIES ($_activeMode Mode)", style: const TextStyle(color: AppColors.primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.auto_awesome, color: AppColors.primaryPink, size: 14),
          ],
        ),
        const SizedBox(height: 12),
        if (replies.isEmpty)
          const Expanded(
            child: Center(
              child: Text("Scanning for context to generate replies...", style: TextStyle(color: AppColors.textSecondary)),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: replies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reply = replies[index];
                return ReplyCard(
                  index: index + 1,
                  style: reply['style'] ?? 'Reply',
                  text: reply['text'] ?? '',
                  onSend: () {
                    if (_sessionId != null) OverlayService.selectReply(_sessionId!, reply['style']);
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: "Regenerate Replies",
            height: 40,
            onPressed: OverlayService.regenerateReplies,
            gradient: const LinearGradient(colors: [AppColors.primaryPurple, AppColors.primaryPink]),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisPanel() {
    final analysis = _latestAnalysis?['analysis'];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("HER BRAIN ANALYSIS", style: TextStyle(color: AppColors.primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)),
              Icon(Icons.refresh, color: Colors.white54, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Detected Mode", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Row(
            children: [
              Text(analysis?['detectedMode'] ?? _activeMode, style: const TextStyle(color: AppColors.primaryPink, fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("${analysis?['matchPercent'] ?? '--'}%", style: const TextStyle(color: AppColors.primaryPink, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Interest Level", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (analysis?['interestLevel'] ?? 0) / 100.0,
            backgroundColor: AppColors.border,
            color: AppColors.primaryPink,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          const Text("Conversation Insight", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          ...((analysis?['insights'] as List<dynamic>?) ?? ['Scanning for insights...']).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Colors.white)),
                    Expanded(child: Text(insight.toString(), style: const TextStyle(color: Colors.white, fontSize: 13))),
                  ],
                ),
              )),
          const Spacer(),
          GlassCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: AppColors.surface,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.accentYellow, size: 16),
                    SizedBox(width: 8),
                    Text("AI Advice", style: TextStyle(color: AppColors.accentYellow, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 4),
                Text("Interact to get advice.", style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallView() => Column(
        children: [
          _buildContextPanel(),
          const SizedBox(height: 12),
          const Text("3 replies ready", style: TextStyle(color: AppColors.primaryPurple)),
        ],
      );

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.minimize, color: AppColors.primaryPink), onPressed: () => _setSize(PopupSizeMode.minimised)),
          IconButton(
            icon: const Icon(Icons.aspect_ratio, color: AppColors.primaryPink),
            onPressed: () {
              if (_currentSize == PopupSizeMode.small) _setSize(PopupSizeMode.medium);
              else if (_currentSize == PopupSizeMode.medium) _setSize(PopupSizeMode.large);
              else _setSize(PopupSizeMode.small);
            },
          ),
          const Icon(Icons.drag_indicator, color: Colors.white30),
          const Text("Drag to move", style: TextStyle(color: Colors.white30, fontSize: 12)),
        ],
      ),
    );
  }
}
