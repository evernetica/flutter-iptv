import 'package:flutter_iptv/domain/entities/entity_category.dart';
import 'package:flutter_iptv/domain/entities/entity_channel.dart';
import 'package:flutter_iptv/domain/entities/entity_fav_channel.dart';
import 'package:flutter_iptv/domain/entities/entity_radio_station.dart';
import 'package:flutter_iptv/domain/entities/entity_user.dart';
import 'package:flutter_iptv/domain/entities/entity_website.dart';
import 'package:flutter_iptv/domain/repo_response.dart';
import 'package:flutter_iptv/domain/repositories_i/i_repository_api_interactions.dart';

class ImplRepositoryMockDataApiInteractions
    implements IRepositoryApiInteractions {
  @override
  Future<String> register({
    required String email,
    required String fullName,
    required String deviceId,
    required String ip,
  }) async {
    return "0";
  }

  @override
  Future<bool> checkRegisteredEmail(String email) async {
    return true;
  }

  @override
  Future<bool> checkBannedIp(String ipAddress) async {
    return false;
  }

  @override
  Future<RepoResponse<EntityUser>> login(
    String code,
  ) async {
    return RepoResponse(
      isSuccessful: true,
      output: const EntityUser(
        code: "00000",
        deviceId: "",
        email: "example@email.com",
        fullName: "Example Preview",
        ip: "",
        registered: "1",
        idSerial: "",
        purchase: "1",
        trialStartTime: "",
        trialFinishTime: "",
        deviceId2: "",
        deviceId3: "",
        isParentalControlActive: "",
        passParentalControl: "",
      ),
    );
  }

  @override
  Future<List<EntityCategory>> getCategories(String code) async {
    return [
      ...List.generate(
        10,
        (i) => EntityCategory(
          categoryId: '$i',
          categoryName: 'Category $i',
          parentId: -1,
        ),
      ),
    ];
  }

  @override
  Future<EntityWebsite> getWebsite() async {
    EntityWebsite output = const EntityWebsite(
      content: "",
      visible: "0",
      name: "",
    );

    return output;
  }

  @override
  Future<List<EntityChannel>> getChannelsByCategory(
    String categoryId,
    String categoryName,
    String code,
  ) async {
    return [
      ...List.generate(
        16,
        (i) => EntityChannel(
          num: i,
          name: 'Channel $i',
          streamType: '',
          streamId: 1,
          streamIcon: '',
          epgChannelId: '',
          added: '',
          customSid: '',
          tvArchive: 0,
          directSource: '',
          tvArchiveDuration: 0,
          categoryId: '',
          categoryIds: [],
          thumbnail: '',
          videoUrl: '',
        ),
      ),
    ];
  }

  @override
  Future<List<EntityRadioStation>> getRadioStations(String code) async {
    List<EntityRadioStation> output = [];
    return output;
  }

  @override
  Future<List<EntityFavChannel>> getFavorites(String idSerial) async {
    List<EntityFavChannel> output = [];
    return output;
  }

  @override
  Future removeFav(
    String idSerial,
    String link,
  ) async {
    return;
  }

  @override
  Future addFav(
    String idSerial,
    String title,
    String link,
    String channelId,
  ) async {
    return;
  }

  @override
  Future<bool?> setTrueToParentalControl(
    String code,
  ) async {
    return false;
  }

  @override
  Future<bool?> setFalseToParentalControl(
    String code,
  ) async {
    return false;
  }

  @override
  Future<bool?> removeAccount(
    String code,
  ) async {
    return false;
  }

  @override
  Future<bool?> sendSupport(
    String idSerial,
    String text,
  ) async {
    return true;
  }

  @override
  Future<EntityUser> getUser(
    String code,
    String fullName,
  ) async {
    return const EntityUser(
      code: "00000",
      deviceId: "",
      email: "example@email.com",
      fullName: "Example Preview",
      ip: "",
      registered: "1",
      idSerial: "",
      purchase: "1",
      trialStartTime: "",
      trialFinishTime: "",
      deviceId2: "",
      deviceId3: "",
      isParentalControlActive: "",
      passParentalControl: "",
    );
  }

  @override
  Future getEpg(String code) async {
    return;
  }

  @override
  Future updateDeviceId(
    String code,
    String deviceId,
    String deviceType,
  ) async {}

  @override
  Future setRegisteredUser(
    String code,
    String trialStartTime,
    String trialFinishTime,
  ) async {}
}
