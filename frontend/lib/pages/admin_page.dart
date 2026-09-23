import 'package:flutter/material.dart';
import '../api/admin_api.dart';
import '../api/api_client.dart';
import '../state/auth_notifier.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late final TabController tabs;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!authNotifier.isAdmin) {
      return const PageShell(
        eyebrow: 'Админ-панель',
        title: 'Доступ запрещён',
        subtitle: 'Эта страница доступна только SteamID64 из ADMIN_STEAM_IDS.',
        children: [],
      );
    }

    return PageShell(
      eyebrow: 'Админ-панель',
      title: 'Управление JBFORSAKEN',
      subtitle: 'Новости, магазин, заказы, пользователи, Battle Pass, кланы и журнал действий.',
      children: [
        TabBar(
          controller: tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Новости'),
            Tab(text: 'Правила'),
            Tab(text: 'Товары'),
            Tab(text: 'Заказы'),
            Tab(text: 'Игроки'),
            Tab(text: 'Battle Pass / Кланы'),
            Tab(text: 'Аудит'),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 720,
          child: TabBarView(
            controller: tabs,
            children: const [
              _Dashboard(),
              _News(),
              _Rules(),
              _Products(),
              _Orders(),
              _Users(),
              _World(),
              _Audit(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: fetchAdminDashboard(apiClient),
    builder: (context, s) {
      if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (s.hasError) return _Error(s.error.toString());
      final d = s.data ?? const {};
      final cards = <(String, dynamic, IconData)>[
        ('Игроки', d['users'] ?? 0, Icons.people_outline),
        ('Новости', d['news'] ?? 0, Icons.article_outlined),
        ('Товары', d['products'] ?? 0, Icons.storefront_outlined),
        ('Заказы', d['orders'] ?? 0, Icons.receipt_long_outlined),
        ('Кланы', d['clans'] ?? 0, Icons.groups_outlined),
        ('Сезоны', d['seasons'] ?? 0, Icons.verified_outlined),
      ];
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final c in cards)
            Container(
              width: 220,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: JbfColors.panel0,
                borderRadius: BorderRadius.circular(JbfRadii.md),
                border: Border.all(color: JbfColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(c.$3, color: JbfColors.accentCyan),
                  const SizedBox(height: 14),
                  Text('${c.$2}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                  Text(c.$1, style: const TextStyle(color: JbfColors.textSecondary)),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class _News extends StatefulWidget {
  const _News();
  @override
  State<_News> createState() => _NewsState();
}

class _NewsState extends State<_News> {
  late Future<List<Map<String, dynamic>>> future;
  @override
  void initState() { super.initState(); reload(); }
  void reload() => future = fetchAdminNews(apiClient);

  Future<void> edit([Map<String, dynamic>? item]) async {
    final title = TextEditingController(text: item?['title']?.toString() ?? '');
    final body = TextEditingController(text: item?['body']?.toString() ?? '');
    bool pinned = item?['pinned'] == true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Новая новость' : 'Редактировать'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Заголовок')),
                TextField(controller: body, maxLines: 6, decoration: const InputDecoration(labelText: 'Текст')),
                CheckboxListTile(
                  value: pinned,
                  onChanged: (v) => setDialogState(() => pinned = v ?? false),
                  title: const Text('Закрепить'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    if (item == null) {
      await createAdminNews(apiClient, title: title.text, body: body.text, pinned: pinned);
    } else {
      await updateAdminNews(apiClient, item['id'] as int, title: title.text, body: body.text, pinned: pinned);
    }
    setState(reload);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(onPressed: () => edit(), icon: const Icon(Icons.add), label: const Text('ДОБАВИТЬ')),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, s) {
            if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (s.hasError) return _Error(s.error.toString());
            final rows = s.data ?? const [];
            return ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final x = rows[i];
                return ListTile(
                  leading: Icon(x['pinned'] == true ? Icons.push_pin : Icons.article_outlined),
                  title: Text(x['title'].toString()),
                  subtitle: Text(x['body'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Wrap(children: [
                    IconButton(onPressed: () => edit(x), icon: const Icon(Icons.edit_outlined)),
                    IconButton(
                      onPressed: () async { await deleteAdminNews(apiClient, x['id'] as int); setState(reload); },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ]),
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

class _Products extends StatefulWidget {
  const _Products();
  @override
  State<_Products> createState() => _ProductsState();
}

class _ProductsState extends State<_Products> {
  late Future<List<Map<String, dynamic>>> future;
  @override
  void initState() { super.initState(); reload(); }
  void reload() => future = fetchAdminProducts(apiClient);

  Future<void> edit([Map<String, dynamic>? item]) async {
    final code = TextEditingController(text: item?['code']?.toString() ?? '');
    final name = TextEditingController(text: item?['name']?.toString() ?? '');
    final description = TextEditingController(text: item?['description']?.toString() ?? '');
    final category = TextEditingController(text: item?['category']?.toString() ?? 'VIP');
    final price = TextEditingController(text: item == null ? '' : '${item['priceCents']}');
    final sort = TextEditingController(text: item == null ? '0' : '${item['sortOrder']}');
    bool active = item?['active'] != false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Новый товар' : 'Редактировать товар'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: code, enabled: item == null, decoration: const InputDecoration(labelText: 'CODE')),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Название')),
                TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Описание')),
                TextField(controller: category, decoration: const InputDecoration(labelText: 'Категория')),
                TextField(controller: price, decoration: const InputDecoration(labelText: 'Цена в копейках')),
                TextField(controller: sort, decoration: const InputDecoration(labelText: 'Порядок')),
                SwitchListTile(value: active, onChanged: (v) => setDialogState(() => active = v), title: const Text('Активен')),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await saveAdminProduct(
      apiClient,
      existingCode: item?['code']?.toString(),
      code: code.text,
      name: name.text,
      description: description.text,
      category: category.text,
      priceCents: int.tryParse(price.text) ?? 0,
      active: active,
      sortOrder: int.tryParse(sort.text) ?? 0,
    );
    setState(reload);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(onPressed: () => edit(), icon: const Icon(Icons.add), label: const Text('ДОБАВИТЬ ТОВАР')),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, s) {
            if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (s.hasError) return _Error(s.error.toString());
            final rows = s.data ?? const [];
            return ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final x = rows[i];
                return ListTile(
                  leading: Icon(x['active'] == true ? Icons.check_circle_outline : Icons.pause_circle_outline),
                  title: Text('${x['name']} (${x['code']})'),
                  subtitle: Text('${x['category']} • ${((x['priceCents'] as num) / 100).toStringAsFixed(0)} ₽'),
                  trailing: Wrap(children: [
                    IconButton(onPressed: () => edit(x), icon: const Icon(Icons.edit_outlined)),
                    IconButton(
                      onPressed: () async { await deleteAdminProduct(apiClient, x['code'].toString()); setState(reload); },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ]),
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

class _Orders extends StatefulWidget {
  const _Orders();
  @override
  State<_Orders> createState() => _OrdersState();
}

class _OrdersState extends State<_Orders> {
  late Future<List<Map<String, dynamic>>> future;
  @override
  void initState() { super.initState(); reload(); }
  void reload() => future = fetchAdminOrders(apiClient);

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
    future: future,
    builder: (context, s) {
      if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (s.hasError) return _Error(s.error.toString());
      final rows = s.data ?? const [];
      return ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, i) {
          final x = rows[i];
          final status = x['status'].toString();
          return ListTile(
            title: Text('${x['productCode']} • ${x['steamId64']}'),
            subtitle: Text('${x['id']} • ${((x['amountCents'] as num) / 100).toStringAsFixed(0)} ₽'),
            trailing: DropdownButton<String>(
              value: status,
              items: const ['PENDING', 'PAID', 'FULFILLED', 'FAILED', 'REFUNDED']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) async {
                if (v == null || v == status) return;
                await updateAdminOrderStatus(apiClient, x['id'].toString(), v);
                setState(reload);
              },
            ),
          );
        },
      );
    },
  );
}

class _Users extends StatelessWidget {
  const _Users();
  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
    future: fetchAdminUsers(apiClient),
    builder: (context, s) {
      if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (s.hasError) return _Error(s.error.toString());
      final rows = s.data ?? const [];
      return ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, i) {
          final x = rows[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: x['avatarUrl'] == null ? null : NetworkImage(x['avatarUrl'].toString()),
              child: x['avatarUrl'] == null ? const Icon(Icons.person_outline) : null,
            ),
            title: Text(x['nickname']?.toString() ?? x['steamId64'].toString()),
            subtitle: Text('SteamID64: ${x['steamId64']} • ${x['lastLoginAt']}'),
          );
        },
      );
    },
  );
}

class _World extends StatefulWidget {
  const _World();

  @override
  State<_World> createState() => _WorldState();
}

class _WorldState extends State<_World> {
  late Future<List<Map<String, dynamic>>> seasons;
  late Future<List<Map<String, dynamic>>> clans;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    seasons = fetchAdminSeasons(apiClient);
    clans = fetchAdminClans(apiClient);
  }

  Future<void> createSeason() async {
    final code = TextEditingController();
    final name = TextEditingController();
    final starts = TextEditingController(text: DateTime.now().toUtc().toIso8601String());
    final ends = TextEditingController(
      text: DateTime.now().toUtc().add(const Duration(days: 90)).toIso8601String(),
    );
    bool active = true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Новый сезон Battle Pass'),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: code, decoration: const InputDecoration(labelText: 'Код, например S02')),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Название')),
                TextField(controller: starts, decoration: const InputDecoration(labelText: 'Начало (ISO 8601)')),
                TextField(controller: ends, decoration: const InputDecoration(labelText: 'Конец (ISO 8601)')),
                SwitchListTile(
                  value: active,
                  onChanged: (v) => setDialogState(() => active = v),
                  title: const Text('Активный сезон'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Создать')),
          ],
        ),
      ),
    );

    if (ok != true) return;
    await createAdminSeason(
      apiClient,
      code: code.text,
      name: name.text,
      startsAt: starts.text,
      endsAt: ends.text,
      active: active,
    );
    setState(reload);
  }

  Future<void> addLevel(Map<String, dynamic> season) async {
    final level = TextEditingController();
    final xp = TextEditingController();
    final reward = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Новый уровень — ${season['name']}'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: level, decoration: const InputDecoration(labelText: 'Номер уровня')),
              TextField(controller: xp, decoration: const InputDecoration(labelText: 'Требуется XP')),
              TextField(controller: reward, decoration: const InputDecoration(labelText: 'Награда')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Добавить')),
        ],
      ),
    );

    if (ok != true) return;
    await createAdminBattlePassLevel(
      apiClient,
      season['id'] as int,
      levelNumber: int.tryParse(level.text) ?? 0,
      xpRequired: int.tryParse(xp.text) ?? 0,
      rewardTitle: reward.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Уровень добавлен')));
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: seasons,
          builder: (context, s) {
            if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (s.hasError) return _Error(s.error.toString());
            final rows = s.data ?? const [];
            return _Panel(
              title: 'Battle Pass сезоны',
              headerAction: IconButton(
                tooltip: 'Новый сезон',
                onPressed: createSeason,
                icon: const Icon(Icons.add_circle_outline),
              ),
              children: [
                for (final x in rows)
                  ListTile(
                    leading: Icon(x['active'] == true ? Icons.verified : Icons.event_outlined),
                    title: Text(x['name'].toString()),
                    subtitle: Text('${x['code']} • ${x['startsAt']} → ${x['endsAt']}'),
                    trailing: IconButton(
                      tooltip: 'Добавить уровень',
                      onPressed: () => addLevel(x),
                      icon: const Icon(Icons.add),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: clans,
          builder: (context, s) {
            if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (s.hasError) return _Error(s.error.toString());
            final rows = s.data ?? const [];
            return _Panel(
              title: 'Кланы',
              children: [
                for (final x in rows)
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: Text('[${x['tag']}] ${x['name']}'),
                    subtitle: Text('Owner: ${x['ownerSteamId64']}'),
                    trailing: IconButton(
                      onPressed: () async {
                        await deleteAdminClan(apiClient, x['id'] as int);
                        setState(reload);
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ],
  );
}

class _Audit extends StatelessWidget {
  const _Audit();
  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
    future: fetchAdminAudit(apiClient),
    builder: (context, s) {
      if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (s.hasError) return _Error(s.error.toString());
      final rows = s.data ?? const [];
      return ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, i) {
          final x = rows[i];
          return ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text('${x['action']} ${x['targetType']}'),
            subtitle: Text('Admin ${x['adminSteamId64']} • ${x['targetId'] ?? '—'} • ${x['createdAt']}'),
            trailing: x['details'] == null ? null : Text(x['details'].toString()),
          );
        },
      );
    },
  );
}

class _Panel extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? headerAction;
  const _Panel({required this.title, required this.children, this.headerAction});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: JbfColors.panel0,
      borderRadius: BorderRadius.circular(JbfRadii.md),
      border: Border.all(color: JbfColors.border),
    ),
    child: Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          trailing: headerAction,
        ),
        const Divider(height: 1),
        Expanded(child: ListView(children: children)),
      ],
    ),
  );
}

class _Error extends StatelessWidget {
  final String text;
  const _Error(this.text);
  @override
  Widget build(BuildContext context) => Center(
    child: Text(text, style: const TextStyle(color: JbfColors.error)),
  );
}


class _Rules extends StatefulWidget {
  const _Rules();

  @override
  State<_Rules> createState() => _RulesState();
}

class _RulesState extends State<_Rules> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() => future = fetchAdminRules(apiClient);

  Future<void> edit([Map<String, dynamic>? item]) async {
    final title = TextEditingController(text: item?['title']?.toString() ?? '');
    final body = TextEditingController(text: item?['body']?.toString() ?? '');
    final sort = TextEditingController(text: item == null ? '10' : '${item['sortOrder']}');
    bool active = item?['active'] != false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Новое правило' : 'Редактировать правило'),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: sort, decoration: const InputDecoration(labelText: 'Порядок')),
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Заголовок')),
                TextField(
                  controller: body,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Текст',
                    helperText: 'Каждый пункт можно писать с новой строки',
                  ),
                ),
                SwitchListTile(
                  value: active,
                  onChanged: (v) => setDialogState(() => active = v),
                  title: const Text('Опубликовано'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
          ],
        ),
      ),
    );

    if (ok != true) return;
    await saveAdminRule(
      apiClient,
      id: item?['id'] as int?,
      sortOrder: int.tryParse(sort.text) ?? 0,
      title: title.text,
      body: body.text,
      active: active,
    );
    setState(reload);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: () => edit(),
          icon: const Icon(Icons.add),
          label: const Text('ДОБАВИТЬ ПРАВИЛО'),
        ),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, s) {
            if (s.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (s.hasError) return _Error(s.error.toString());
            final rows = s.data ?? const [];
            return ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final x = rows[i];
                return ListTile(
                  leading: Text('#${x['sortOrder']}'),
                  title: Text(x['title'].toString()),
                  subtitle: Text(
                    x['body'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Wrap(
                    children: [
                      Icon(x['active'] == true ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      IconButton(onPressed: () => edit(x), icon: const Icon(Icons.edit_outlined)),
                      IconButton(
                        onPressed: () async {
                          await deleteAdminRule(apiClient, x['id'] as int);
                          setState(reload);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    ],
  );
}
