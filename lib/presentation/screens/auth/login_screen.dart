import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';
import '../../viewmodels/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildFeatureCard(Icons.inventory_2_outlined, 'Gestion', 'Suivi réel'),
                        _buildFeatureCard(Icons.family_restroom_outlined, 'Famille', 'Partage'),
                        _buildFeatureCard(Icons.bolt, 'Alertes', 'Stocks'),
                        _buildFeatureCard(Icons.shield_outlined, 'Sécurisé', 'Chiffré'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  _buildLoginCard(ref, context),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }

  // Widget pour le Header (Logo + Titre)
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.inventory_2, color: Color(0xFF6366F1), size: 40),
        ),
        const SizedBox(height: 16),
        Text('StockWise',
            style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLoginCard(WidgetRef ref, BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Text('Bienvenue', style: AppTextStyles.h2.copyWith(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryNavy)),
          const SizedBox(height: 8),
          Text('Connectez-vous pour commencer',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(color: const Color(0xFF64748B))),
          const SizedBox(height: 32),

          _GoogleButton(isLoading: isLoading, ref: ref, context: context),

          const SizedBox(height: 24),
          Text('En continuant, vous acceptez nos conditions',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(fontSize: 10, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool isLoading;
  final WidgetRef ref;
  final BuildContext context;

  const _GoogleButton({required this.isLoading, required this.ref, required this.context});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () async {
          final error = await ref.read(authStateProvider.notifier).loginWithGoogle();
          if (error != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFF1F5F9), width: 2),
          ),
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset(
              'assets/images/google-logo.png',
              height: 22,
              width: 22,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
        const Flexible(
          child: Text(
            'Continuer avec Google',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
          ],
        ),
      ),
    );
  }
}
