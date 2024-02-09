import 'dart:convert';
import 'dart:math';

import 'package:format/format.dart';
import 'package:giptv_flutter/domain/entities/entity_category.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_custom_link.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/entities/entity_website.dart';
import 'package:giptv_flutter/domain/repositories_i/i_repository_api_interactions.dart';
import 'package:http/http.dart';

//TODO: add error handlers
//TODO: move entities creation to convertors

class ImplRepositoryGiptvApiInteractions implements IRepositoryApiInteractions {
  EntityCustomLink? customLink;

  @override
  Future<String> register({
    required String email,
    required String fullName,
    required String deviceId,
    required String ip,
  }) async {
    Random rand = Random(DateTime.now().millisecond);
    String code = "${((1 + rand.nextInt(2)) * 10000) + rand.nextInt(10000)}";
    String passParentalControl = format(
      "{:04d}",
      rand.nextInt(10000),
    );

    Request request = Request(
      "POST",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/serials/register.php",
      ),
    );

    request.headers.addAll(
      {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    request.bodyFields = {
      "email": email,
      "fullname": fullName,
      "deviceId": deviceId,
      "code": code,
      "ip": ip,
      "passParentalControl": passParentalControl,
    };

    Response response = await Response.fromStream(await request.send());

    Map resMap = jsonDecode(response.body);

    print("$code :: ${response.body}");

    if (resMap["status"] == 1) {
      return resMap.toString();
    } else {
      if (resMap["Action"] == "DCS") {
        //TODO: maybe delete?
        bool isEmailCorrect = !(await checkRegisteredEmail(email));

        return isEmailCorrect
            ? await register(
                email: email,
                fullName: fullName,
                deviceId: deviceId,
                ip: ip,
              )
            : "0";
      }
      return "0";
    }
  }

  @override
  Future<bool> checkRegisteredEmail(String email) async {
    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/serials/checkDeplicatedEmail.php",
        queryParameters: {
          "email": email,
        },
      ),
    );

    request.headers.addAll(
      {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    Response response = await Response.fromStream(await request.send());

    Map resMap = jsonDecode(response.body);

    return resMap["status"] == 1;
  }

  @override
  Future<bool> checkBannedIp(String ipAddress) async {
    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/bannedIp/checkUserifBanned.php",
        queryParameters: {
          "ip": ipAddress,
        },
      ),
    );

    request.headers.addAll(
      {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    Response response = await Response.fromStream(await request.send());

    return jsonDecode(response.body)["status"] == 1;
  }

  @override
  Future<EntityUser> login(String code) async {
    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/serials/getUser1.php",
        queryParameters: {
          "code": code,
        },
      ),
    );

    request.headers.addAll(
      {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    Response response = await Response.fromStream(await request.send());

    Map resMap = jsonDecode(response.body)["Users"].first;

    print(response.body);

    EntityUser user = EntityUser(
      code: resMap["code"],
      deviceId: resMap["deviceId"],
      email: resMap["email"],
      fullName: resMap["fullName"],
      ip: resMap["ip"],
      registered: resMap["registred"],
      idSerial: resMap["IdSerial"],
      purchase: resMap["purchase"],
      trialStartTime: resMap["trial_start_time"],
      trialFinishTime: resMap["trial_finish_time"],
      deviceId2: resMap["deviceId2"],
      deviceId3: resMap["deviceId3"],
      isParentalControlActive: resMap["isParentalControlActive"],
      passParentalControl: resMap["passParentalControl"],
    );

    print(user);

    return user;
  }

  Future _getCustomLink(String code) async {
    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/customChannels/getCustomList.php",
        queryParameters: {
          "email": code,
        },
      ),
    );

