import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_assistant_message.dart';
import '../providers/ai_assistant_provider.dart';
import '../providers/air_quality_provider.dart';
import '../providers/household_provider.dart';
import '../providers/settings_provider.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedPrompts = [
    'How can my family stay safe during today\'s smog?',
    'Is it a good idea to take my children outdoors?',
    'How can I improve indoor air quality without spending too much?',
    'What should I change in my daily commute?',
    'What can elderly family members do during severe pollution?',
    'What are affordable alternatives to reduce household pollution?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? preset]) {
    final query = preset ?? _textController.text.trim();
    if (query.isEmpty) return;
    _textController.clear();
    ref.read(aiAssistantProvider.notifier).sendMessage(query);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantProvider);
    final aqiData = ref.watch(airQualityProvider).data;
    final household = ref.watch(householdProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: Column(
        children: [
          // Mandatory Health & Scope Disclaimer Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                Icon(Icons.health_and_safety_outlined, color: Colors.amber.shade900, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Environmental Protection Guidance Only — Not Medical Advice. ClearAir AI provides engineering and exposure recommendations. Never diagnose illness or alter prescription medication without a physician.',
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade900, height: 1.3),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(aiAssistantProvider.notifier).clearHistory(),
                  child: const Text('Clear Chat', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          // Active Context Header (Location, AQI, Household sensitivity)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Context: ${aqiData?.locationName ?? "Local"} (${aqiData?.aqi ?? 150} AQI, ${aqiData?.category.title ?? "Poor"}) • '
                    '${household.totalMembers} Members (${household.children} kids, ${household.olderAdults} seniors) • '
                    '${household.budget.label}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: settings.useRealGenAi ? Colors.blue.withValues(alpha: 0.15) : Colors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: settings.useRealGenAi ? Colors.blue : Colors.purple),
                  ),
                  child: Text(
                    settings.useRealGenAi ? 'GenAI Active' : 'Deterministic Local Mode',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: settings.useRealGenAi ? Colors.blue.shade700 : Colors.purple.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: aiState.messages.length,
              itemBuilder: (context, index) {
                final msg = aiState.messages[index];
                return _buildMessageItem(context, msg);
              },
            ),
          ),

          if (aiState.isThinking)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Text(
                    'Synthesizing evidence-based environmental guidance...',
                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),

          // Suggested Questions Horizontal Rail
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedPrompts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _suggestedPrompts[index];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _handleSend(prompt),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(top: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask ClearAir AI about smog safety, filtration, commute, or children...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: aiState.isThinking ? null : () => _handleSend(),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Ask'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, AiAssistantMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

    final advice = msg.structuredAdvice;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, right: 40),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Color(0xFF0D9488), size: 18),
                ),
                const SizedBox(width: 10),
                const Text('ClearAir AI Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (advice?.isGenAiGenerated ?? false) ? Colors.blue.withValues(alpha: 0.1) : Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (advice?.isGenAiGenerated ?? false) ? 'GenAI' : 'Deterministic Local',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: (advice?.isGenAiGenerated ?? false) ? Colors.blue : Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 1. Explanation
            Text(
              msg.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),

            if (advice != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // 2. Recommended Actions
              const Text('RECOMMENDED ACTIONS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              ...advice.recommendedActions.map((action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(action, style: const TextStyle(fontSize: 13, height: 1.35))),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),

              // 3. Why It Matters
              _buildAdviceRow(context, 'Why It Matters:', advice.whyItMatters, Icons.psychology_outlined),
              const SizedBox(height: 10),

              // 4. Affordability
              _buildAdviceRow(context, 'Estimated Cost:', advice.affordabilityEstimate, Icons.attach_money),
              const SizedBox(height: 10),

              // 5. Expected Benefit & Uncertainty
              _buildAdviceRow(context, 'Expected Benefit & Uncertainty:', advice.expectedBenefitAndUncertainty, Icons.analytics_outlined),
              const SizedBox(height: 10),

              // 6. Source / Evidence
              _buildAdviceRow(context, 'Scientific Evidence Reference:', advice.sourceReference, Icons.menu_book_outlined),
              const SizedBox(height: 14),

              // 7. When to Seek Medical Advice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services_outlined, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'When to Seek Clinical Help: ${advice.whenToSeekMedicalAdvice}',
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceRow(BuildContext context, String title, String body, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: [
                TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
