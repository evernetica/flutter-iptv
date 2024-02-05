class EntityUser {
  EntityUser({
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

  String? code;
  String? deviceId;
  String? email;
  String? fullName;
  String? ip;
  String? registered;
  String? idSerial;
  String? purchase;
  String? trialStartTime;
  String? trialFinishTime;
  String? deviceId2;
  String? deviceId3;
  String? isParentalControlActive;
  String? passParentalControl;
}
