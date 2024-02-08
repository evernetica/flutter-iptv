import 'package:giptv_flutter/domain/entities/entity_category.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/entities/entity_website.dart';

abstract class IRepositoryApiInteractions {
  Future<String> register({
    required String email,
    required String fullName,
    required String deviceId,
    required String ip,
  });

  Future<bool> checkRegisteredEmail(String email);

  Future<bool> checkBannedIp(String ipAddress);

  Future<EntityUser> login(String code);

  Future<List<EntityCategory>> getCategories();

  Future<EntityWebsite> getWebsite();

  Future<List<EntityChannel>> getChannelsByCategory(String categoryId);

  Future<List<EntityRadioStation>> getRadioStations(String code);

  Future<List<EntityFavChannel>> getFavorites(String idSerial);

  Future removeFav(
    String idSerial,
    String link,
  );

  Future addFav(
    String idSerial,
    String title,
    String link,
    String channelId,
  );

  Future<bool?> setTrueToParentalControl(
    String code,
  );

  Future<bool?> setFalseToParentalControl(
    String code,
  );

  Future<bool?> removeAccount(
    String code,
  );

  Future<bool?> sendSupport(
    String idSerial,
    String text,
  );

  Future<EntityUser> getUser(
    String code,
    String fullName,
  );
}
