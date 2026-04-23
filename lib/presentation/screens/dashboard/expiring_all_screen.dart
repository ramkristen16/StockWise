import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';
import '../../viewmodels/stock_provider.dart';
import 'dashboard_screen.dart';

class ExpiringAllScreen extends ConsumerWidget {
  const ExpiringAllScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiring = ref.watch(stockProvider.notifier).expiringSoonList;
    final hasExpired = expiring.any((p) => p.isExpired);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes Péremption'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryNavy,
        elevation: 0,
        actions: [
          if (hasExpired)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: AppColors.errorRed),
              onPressed: () => _showClearConfirmation(context, ref),
              tooltip: 'Vider les périmés',
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: expiring.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
          key: const ValueKey('list'),
          padding: const EdgeInsets.all(16),
          itemCount: expiring.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ExpiringRow(product: expiring[index]),
            );
          },
        ),
      ),


    );
  }
  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tout supprimer ?'),
        content: const Text('Voulez-vous supprimer définitivement tous les produits déjà périmés de votre stock ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(stockProvider.notifier).clearAllExpired();
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
Widget _buildEmptyState() {
  return Center(
    key: const ValueKey('empty'),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Une icône douce pour dire que tout va bien
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.done_all_rounded,
            size: 64,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Tout est sous contrôle !',
          style: AppTextStyles.h2.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Aucun produit périmé ou en alerte n\'a été trouvé dans votre stock.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

