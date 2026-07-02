import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/health_tip_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';

class AdminHealthTipsScreen extends ConsumerWidget {
  const AdminHealthTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(healthTipsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Health Tips CMS', style: AppTextStyles.h1),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddTipDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Tip'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(width: AppSpacing.base),
        ],
      ),
      body: tipsAsync.when(
        data: (tips) {
          if (tips.isEmpty) {
            return const EmptyState(
              icon: Icons.lightbulb_outline,
              title: 'No health tips yet',
              subtitle: 'Create your first health tip',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: tips.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) => _buildTipCard(tips[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTipCard(HealthTipModel tip) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(tip.title, style: AppTextStyles.subtitle),
              ),
              if (tip.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    tip.category!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tip.content,
            style: AppTextStyles.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                AppFormatters.dateTime(tip.createdAt),
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () {},
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.error),
                onPressed: () {},
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTipDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String? category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Tip'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Title'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(hintText: 'Category'),
                  items: ['Wellness', 'Prevention', 'Mental Health', 'Nutrition']
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (v) => category = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration:
                      const InputDecoration(hintText: 'Content'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final tip = HealthTipModel(
                id: 'tip_${DateTime.now().millisecondsSinceEpoch}',
                title: titleController.text,
                content: contentController.text,
                category: category,
                createdAt: DateTime.now(),
                createdBy: 'admin',
              );
              await ref
                  .read(databaseServiceProvider)
                  .addHealthTip(tip);
              ref.invalidate(healthTipsProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add Tip'),
          ),
        ],
      ),
    );
  }
}
