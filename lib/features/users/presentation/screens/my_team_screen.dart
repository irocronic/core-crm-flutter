// lib/features/users/presentation/screens/my_team_screen.dart
import 'package:flutter/material.dart';
// ✅ DÜZELTME: Hatalı import yolu düzeltildi.
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/user_card.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
// EKLENEN KOD: CustomDrawer bileşenini içe aktarma
import '../../../../shared/widgets/custom_drawer.dart';

class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({super.key});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadMyTeam();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // EKLENEN KOD: CustomDrawer buraya eklenmiştir.
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Ekibim'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Ekip bilgisi yükleniyor...');
          }

          if (provider.errorMessage != null) {
            return ErrorDisplay(
              message: provider.errorMessage!,
              onRetry: () => provider.loadMyTeam(),
            );
          }

          final team = provider.team;
          if (team == null) {
            return const Center(child: Text('Ekip bilgisi bulunamadı.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMyTeam(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Ekip Lideri',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                UserCard(user: team.teamLeader),
                const SizedBox(height: 24),
                Text(
                  'Ekip Üyeleri (${team.totalMembers})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (team.teamMembers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text('Ekibinizde henüz üye bulunmuyor.')),
                  )
                else
                  ...team.teamMembers.map((user) => UserCard(user: user)),
              ],
            ),
          );
        },
      ),
    );
  }
}