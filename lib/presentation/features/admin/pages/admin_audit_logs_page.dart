import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/data/providers/audit_log_repository_provider.dart';

final adminAuditLogsProvider = StreamProvider.autoDispose<List<AuditLogEntity>>((ref) {
  final repo = ref.watch(auditLogRepositoryProvider);
  return repo.watchAuditLogs();
});

class AdminAuditLogsPage extends ConsumerWidget {
  const AdminAuditLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(adminAuditLogsProvider);
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'سجل العمليات' : 'Audit Logs'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminAuditLogsProvider),
        child: logsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('$err')),
          data: (list) {
            if (list.isEmpty) {
              return Center(
                child: Text(isAr ? 'السجل فارغ' : 'No audit logs found'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = list[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                log.action,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.colorScheme.onPrimaryContainer,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              log.timestamp.toLocal().toString().split('.')[0],
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          log.details,
                          style: context.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Divider(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              log.userEmail,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
