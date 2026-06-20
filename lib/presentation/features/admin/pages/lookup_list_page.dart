import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/lookup.entity.dart';
import 'package:fresh_market/data/providers/lookup_repository_provider.dart';
import '../providers/lookup_providers.dart';

class LookupListPage extends ConsumerWidget {
  final String lookupType;
  final String title;

  const LookupListPage({
    super.key,
    required this.lookupType,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(lookupListProvider(lookupType));
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: isRtl ? 'إضافة' : 'Add Lookup',
            onPressed: () {
              context.push('/admin/lookups/new?type=$lookupType');
            },
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(isRtl ? 'لا توجد بيانات' : 'No items found'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.push('/admin/lookups/new?type=$lookupType');
                    },
                    child: Text(isRtl ? 'إضافة' : 'Add Lookup'),
                  ),
                ],
              ),
            );
          }

          // Create a mutable copy for reordering list
          final mutableList = List<LookupEntity>.from(list);

          return ReorderableListView.builder(
            itemCount: mutableList.length,
            padding: const EdgeInsets.all(16),
            onReorder: (oldIndex, newIndex) async {
              var adjustedIndex = newIndex;
              if (oldIndex < newIndex) {
                adjustedIndex -= 1;
              }
              final item = mutableList.removeAt(oldIndex);
              mutableList.insert(adjustedIndex, item);
              final ids = mutableList.map((l) => l.id).toList();
              final repository = ref.read(lookupRepositoryProvider);
              await repository.reorderLookups(lookupType, ids);
            },
            itemBuilder: (context, index) {
              final item = mutableList[index];
              return Card(
                key: ValueKey(item.id),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.drag_handle),
                  title: Text(isRtl ? item.nameAr : item.nameEn),
                  subtitle: Text('Code: ${item.code} | ID: ${item.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Toggle Active
                      IconButton(
                        icon: Icon(
                          item.isActive ? Icons.visibility : Icons.visibility_off,
                          color: item.isActive ? Colors.green : Colors.grey,
                        ),
                        tooltip: isRtl ? 'تعديل الظهور' : 'Toggle Active',
                        onPressed: () async {
                          final updated = item.copyWith(isActive: !item.isActive);
                          final repository = ref.read(lookupRepositoryProvider);
                          await repository.updateLookup(updated);
                        },
                      ),
                      // Edit
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: isRtl ? 'تعديل' : 'Edit',
                        onPressed: () {
                          context.push('/admin/lookups/edit/${item.id}?type=$lookupType');
                        },
                      ),
                      // Delete
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: isRtl ? 'حذف' : 'Delete',
                        onPressed: () => _confirmDelete(context, ref, item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/lookups/new?type=$lookupType');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, LookupEntity item) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRtl ? 'حذف العنصر؟' : 'Delete Item?'),
        content: Text(isRtl
            ? 'هل أنت متأكد من حذف "${item.nameAr}"؟'
            : 'Are you sure you want to delete "${item.nameEn}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final repository = ref.read(lookupRepositoryProvider);
              await repository.deleteLookup(item.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isRtl ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
