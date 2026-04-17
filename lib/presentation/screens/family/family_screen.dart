import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';

import '../../viewmodels/auth_provider.dart';
import '../../viewmodels/family_provider.dart';


class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    final user = authState.value;

    final householdAsync = ref.watch(householdDetailsProvider);
    final membersAsync = ref.watch(householdMembersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [

          householdAsync.when(
            data: (household) => _FamilyHeader(name: household?.name ?? "Mon Foyer"),
            loading: () => const _FamilyHeader(name: "Chargement..."),
            error: (_, __) => const _FamilyHeader(name: "Erreur"),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //liste des membres
                  membersAsync.when(
                    //liste des membres du famille : admin d'abord
                    data: (members) {
                        final sortedMembers = List.from(members)
                        ..sort((a, b) {
                         if (a.role == 'Admin') return -1;
                         if (b.role == 'Admin') return 1;
                         return 0;
                        });
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Membres (${sortedMembers.length})', style: AppTextStyles.h3),
                            const SizedBox(height: 16),
                            ...sortedMembers.map((m) => _MemberTile(
                              uid: m.uid,
                              name: m.name,
                              role: m.role,
                              isMe: m.uid == user?.uid,
                              photoUrl: m.photoUrl,
                            )),
                          ],
                        );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),

                    error: (e, _) => Text('Erreur : $e'),
                  ),

                  const SizedBox(height: 40),

                  //seul Admin peut inviter
                  if (user?.isAdmin ?? false)
                    householdAsync.when(
                      data: (household) => _InviteSection(code: household?.inviteCode ?? ""),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _FamilyHeader extends ConsumerWidget {
  final String name;
  const _FamilyHeader({required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const Icon(Icons.house_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(name, style: AppTextStyles.h2.copyWith(color: Colors.white)),
            ],
          ),
          Positioned(
            right: 16,
            top: 0,
            child: GestureDetector(
              onTap: () => _showLogoutDialog(context, ref),
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text("Déconnexion", textAlign: TextAlign.center),
      content: const Text(
        "Êtes-vous sûr de déconnecter ?",
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Annuler", style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.indigo,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.pop(context);
            ref.read(authStateProvider.notifier).logout();
          },
          child: const Text("Se déconnecter", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}


class _MemberTile extends ConsumerWidget {
  final String name;
  final String role;
  final bool isMe;
  final String uid;
  final String? photoUrl;

  const _MemberTile({
    required this.name,
    required this.role,
    required this.isMe,
    required this.uid,
    this.photoUrl
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final bool isAdmin = currentUser?.isAdmin ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.indigo.withOpacity(0.1),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null ? const Icon(Icons.person, color: AppColors.indigo) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(isMe ? 'Vous - $role' : role, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),


          if (role == 'Admin')
            _buildBadge('Admin', AppColors.successGreen)

          //quitter le household si membre
          else if (isMe)
            IconButton(
              icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.errorRed, size: 22),
              onPressed: () => _confirmLeave(context, ref),
            )


          //expluser un membre
          else if (isAdmin && role != 'Admin')
              IconButton(
                icon: const Icon(Icons.person_remove_alt_1_rounded, color: AppColors.errorRed, size: 22),
                onPressed: () => _confirmKick(context, ref, name, uid),
              ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}


//pour confirmer si vraiment quitter
void _confirmLeave(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text("Quitter le foyer"),
      content: const Text("Voulez-vous vraiment quitter ce foyer ? Vous perdrez l'accès au stock commun."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
          onPressed: () {
            Navigator.pop(ctx);
            ref.read(authStateProvider.notifier).leaveHousehold();
          },
          child: const Text("Quitter", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}


//confirme l'expulsion

void _confirmKick(BuildContext context, WidgetRef ref, String name, String uid) {


  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text("Expulser $name"),
      content: const Text("Ce membre n'aura plus accès aux données du foyer."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
          onPressed: () {
            Navigator.pop(ctx);
            ref.read(familyControllerProvider.notifier).removeMember(uid);
          },
          child: const Text("Expulser", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}



class _InviteSection extends StatelessWidget {
  final String code;
  const _InviteSection({required this.code});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => Share.share("Rejoins mon foyer StockWise ! Code : $code"),
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: const Text(
              'Inviter un membre',
              style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              )
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text("Code d'invitation", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copié !')));
          },
          child: Text(code, style: AppTextStyles.h1.copyWith(letterSpacing: 4, color: AppColors.primaryNavy)),
        ),
      ],
    );
  }
}
