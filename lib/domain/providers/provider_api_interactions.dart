import 'package:flutter_iptv/domain/entities/entity_category.dart';
import 'package:flutter_iptv/domain/entities/entity_channel.dart';
import 'package:flutter_iptv/domain/entities/entity_fav_channel.dart';
import 'package:flutter_iptv/domain/entities/entity_radio_station.dart';
import 'package:flutter_iptv/domain/entities/entity_user.dart';
import 'package:flutter_iptv/domain/entities/entity_website.dart';
import 'package:flutter_iptv/domain/repo_response.dart';
import 'package:flutter_iptv/domain/repositories_i/i_repository_api_interactions.dart';

class ProviderApiInteractions {
  ProviderApiInteractions({
    required IRepositoryApiInteractions repository,
  }) : _repository = repository;

  final IRepositoryApiInteractions _repository;

  Future<String> register({
    required String email,
    required String fullName,
    required String deviceId,
    required String ip,
  }) =>
      _repository.register(
        email: email,
        fullName: fullName,
        deviceId: deviceId,
        ip: ip,
      );

  Future<bool> checkRegisteredEmail(String email) =>
      _repository.checkRegisteredEmail(email);

  Future<bool> checkBannedIp(String ipAddress) =>
      _repository.checkBannedIp(ipAddress);

  /// Device types [deviceType]:
  /// phone,
  /// tablet,
  /// tv
  Future<RepoResponse<EntityUser>> login(
    String code,
  ) =>
      _repository.login(
        code,
      );

  Future<List<EntityCategory>> getCategories(String code) =>
      _repository.getCategories(code);

  Future<EntityWebsite> getWebsite() => _repository.getWebsite();

  Future<List<EntityChannel>> getChannelsByCategory(
    String categoryId,
    String categoryName,
    String code,
  ) =>
      _repository.getChannelsByCategory(categoryId, categoryName, code);

  Future<List<EntityRadioStation>> getRadioStations(String code) =>
      _repository.getRadioStations(code);

  Future<List<EntityFavChannel>> getFavorites(String idSerial) =>
      _repository.getFavorites(idSerial);

  Future removeFav({
    required String idSerial,
    required String link,
  }) =>
      _repository.removeFav(
        idSerial,
        link,
      );

  Future addFav({
    required String idSerial,
    required String title,
    required String link,
    required String channelId,
  }) =>
      _repository.addFav(
        idSerial,
        title,
        link,
        channelId,
      );

  Future<bool?> setTrueToParentalControl(
    String code,
  ) =>
      _repository.setTrueToParentalControl(code);

  Future<bool?> setFalseToParentalControl(
    String code,
  ) =>
      _repository.setFalseToParentalControl(code);

  Future<bool?> removeAccount(
    String code,
  ) =>
      _repository.removeAccount(code);

  Future<bool?> sendSupport(
    String idSerial,
    String text,
  ) =>
      _repository.sendSupport(
        idSerial,
        text,
      );

  //TODO: probably delete?
  Future<EntityUser> getUser(
    String code,
    String fullName,
  ) =>
      _repository.getUser(
        code,
        fullName,
      );

  Future getEpg(
    String code,
  ) =>
      _repository.getEpg(
        code,
      );

  Future updateDeviceId(
    String code,
    String deviceId,
    String deviceType,
  ) =>
      _repository.updateDeviceId(
        code,
        deviceId,
        deviceType,
      );

  Future setRegisteredUser(
    String code,
    String trialStartTime,
    String trialFinishTime,
  ) =>
      _repository.setRegisteredUser(
        code,
        trialStartTime,
        trialFinishTime,
      );
}
