import 'package:flutter/material.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Правила',
      title: 'Правила JBFORSAKEN',
      subtitle: 'Структурированная версия правил. Финальный текст наказаний и отдельных исключений должен синхронизироваться с правилами игрового сервера.',
      children: const [
        _RuleGroup(
          number: '01',
          title: 'Общие правила',
          items: [
            'Уважайте других игроков и администрацию.',
            'Запрещены намеренные помехи игровому процессу, эксплуатация багов и обход ограничений.',
            'Незнание правил не освобождает от ответственности.',
          ],
        ),
        SizedBox(height: 14),
        _RuleGroup(
          number: '02',
          title: 'Заключённые',
          items: [
            'Выполняйте корректные приказы командира в рамках режима.',
            'Игровые действия, связанные с побегом, бунтом и LR, регулируются правилами конкретной ситуации.',
            'Запрещено намеренно затягивать раунд без игровой цели.',
          ],
        ),
        SizedBox(height: 14),
        _RuleGroup(
          number: '03',
          title: 'Охрана и командир',
          items: [
            'CT обязан понимать правила Jailbreak до игры за охрану.',
            'Командир отвечает за понятные приказы и проведение раунда.',
            'Запрещены необоснованные убийства заключённых и злоупотребление полномочиями.',
          ],
        ),
        SizedBox(height: 14),
        _RuleGroup(
          number: '04',
          title: 'Чат и коммуникация',
          items: [
            'Не используйте голосовой и текстовый чат для спама и намеренных помех.',
            'Запрещена публикация вредоносных ссылок и персональных данных других людей.',
            'Конфликты с администрацией решаются через установленные каналы проекта.',
          ],
        ),
        SizedBox(height: 14),
        InfoStrip(
          icon: Icons.info_outline_rounded,
          title: 'Нужна синхронизация с финальными правилами',
          text: 'Этот экран уже готов технически. Перед публикацией production-версии сюда нужно перенести утверждённый полный свод правил JBFORSAKEN и таблицу наказаний.',
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
