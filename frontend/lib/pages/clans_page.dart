import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/portal_api.dart';
import '../state/auth_notifier.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class ClansPage extends StatefulWidget {
  const ClansPage({super.key});

  @override
  State<ClansPage> createState() => _ClansPageState();
}

class _ClansPageState extends State<ClansPage> {
  late Future<List<Map<String, dynamic>>> _clans;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _clans = fetchClans(apiClient);
  }

  Future<void> _create() async {
    if (authNotifier.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала войдите через Steam.')),
      );
      return;
    }

    final name = TextEditingController();
    final tag = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать клан'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Название')),
            TextField(controller: tag, decoration: const InputDecoration(labelText: 'Тег')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Создать')),
        ],
      ),
    );

    if (result != true) return;

    try {
      await createClan(apiClient, name.text, tag.text);
      setState(_reload);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Кланы',
      title: 'Команды JBFORSAKEN',
      subtitle: 'Создание и список кланов работают через Spring MVC и транзакции.',
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _create,
            icon: const Icon(Icons.add_rounded),
            label: const Text('СОЗДАТЬ КЛАН'),
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _clans,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return InfoStrip(
                icon: Icons.error_outline_rounded,
                title: 'Кланы недоступны',
                text: snapshot.error.toString(),
              );
            }

            final clans = snapshot.data ?? const [];
            if (clans.isEmpty) {
              return const InfoStrip(
                icon: Icons.groups_rounded,
                title: 'Пока нет кланов',
                text: 'Первый авторизованный игрок может создать клан.',
              );
            }

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final clan in clans)
                  FeatureCard(
                    icon: Icons.shield_outlined,
                    title: '[${clan['tag']}] ${clan['name']}',
                    text: 'Владелец: ${clan['ownerSteamId64']}',
                    accent: JbfColors.accentCyan,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
