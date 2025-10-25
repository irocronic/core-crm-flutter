// lib/features/properties/presentation/screens/projects_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_drawer.dart';
import '../providers/property_provider.dart';
import '../../data/models/project_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // Bu import zaten var

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<PropertyProvider>().loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          // Rol kontrolü zaten var
          if (authProvider.isAdmin || authProvider.isSalesManager)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'stats') {
                  context.go('/properties/stats');
                } else if (value == 'bulk_upload') {
                  context.go('/properties/bulk-upload');
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'stats',
                  child: ListTile(
                    leading: Icon(Icons.bar_chart),
                    title: Text('İstatistikler'),
                  ),
                ),
                if (authProvider.isAdmin) // Sadece admin toplu yükleme yapabilir
                  const PopupMenuItem<String>(
                    value: 'bulk_upload',
                    child: ListTile(
                      leading: Icon(Icons.upload_file),
                      title: Text('Toplu Yükleme (CSV)'),
                    ),
                  ),
              ],
            ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.projects.isEmpty) {
            return Center(child: Text('Hata: ${provider.errorMessage}'));
          }

          if (provider.projects.isEmpty) {
            return const Center(
              child: Text(
                'Henüz proje bulunmuyor.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.projects.length,
              itemBuilder: (context, index) {
                final project = provider.projects[index];
                return _ProjectCard(project: project);
              },
            ),
          );
        },
      ),
      // --- FAB GÜNCELLENDİ ---
      floatingActionButton: (authProvider.isAdmin || authProvider.isSalesManager)
          ? FloatingActionButton(
        onPressed: () {
          // Artık SnackBar yerine forma yönlendiriyoruz
          context.go('/projects/new');
        },
        tooltip: 'Yeni Proje Ekle',
        child: const Icon(Icons.add),
      )
          : null,
      // --- FAB GÜNCELLENDİ SONU ---
    );
  }
}

// _ProjectCard widget'ı aynı kalabilir...
class _ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      clipBehavior: Clip.antiAlias, // Bu, resmin kartın köşeleriyle uyumlu olmasını sağlar
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Projeye tıklandığında ilgili mülk listesine git
          context.go('/properties/project/${project.id}', extra: project.name);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Proje Görseli
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[300], // Varsayılan arkaplan
              child: project.projectImage != null
                  ? Image.network(
                project.projectImage!,
                fit: BoxFit.cover,
                // Hata durumunda veya yüklenirken gösterilecek widget
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.business, size: 60, color: Colors.grey),
                  );
                },
              )
                  : const Center( // Görsel yoksa ikon göster
                child: Icon(Icons.business, size: 60, color: Colors.grey),
              ),
            ),
            // Proje Detayları
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (project.location != null && project.location!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            project.location!,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  // İstatistikler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(
                        context,
                        'Toplam Mülk',
                        project.propertyCount?.toString() ?? '0', // Null check
                        Icons.home_work,
                        Colors.blue,
                      ),
                      _buildStat(
                        context,
                        'Müsait',
                        project.availableCount?.toString() ?? '0', // Null check
                        Icons.event_available,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildStat helper metodu aynı kalabilir
  Widget _buildStat(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}