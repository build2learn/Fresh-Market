import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/weight_unit.entity.dart';
import 'package:fresh_market/domain/usecases/weight_unit/create_weight_unit.usecase.dart';
import 'package:fresh_market/domain/usecases/weight_unit/update_weight_unit.usecase.dart';
import 'package:fresh_market/domain/usecases/weight_unit/get_weight_units.usecase.dart';

class WeightUnitFormState {
  final String nameAr;
  final String nameEn;
  final String abbr;
  final int sortOrder;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isEditMode;

  const WeightUnitFormState({
    this.nameAr = '',
    this.nameEn = '',
    this.abbr = '',
    this.sortOrder = 0,
    this.isSubmitting = false,
    this.errorMessage,
    this.isEditMode = false,
  });

  bool get isValid =>
      nameAr.trim().isNotEmpty && nameEn.trim().isNotEmpty && abbr.trim().isNotEmpty;

  WeightUnitFormState copyWith({
    String? nameAr,
    String? nameEn,
    String? abbr,
    int? sortOrder,
    bool? isSubmitting,
    String? errorMessage,
    bool? isEditMode,
  }) {
    return WeightUnitFormState(
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      abbr: abbr ?? this.abbr,
      sortOrder: sortOrder ?? this.sortOrder,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  factory WeightUnitFormState.fromEntity(WeightUnitEntity entity) {
    return WeightUnitFormState(
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      abbr: entity.abbr,
      sortOrder: entity.sortOrder,
      isEditMode: true,
    );
  }
}

class WeightUnitFormNotifier extends StateNotifier<WeightUnitFormState> {
  final CreateWeightUnitUseCase _createWeightUnit;
  final UpdateWeightUnitUseCase _updateWeightUnit;
  final GetWeightUnitsUseCase _getWeightUnits;
  final String? _editId;

  WeightUnitFormNotifier({
    required CreateWeightUnitUseCase createWeightUnit,
    required UpdateWeightUnitUseCase updateWeightUnit,
    required GetWeightUnitsUseCase getWeightUnits,
    String? editId,
    WeightUnitFormState? initialState,
  })  : _createWeightUnit = createWeightUnit,
        _updateWeightUnit = updateWeightUnit,
        _getWeightUnits = getWeightUnits,
        _editId = editId,
        super(initialState ?? const WeightUnitFormState()) {
    if (_editId != null && initialState == null) {
      _loadFromRepository();
    }
  }

  void setNameAr(String value) => state = state.copyWith(nameAr: value);
  void setNameEn(String value) => state = state.copyWith(nameEn: value);
  void setAbbr(String value) => state = state.copyWith(abbr: value);

  Future<void> _loadFromRepository() async {
    state = state.copyWith(isSubmitting: true);
    final result = await _getWeightUnits();
    if (result is Success<List<WeightUnitEntity>>) {
      final weightUnit = result.data.cast<WeightUnitEntity?>().firstWhere(
        (u) => u?.id == _editId,
        orElse: () => null,
      );
      if (weightUnit != null) {
        state = WeightUnitFormState.fromEntity(weightUnit);
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Weight unit not found',
        );
      }
    } else if (result is Failure<List<WeightUnitEntity>>) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: result.error.message,
      );
    }
  }

  Future<String?> submit() async {
    if (!state.isValid) return 'Please fill all required fields';

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final entity = WeightUnitEntity(
      id: _editId ?? '',
      nameAr: state.nameAr.trim(),
      nameEn: state.nameEn.trim(),
      abbr: state.abbr.trim(),
      sortOrder: state.sortOrder,
    );

    final Result result;
    if (_editId != null) {
      result = await _updateWeightUnit(entity);
    } else {
      result = await _createWeightUnit(entity);
    }

    if (result is Success) {
      state = state.copyWith(isSubmitting: false);
      return null;
    } else if (result is Failure) {
      final error = result.error;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.message,
      );
      return error.message;
    }

    state = state.copyWith(isSubmitting: false);
    return null;
  }
}
