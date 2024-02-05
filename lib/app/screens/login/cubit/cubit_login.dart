import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giptv_flutter/app/screens/login/cubit/state_login.dart';

class CubitLogin extends Cubit<StateLogin> {
  CubitLogin() : super(const StateLogin());

  void goToMainStage() {
    emit(state.copyWith(stage: LoginStage.main));
  }

  void goToGenerateCodeStage() {
    emit(state.copyWith(stage: LoginStage.generateCode));
  }

  void goToBanStage() {
    emit(state.copyWith(stage: LoginStage.ban));
  }
}
