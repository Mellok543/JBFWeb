import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/server_status_notifier.dart';
import '../theme/jbf_theme.dart';
import 'jbf_badge.dart';
import 'jbf_button.dart';
import 'jbf_panel.dart';
import 'jbf_stat_card.dart';

class ServerStatus extends StatefulWidget {
  final ServerStatusNotifier? notifier;

  const ServerStatus({super.key, this.notifier});

  @override
  State<ServerStatus> createState() => _ServerStatusState();
}

class _ServerStatusState extends State<ServerStatus> {
  late final ServerStatusNotifier _notifier;
  late final bool _ownsNotifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? ServerStatusNotifier();
    _ownsNotifier = widget.notifier == null;
    if (_ownsNotifier) {
      _notifier.start();
    }
  }

  @override
  void dispose() {
    if (_ownsNotifier) {
      _notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) {
        final status = _notifier.status;
        if (status == null) {
          final error = _notifier.error;
          if (error != null) {
            return JbfPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Не удалось загрузить статус сервера',
                    style: TextStyle(color: JbfColors.error, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(error, style: const TextStyle(color: JbfColors.error, fontSize: 13)),
                ],
              ),
            );
          }
          return const JbfPanel(
            child: Text('Загрузка статуса сервера…', style: TextStyle(color: JbfColors.textSecondary)),
          );
        }

        return JbfPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('JBFORSAKEN', style: TextStyle(fontWeight: FontWeight.bold, color: JbfColors.textPrimary)),
                      Text('LIVE SERVER', style: TextStyle(fontSize: 11, color: JbfColors.textSecondary)),
                    ],
                  ),
                  JbfBadge(
                    label: status.online ? 'ONLINE' : 'OFFLINE',
                    tone: status.online ? JbfBadgeTone.online : JbfBadgeTone.offline,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (status.online) ...[
                Text(status.map ?? '', style: const TextStyle(color: JbfColors.accentCyan, fontFamily: 'monospace')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    JbfStatCard(label: 'PLAYERS', value: '${status.players} / ${status.maxPlayers}'),
                    const SizedBox(width: 10),
                    JbfStatCard(label: 'PING', value: '${status.pingMs} ms'),
                  ],
                ),
                const SizedBox(height: 12),
                JbfButton(
                  label: 'CONNECT',
                  variant: JbfButtonVariant.primary,
                  onPressed: () => launchUrl(Uri.parse('steam://connect/${status.connectAddress}')),
                ),
              ] else
                Text(
                  'Сервер недоступен. Последняя проверка: ${DateTime.parse(status.lastUpdateUtc).toLocal()}',
                  style: const TextStyle(color: JbfColors.error, fontSize: 13),
                ),
            ],
          ),
        );
      },
    );
  }
}
