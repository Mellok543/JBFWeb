import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/portal_api.dart';
import '../state/auth_notifier.dart';
import '../theme/jbf_theme.dart';
import '../widgets/page_shell.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<List<Map<String, dynamic>>> _products;

  @override
  void initState() {
    super.initState();
    _products = fetchStoreProducts(apiClient);
  }

  Future<void> _buy(String code) async {
    if (authNotifier.user == null) {
      _message('Сначала войдите через Steam.');
      return;
    }
    try {
      final order = await createStoreOrder(apiClient, code);
      _message('Заказ создан: ${order['id']}');
    } catch (e) {
      _message('Не удалось создать заказ: $e');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Магазин',
      title: 'Привилегии и косметика',
      subtitle: 'Каталог загружается из Spring backend. Покупка создаёт транзакционный заказ, а повторный запрос защищён Idempotency-Key.',
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return InfoStrip(
                icon: Icons.error_outline_rounded,
                title: 'Каталог недоступен',
                text: snapshot.error.toString(),
              );
            }
            final products = snapshot.data ?? const [];
            if (products.isEmpty) {
              return const InfoStrip(
                icon: Icons.inventory_2_outlined,
                title: 'Каталог пуст',
                text: 'Добавьте товары в jbf_web_store_products.',
              );
            }

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final product in products)
                  FeatureCard(
                    icon: product['category'] == 'VIP'
                        ? Icons.workspace_premium_outlined
                        : Icons.style_outlined,
                    title: product['name']?.toString() ?? product['code'].toString(),
                    text: product['description']?.toString() ?? '',
                    accent: product['category'] == 'VIP'
                        ? JbfColors.accentLime
                        : JbfColors.accentCyan,
                    footer: FilledButton(
                      onPressed: () => _buy(product['code'].toString()),
                      child: Text('${(((product['priceCents'] as num?) ?? 0) / 100).toStringAsFixed(0)} ₽'),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
