import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/portal_api.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Правила',
      title: 'Правила JBFORSAKEN',
      subtitle: 'Актуальная версия правил загружается из backend и может редактироваться через админ-панель.',
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchRules(apiClient),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return InfoStrip(
                icon: Icons.error_outline_rounded,
                title: 'Правила недоступны',
                text: snapshot.error.toString(),
              );
            }

            final rules = snapshot.data ?? const [];
            if (rules.isEmpty) {
              return const InfoStrip(
                icon: Icons.gavel_outlined,
                title: 'Правила пока не опубликованы',
                text: 'Администратор может добавить их через /admin.',
              );
            }

            return Column(
              children: [
                for (int i = 0; i < rules.length; i++) ...[
                  _RuleGroup(
                    number: (i + 1).toString().padLeft(2, '0'),
                    title: rules[i]['title']?.toString() ?? '',
                    items: (rules[i]['body']?.toString() ?? '')
                        .split('\n')
                        .where((x) => x.trim().isNotEmpty)
                        .toList(),
                  ),
                  if (i != rules.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RuleGroup extends StatelessWidget {
  final String number;
  final String title;
  final List<String> items;

  const _RuleGroup({
    required this.number,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: JbfColors.panel0,
        borderRadius: BorderRadius.circular(JbfRadii.md),
        border: Border.all(color: JbfColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: JbfColors.accentLime,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                for (final item in items) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•', style: TextStyle(color: JbfColors.accentCyan)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(color: JbfColors.textSecondary, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
