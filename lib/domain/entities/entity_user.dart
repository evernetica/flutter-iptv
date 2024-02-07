class EntityUser {
  const EntityUser({
    required this.code,
    required this.deviceId,
    required this.email,
    required this.fullName,
    required this.ip,
    required this.registered,
    required this.idSerial,
    required this.purchase,
    required this.trialStartTime,
    required this.trialFinishTime,
    required this.deviceId2,
    required this.deviceId3,
    required this.isParentalControlActive,
    required this.passParentalControl,
  });

  final String? code;
  final String? deviceId;
  final String? email;
  final String? fullName;
  final String? ip;
  final String? registered;
  final String? idSerial;
  final String? purchase;
  final String? trialStartTime;
  final String? trialFinishTime;
  final String? deviceId2;
  final String? deviceId3;
  final String? isParentalControlActive;
  final String? passParentalControl;
}