    request.headers.addAll(
      {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    Response response = await Response.fromStream(await request.send());

    Iterable linkList = jsonDecode(response.body)["CustomList"];

    Map linkMap = linkList.first;

    customLink = EntityCustomLink(
      link: linkMap['link'],
      nameFile: linkMap['nameFile'],
      type: linkMap['type'],
      password: linkMap['password'],
      port: linkMap['port'],
      username: linkMap['username'],
      fileUrl: linkMap['fileUrl'],
    );
  }

  @override
  Future<List<EntityCategory>> getCategories(String code) async {
    if (customLink == null) await _getCustomLink(code);

    List<EntityCategory> output = [];

    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/xsteam/xsteam_api.php",
        queryParameters: {
          "op": "category_channels",
          "username": customLink!.username,
          "password": customLink!.password,
          "fileUrl": "${customLink!.fileUrl}:${customLink!.port}",
        },
      ),
    );

    Response response = await Response.fromStream(await request.send());

    Iterable categories = jsonDecode(response.body);

    print(response.body);

    for (Map categoryMap in categories) {
      output.add(
        EntityCategory(
          categoryId: categoryMap["category_id"],
          categoryName: categoryMap["category_name"],
          parentId: categoryMap["parent_id"],
        ),
      );
    }

    return output;
  }

  @override
  Future<EntityWebsite> getWebsite() async {
    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/config/getSiteWebLink.php",
      ),
    );

    Response response = await Response.fromStream(await request.send());

    Map resMap = jsonDecode(response.body)["WebSite"].first;

    EntityWebsite output = EntityWebsite(
      content: resMap["content"],
      visible: resMap["visible"],
      name: resMap["name"],
    );

    return output;
  }

  @override
  Future<List<EntityChannel>> getChannelsByCategory(
    String categoryId,
    String code,
  ) async {
    if (customLink == null) await _getCustomLink(code);

    List<EntityChannel> output = [];

    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/xsteam/xsteam_api.php",
        queryParameters: {
          "op": "channels",
          "username": customLink!.username,
          "password": customLink!.password,
          "fileUrl": "${customLink!.fileUrl}:${customLink!.port}",
          "category": categoryId,
        },
      ),
    );

    Response response = await Response.fromStream(await request.send());

    Iterable channels = jsonDecode(response.body);

    for (Map c in channels) {
      output.add(
        EntityChannel(
          num: c["num"],
          name: c["name"],
          streamType: c["stream_type"],
          streamId: c["stream_id"],
          streamIcon: c["stream_icon"],
          epgChannelId: c["epg_channel_id"],
          added: c["added"],
          customSid: c["custom_sid"],
          tvArchive: c["tv_archive"],
          directSource: c["direct_source"],
          tvArchiveDuration: c["tv_archive_duration"],
          categoryId: c["category_id"],
          categoryIds: <int>[...c["category_ids"]],
          thumbnail: c["thumbnail"],
          videoUrl: "${customLink!.fileUrl}:${customLink!.port}"
              "/live/${customLink!.username}/${customLink!.password}"
              "/${c["stream_id"]}.m3u8",
        ),
      );
    }

    return output;
  }

  @override
  Future<List<EntityRadioStation>> getRadioStations(String code) async {
    List<EntityRadioStation> output = [];

    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/radios/getCustomRadios.php",
        queryParameters: {
          "code": code,
        },
      ),
    );

    Response response = await Response.fromStream(await request.send());

    Map resMap = jsonDecode(response.body);

    for (Map station in resMap["Radios"]) {
      output.add(
        EntityRadioStation(
          radioName: station["radioName"],
          radioImgLink: station["radioImgLink"],
          radioStreamUrl: station["radioStreamUrl"],
        ),
      );
    }

    return output;
  }

  @override
  Future<List<EntityFavChannel>> getFavorites(String idSerial) async {
    List<EntityFavChannel> output = [];

    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/fav/getMyFav.php",
        queryParameters: {
          "IdSerial": idSerial,
        },
      ),
    );

    Response response = await Response.fromStream(await request.send());

    Map resMap = jsonDecode(response.body);

    for (Map fav in resMap["FavList"]) {
      output.add(
        EntityFavChannel(
          titleChannel: fav["titleChannel"],
          linkChannel: fav["linkChannel"],
          channelId: fav["channelId"],
        ),
      );
    }

    return output;
  }

  @override
  Future removeFav(
    String idSerial,
    String link,
  ) async {
    print("removeFav");
    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/fav/removeFav.php",
        queryParameters: {
          'link': link,
          'IdSerial': idSerial,
        },
      ),
    );

    request.headers.addAll(
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    print("send removeFav");
    Response response = await Response.fromStream(await request.send());
    print("response removeFav :: ${response.body}");
    return;
  }

  @override
  Future addFav(
    String idSerial,
    String title,
    String link,
    String channelId,
  ) async {
    print("addFav");

    Request request = Request(
      "POST",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/fav/sendFav.php",
      ),
    );

    request.headers.addAll(
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    request.bodyFields = {
      'link': link,
      'IdSerial': idSerial,
      'title': title,
      'channelId': channelId,
    };

    print("send addFav :: ${request.body}");
    Response response = await Response.fromStream(await request.send());
    print("response addFav :: ${response.body}");
    return;
  }

  @override
  Future<bool?> setTrueToParentalControl(
    String code,
  ) async {
    print("set true");

    Request request = Request(
      "POST",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/serials/setTrueToParentalControl.php",
      ),
    );

    request.headers.addAll(
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    request.bodyFields = {'code': code};

    Response response = await Response.fromStream(await request.send());

    print(response.body);

    if (jsonDecode(response.body)["status"] == 1) return true;

    return false;
  }

  @override
  Future<bool?> setFalseToParentalControl(
    String code,
  ) async {
    print("set false");
    Request request = Request(
      "POST",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/serials/setFalseToParentalControl.php",
      ),
    );

    request.headers.addAll(
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    request.bodyFields = {'code': code};

    Response response = await Response.fromStream(await request.send());

    print(response.body);

    if (jsonDecode(response.body)["status"] == 1) return true;

    return false;
  }

  @override
  Future<bool?> removeAccount(
    String code,
  ) async {
    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/serials/removeAccount.php",
        queryParameters: {
          "code": code,
        },
      ),
    );

    request.headers.addAll(
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    Response response = await Response.fromStream(await request.send());

    if (jsonDecode(response.body)["status"] == 1) return true;

    return false;
  }

  @override
  Future<bool?> sendSupport(
    String idSerial,
    String text,
  ) async {
    print("send message $idSerial");
    print(text);

    Request request = Request(
      "POST",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/support/sendSupport.php",
      ),
    );

    request.headers.addAll(
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    request.bodyFields = {
      'IdSerial': idSerial,
      'text': text,
    };

    Response response = await Response.fromStream(await request.send());

    print(response.body);

    return true;
  }

  @override
  Future<EntityUser> getUser(
    String code,
    String fullName,
  ) async {
    Request request = Request(
      "GET",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/serials/getUser.php",
        queryParameters: {
          "code": code,
          "fullname": fullName,
        },
      ),
    );

    request.headers.addAll(
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    Response response = await Response.fromStream(await request.send());

    print(response.body);

    Map resMap = jsonDecode(response.body)["Users"].first;

    EntityUser user = EntityUser(
      code: resMap["code"],
      deviceId: resMap["deviceId"],
      email: resMap["email"],
      fullName: resMap["fullName"],
      ip: resMap["ip"],
      registered: resMap["registred"],
      idSerial: resMap["IdSerial"],
      purchase: resMap["purchase"],
      trialStartTime: resMap["trial_start_time"],
      trialFinishTime: resMap["trial_finish_time"],
      deviceId2: resMap["deviceId2"],
      deviceId3: resMap["deviceId3"],
      isParentalControlActive: resMap["isParentalControlActive"],
      passParentalControl: resMap["passParentalControl"],
    );

    print(user);

    return user;
  }
}

/*

    @GET("serials/getUser.php")
    Call<Users> getUserByCode(@Header("Content-Type") String str, @Query("code") String code,@Query("fullname") String fullname);

*/
