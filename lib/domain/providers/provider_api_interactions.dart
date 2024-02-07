import 'package:giptv_flutter/domain/entities/entity_category.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/entities/entity_website.dart';
import 'package:giptv_flutter/domain/repositories_i/i_repository_api_interactions.dart';

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

  Future<EntityUser> login(String code) => _repository.login(code);

  Future<List<EntityCategory>> getCategories() => _repository.getCategories();

  Future<EntityWebsite> getWebsite() => _repository.getWebsite();

  Future<List<EntityChannel>> getChannelsByCategory(String categoryId) =>
      _repository.getChannelsByCategory(categoryId);

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
}
