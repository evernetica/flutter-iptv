import 'package:equatable/equatable.dart';

enum LoginStage {
  initial,
  main,
  generateCode,
  ban,
}

class StateLogin extends Equatable {
  const StateLogin({
    this.stage = LoginStage.initial,
  });

  StateLogin copyWith({
    LoginStage? stage,
  }) =>
      StateLogin(
        stage: stage ?? this.stage,
      );

  final LoginStage stage;

  @override
  List<Object?> get props => [
        stage,
      ];
}
