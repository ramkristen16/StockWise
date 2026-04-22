import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:stock_wise/presentation/screens/auth/setup_household_screen.dart';
import '../../../core/navigation/app_router.dart';
import '../../viewmodels/auth_provider.dart';
import 'login_screen.dart';

final authLoadingProvider = StateProvider<bool>((ref) => true);

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () =>
      const Scaffold(
        backgroundColor: Color(0xFF1E293B),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),


      error: (e, _) =>
          Scaffold(
            body: Center(child: Text('Erreur : $e')),
          ),

      data: (user) {
        if (user == null) return const LoginScreen();
        if (!user.hasHousehold) return const SetupHouseholdScreen();
        return const MainScaffold();
      },
    );
  }

}