import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/enums/request_state.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../providers/weight_unit_providers.dart';
import '../widgets/weight_unit_card.dart';
import '../widgets/weight_unit_delete_dialog.dart';

class AdminWeightUnitsPage extends ConsumerWidget {
  const AdminWeightUnitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weightUnitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Units'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Weight Unit',
            onPressed: () => context.push(RouteConstants.adminWeightUnitNew),
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
      floatingActionButton: state.weightUnits.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => context.push(RouteConstants.adminWeightUnitNew),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, WeightUnitListState state) {
    if (state.requestState == RequestState.loading) {
      return const LoadingWidget();
    }
    if (state.requestState == RequestState.failure) {
      return ErrorDisplayWidget(
        message: state.errorMessage ?? context.l10n.errorGeneral,
        onRetry: () => ref.read(weightUnitListProvider.notifier).refresh(),
      );
    }
    if (state.weightUnits.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.scale_outlined,
        title: 'No Weight Units',
        actionLabel: 'Add Weight Unit',
        onAction: () => context.push(RouteConstants.adminWeightUnitNew),
      );
    }
    return _buildList(context, ref, state);
  }

  Widget _buildList(BuildContext context, WidgetRef ref, WeightUnitListState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(weightUnitListProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.weightUnits.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final unit = state.weightUnits[index];
          return WeightUnitCard(
            key: ValueKey(unit.id),
            weightUnit: unit,
            onEdit: () => context.push(
              RouteConstants.adminWeightUnitEditPath(unit.id),
            ),
            onDelete: () => _showDeleteDialog(context, ref, unit.id, unit.nameEn),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => WeightUnitDeleteDialog(
        weightUnitName: name,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final error = await ref
              .read(weightUnitListProvider.notifier)
              .deleteWeightUnit(id);
          if (error != null && context.mounted) {
            context.showSnackBar(error, isError: true);
          } else if (context.mounted) {
            context.showSnackBar(context.l10n.itemDeleted);
          }
        },
      ),
    );
  }
}
