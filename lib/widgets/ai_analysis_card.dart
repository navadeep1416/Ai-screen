import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// AI Analysis card widget
class AIAnalysisCard extends StatelessWidget {
  final String detectedMode;
  final int matchPercent;
  final int interestLevel;
  final List<String> emotions;
  final List<String> insights;
  final String aiAdvice;

  const AIAnalysisCard({
    super.key,
    required this.detectedMode,
    required this.matchPercent,
    required this.interestLevel,
    required this.emotions,
    required this.insights,
    required this.aiAdvice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildModeDisplay(),
          const SizedBox(height: 16),
          _buildInterestLevel(),
          const SizedBox(height: 16),
          _buildInsights(),
          const Spacer(),
          _buildAdvice(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'HER BRAIN ANALYSIS',
          style: TextStyle(
            color: AppColors.primaryPurple,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Icon(Icons.refresh, color: Colors.white54, size: 16),
        ),
      ],
    );
  }

  Widget _buildModeDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detected Mode',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              detectedMode,
              style: const TextStyle(
                color: AppColors.primaryPink,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '$matchPercent%',
              style: const TextStyle(
                color: AppColors.primaryPink,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInterestLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interest Level',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: interestLevel / 100.0,
          backgroundColor: AppColors.border,
          color: AppColors.primaryPink,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conversation Insight',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.white)),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAdvice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.accentYellow, size: 16),
              const SizedBox(width: 8),
              const Text(
                'AI Advice',
                style: TextStyle(
                  color: AppColors.accentYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            aiAdvice,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}