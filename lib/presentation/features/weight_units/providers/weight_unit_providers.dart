import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/weight_unit_repository_provider.dart';
import 'package:fresh_market/domain/entities/weight_unit.entity.dart';
import 'package:fresh_market/domain/usecases/weight_unit/get_weight_units.usecase.dart';
import 'package:fresh_market/domain/usecases/weight_unit/create_weight_unit.usecase.dart';
import 'package:fresh_market/domain/usecases/weight_unit/update_weight_unit.usecase.dart';
import 'package:fresh_market/domain/usecases/weight_unit/delete_weight_unit.usecase.dart';
import 'weight_unit_form_provider.dart';

final _getWeightUnitsUseCaseProvider = Provider<GetWeightUnitsUseCase>((ref) {
  final repo = ref.watch(weightUnitRepositoryProvider);
  return GetWeightUnitsUseCase(repository: repo);
});

final _createWeightUnitUseCaseProvider = Provider<CreateWeightUnitUseCase>((ref) {
  final repo = ref.watch(weightUnitRepositoryProvider);
  return CreateWeightUnitUseCase(repository: repo);
});

final _updateWeightUnitUseCaseProvider = Provider<UpdateWeightUnitUseCase>((ref) {
  final repo = ref.watch(weightUnitRepositoryProvider);
  return UpdateWeightUnitUseCase(repository: repo);
});

final _deleteWeightUnitUseCaseProvider = Provider<DeleteWeightUnitUseCase>((ref) {
  final repo = ref.watch(weightUnitRepositoryProvider);
  return DeleteWeightUnitUseCase(repository: repo);
});

class WeightUnitListState {
  final List<WeightUnitEntity> weightUnits;
  final RequestState requestState;
  final String? errorMessage;

  const WeightUnitListState({
    this.weightUnits = const [],
    this.requestState = RequestState.idle,
    this.errorMessage,
  });

  WeightUnitListState copyWith({
    List<WeightUnitEntity>? weightUnits,
    RequestState? requestState,
    String? errorMessage,
  }) {
    return WeightUnitListState(
      weightUnits: weightUnits ?? this.weightUnits,
      requestState: requestState ?? this.requestState,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WeightUnitListNotifier extends StateNotifier<WeightUnitListState> {
  final GetWeightUnitsUseCase _getWeightUnits;
  final DeleteWeightUnitUseCase _deleteWeightUnit;

  WeightUnitListNotifier({
    required GetWeightUnitsUseCase getWeightUnits,
    required DeleteWeightUnitUseCase deleteWeightUnit,
  })  : _getWeightUnits = getWeightUnits,
        _deleteWeightUnit = deleteWeightUnit,
        super(const WeightUnitListState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(requestState: RequestState.loading);
    final result = await _getWeightUnits();
    if (result is Success<List<WeightUnitEntity>>) {
      state = state.copyWith(
        weightUnits: result.data,
        requestState: RequestState.success,
      );
    } else if (result is Failure<List<WeightUnitEntity>>) {
      state = state.copyWith(
        requestState: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(requestState: RequestState.loading);
    final result = await _getWeightUnits();
    if (result is Success<List<WeightUnitEntity>>) {
      state = state.copyWith(
        weightUnits: result.data,
        requestState: RequestState.success,
      );
    } else if (result is Failure<List<WeightUnitEntity>>) {
      state = state.copyWith(
        requestState: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  Future<String?> deleteWeightUnit(String id) async {
    final result = await _deleteWeightUnit(id);
    if (result is Success<void>) {
      state = state.copyWith(
        weightUnits: state.weightUnits.where((u) => u.id != id).toList(),
      );
      return null;
    } else if (result is Failure<void>) {
      return result.error.message;
    }
    return null;
  }
}

final weightUnitListProvider =
    StateNotifierProvider<WeightUnitListNotifier, WeightUnitListState>((ref) {
  return WeightUnitListNotifier(
    getWeightUnits: ref.watch(_getWeightUnitsUseCaseProvider),
    deleteWeightUnit: ref.watch(_deleteWeightUnitUseCaseProvider),
  );
});

final weightUnitFormProvider = StateNotifierProvider.family.autoDispose<
    WeightUnitFormNotifier, WeightUnitFormState, String?>((ref, editId) {
  WeightUnitFormState? initialState;
  if (editId != null) {
    final listState = ref.read(weightUnitListProvider);
    final weightUnit = listState.weightUnits.cast<WeightUnitEntity?>().firstWhere(
      (u) => u?.id == editId,
      orElse: () => null,
    );
    if (weightUnit != null) {
      initialState = WeightUnitFormState.fromEntity(weightUnit);
    }
  }

  return WeightUnitFormNotifier(
    createWeightUnit: ref.watch(_createWeightUnitUseCaseProvider),
    updateWeightUnit: ref.watch(_updateWeightUnitUseCaseProvider),
    getWeightUnits: ref.watch(_getWeightUnitsUseCaseProvider),
    editId: editId,
    initialState: initialState,
  );
});
