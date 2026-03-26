import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/payroll_config_model.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/remote/payroll_repository.dart';

class PayrollConfigCubit extends Cubit<PayrollConfigStates> {
  final PayrollRepository _repository;

  PayrollConfigCubit(this._repository) : super(PayrollConfigInitialState());

  static PayrollConfigCubit get(context) => BlocProvider.of(context);

  PayrollConfigModel? config;

  // ---------------------------------------------------------------------------
  // Load config for a company (or create defaults)
  // ---------------------------------------------------------------------------
  Future<void> loadConfig(String companyId) async {
    emit(PayrollConfigLoadingState());
    try {
      config = await _repository.getPayrollConfig(companyId);
      config ??= PayrollConfigModel.defaults(companyId: companyId);
      emit(PayrollConfigLoadedState());
    } catch (e) {
      emit(PayrollConfigErrorState(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Save config
  // ---------------------------------------------------------------------------
  Future<void> saveConfig({
    required String companyId,
    required double absenceMultiplier,
    required int lateGracePeriodMinutes,
    required String lateDeductionMode,
    required double lateDeductionValue,
    required int overtimeMinMinutes,
    required double overtimeBonusPercentage,
    required String earlyLeaveDeductionMode,
    required double earlyLeaveDeductionValue,
    required String missingCheckoutPolicy,
  }) async {
    emit(PayrollConfigLoadingState());
    try {
      config = PayrollConfigModel(
        companyId: companyId,
        absenceMultiplier: absenceMultiplier,
        lateGracePeriodMinutes: lateGracePeriodMinutes,
        lateDeductionMode: lateDeductionMode,
        lateDeductionValue: lateDeductionValue,
        overtimeMinMinutes: overtimeMinMinutes,
        overtimeBonusPercentage: overtimeBonusPercentage,
        earlyLeaveDeductionMode: earlyLeaveDeductionMode,
        earlyLeaveDeductionValue: earlyLeaveDeductionValue,
        missingCheckoutPolicy: missingCheckoutPolicy,
      );
      await _repository.savePayrollConfig(config!);
      emit(PayrollConfigSavedState());
    } catch (e) {
      emit(PayrollConfigErrorState(e.toString()));
    }
  }
}
