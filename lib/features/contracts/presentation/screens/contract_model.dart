// lib/features/contracts/presentation/screens/contracts_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/contract_provider.dart';
import '../widgets/contract_card.dart';
import '../widgets/contract_filter_bottom_sheet.dart';
import 'contract_detail_screen.dart';

/// Contracts List Screen
class ContractsListScreen extends StatefulWidget {
  const ContractsListScreen({Key? key}) : super(key: key);

  @override
  State<ContractsListScreen> createState() => _ContractsListScreenState();
}

class _ContractsListScreenState extends State<ContractsListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContractProvider>().loadContracts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ContractProvider>().loadMoreContracts();
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ContractFilterBottomSheet(),
    );
  }

  Future<void> _refreshContracts() async {
    await context.read<ContractProvider>().loadContracts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Sözleşmeler',
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Sözleşme ara...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<ContractProvider>()
                            .setSearchQuery(null);
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    context.read<ContractProvider>().setSearchQuery(
                      value.isEmpty ? null : value,
                    );
                  },
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: AppTextStyles.bodyMedium,
                tabs: [
                  Tab(text: 'Tümü (${context.watch<ContractProvider>().totalContracts})'),
                  Tab(text: 'Taslak (${context.watch<ContractProvider>().draftCount})'),
                  Tab(text: 'Onay Bekliyor (${context.watch<ContractProvider>().pendingApprovalCount})'),
                  Tab(text: 'İmzalandı (${context.watch<ContractProvider>().signedCount})'),
                  Tab(text: 'İptal (${context.watch<ContractProvider>().cancelledCount})'),
                ],
                onTap: (index) {
                  final provider = context.read<ContractProvider>();
                  switch (index) {
                    case 0:
                      provider.setFilterStatus(null);
                      break;
                    case 1:
                      provider.setFilterStatus(ContractStatus.draft);
                      break;
                    case 2:
                      provider.setFilterStatus(ContractStatus.pendingApproval);
                      break;
                    case 3:
                      provider.setFilterStatus(ContractStatus.signed);
                      break;
                    case 4:
                      provider.setFilterStatus(ContractStatus.cancelled);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Consumer<ContractProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.contracts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.contracts.isEmpty) {
            return _buildErrorWidget(provider.error!);
          }

          if (provider.contracts.isEmpty) {
            return _buildEmptyWidget();
          }

          return RefreshIndicator(
            onRefresh: _refreshContracts,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.contracts.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.contracts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final contract = provider.contracts[index];
                return ContractCard(
                  contract: contract,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContractDetailScreen(
                          contractId: contract.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Bir Hata Oluştu',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshContracts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sözleşme Bulunamadı',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Henüz hiç sözleşme oluşturulmamış',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}