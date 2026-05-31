import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/weight_unit_repository_provider.dart';
import 'package:fresh_market/domain/entities/weight_unit.entity.dart';
import 'package:fresh_market/domain/usecases/weight_unit/get_weight_units.usecase.dart';

final _getWeightUnitsUseCaseProvider = Provider<GetWeightUnitsUseCase>((ref) {
  final repo = ref.watch(weightUnitRepositoryProvider);
  return GetWeightUnitsUseCase(repository: repo);
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

  WeightUnitListNotifier({
    required GetWeightUnitsUseCase getWeightUnits,
  })  : _getWeightUnits = getWeightUnits,
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
}

final weightUnitListProvider =
    StateNotifierProvider<WeightUnitListNotifier, WeightUnitListState>((ref) {
  return WeightUnitListNotifier(
    getWeightUnits: ref.watch(_getWeightUnitsUseCaseProvider),
  );
});
