import 'dart:convert';
import 'dart:math';

//TODO: REMOVE MOCKED RESPONSES AFTER THE API IS FIXED

import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:format/format.dart';
import 'package:giptv_flutter/data/models/model_file_link.dart';
import 'package:giptv_flutter/domain/entities/entity_category.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_custom_link.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/entities/entity_website.dart';
import 'package:giptv_flutter/domain/repo_response.dart';
import 'package:giptv_flutter/domain/repositories_i/i_repository_api_interactions.dart';
import 'package:http/http.dart';

//TODO: add error handlers
//TODO: move entities creation to convertors

enum CustomListSource {
  notInitialized,
  file,
  link,
  error,
}

class ImplRepositoryGiptvApiInteractions implements IRepositoryApiInteractions {
  CustomListSource listSource = CustomListSource.notInitialized;
  EntityCustomLink? customLink;
  List<ModelFileLink> fileLinks = [];

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
      return "Registration successful!\n"
          "Your code: $code\n"
          "Parental control password: $passParentalControl";
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
    return false;
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

    return RepoResponse(
      isSuccessful: true,
      output: user,
    );
  }

  Future _getCustomLink(String code) async {
    return;
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

    print(response.body);

    for (var a in linkList) {
      print(a);
    }

    Map linkMap = linkList.first;

    for (MapEntry entry in linkMap.entries) print(entry);

    customLink = EntityCustomLink(
      link: linkMap['link'],
      nameFile: linkMap['nameFile'],
      type: linkMap['type'],
      password: linkMap['password'] ?? "",
      port: linkMap['port'] ?? "",
      username: linkMap['username'] ?? "",
      fileUrl: linkMap['fileUrl'] ?? "",
    );

    bool isListFile = customLink!.type == "list-m3u";

    if (isListFile) {
      listSource = CustomListSource.file;

      Request request = Request(
        "GET",
        Uri(
          scheme: "https",
          host: "giptv.ro",
          path: customLink!.link,
        ),
      );

      Response response = await Response.fromStream(await request.send());
      String m3uStr = response.body.replaceAll("#EXTINF:-1", "#EXTINF:0");

      if (isListFile) {
        Uri playlistUri = Uri();
        HlsPlaylist playList;
        print("start parser");
        try {
          playList =
              await HlsPlaylistParser.create().parseString(playlistUri, m3uStr);
        } on ParserException catch (e) {
          print(e);
          return [];
        }
        print("end parser");

        if (playList is HlsMasterPlaylist) {
          // master m3u8 file
          print("#### master");
          for (var segment in playList.tags) {
            print(segment);
          }
        } else if (playList is HlsMediaPlaylist) {
          // media m3u8 file
          print(
              "#### media ${playList.tags.length} / ${playList.segments.length}");

          List<String> tags = [
            ...playList.tags.where((s) => s.startsWith("#EXTINF")),
          ];
          List<String> urls = [];
          for (var segment in playList.segments) {
            urls.add(segment.url!);
          }

          for (int i = 0; i < tags.length; i++) {
            /*

            parsing:

                #EXTINF:0 xui-id="23485" tvg-id="" tvg-name="KAPITAL TV" tvg-logo="" group-title="ROMANIA",KAPITAL TV

            */

            List<String> splitTag = tags[i].split('"');

            String xuiId =
                splitTag[splitTag.indexWhere((s) => s.contains("xui-id=")) + 1];
            String tvgId =
                splitTag[splitTag.indexWhere((s) => s.contains("tvg-id=")) + 1];
            String tvgName = splitTag[
                splitTag.indexWhere((s) => s.contains("tvg-name=")) + 1];
            String tvgLogo = splitTag[
                splitTag.indexWhere((s) => s.contains("tvg-logo=")) + 1];
            String groupTitle = splitTag[
                splitTag.indexWhere((s) => s.contains("group-title=")) + 1];
            String id = splitTag.last.substring(1);

            fileLinks.add(
              ModelFileLink(
                xuiId: xuiId,
                tvgId: tvgId,
                tvgName: tvgName,
                tvgLogo: tvgLogo,
                groupTitle: groupTitle,
                id: id,
                url: urls[i],
              ),
            );
          }

          print("fileLinks :: ${fileLinks.length}");
        }

        return;
      }
    } else {
      listSource = CustomListSource.link;
    }
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

    if (listSource == CustomListSource.notInitialized) {
      await _getCustomLink(code);
    }

    List<EntityCategory> output = [];

    if (listSource == CustomListSource.link) {
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
    } else {
      Set<String> categoryNames = {};

      for (ModelFileLink link in fileLinks) {
        categoryNames.add(link.groupTitle ?? "");
      }

      for (String name in categoryNames) {
        output.add(
          EntityCategory(
            categoryId: name,
            categoryName: name,
            parentId: -1,
          ),
        );
      }

      return output;
    }
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

    if (listSource == CustomListSource.notInitialized) {
      await _getCustomLink(code);
    }

    List<EntityChannel> output = [];

    if (listSource == CustomListSource.link) {
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

      print("### \n $categoryId \n ###");
      print("num ${output.first.num}");
      print("name ${output.first.name}");
      print("streamType ${output.first.streamType}");
      print("streamId ${output.first.streamId}");
      print("streamIcon ${output.first.streamIcon}");
      print("epgChannelId ${output.first.epgChannelId}");
      print("added ${output.first.added}");
      print("customSid ${output.first.customSid}");
      print("tvArchive ${output.first.tvArchive}");
      print("directSource ${output.first.directSource}");
      print("tvArchiveDuration ${output.first.tvArchiveDuration}");
      print("categoryId ${output.first.categoryId}");
      print("categoryIds ${output.first.categoryIds}");
      print("thumbnail ${output.first.thumbnail}");
      print("videoUrl ${output.first.videoUrl}");
      print("*** \n ***");

      return output;
    } else {
      for (ModelFileLink link in fileLinks) {
        print("${link.groupTitle!} :: $categoryName");
        print("${!link.groupTitle!.contains(categoryName)}");

        if (!link.groupTitle!.contains(categoryName)) continue;
        output.add(
          EntityChannel(
            num: 0,
            name: link.tvgName!,
            streamType: "",
            streamId: int.parse(link.xuiId!),
            streamIcon: "",
            epgChannelId: "",
            added: "",
            customSid: "",
            tvArchive: 0,
            directSource: "",
            tvArchiveDuration: 0,
            categoryId: "",
            categoryIds: [],
            thumbnail: link.tvgLogo!,
            videoUrl: link.url!,
          ),
        );
        print("added!!!");
      }

      return output;
    }
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

  @override
  Future getEpg(String code) async {
    return;
    if (customLink == null) await _getCustomLink(code);

    Uri link = Uri.parse(customLink!.link);

    Request request = Request(
      "GET",
      Uri(
        scheme: "http",
        host: link.host,
        port: link.port,
        path: "xmltv.php",
        queryParameters: {
          "username": customLink!.username,
          "password": customLink!.password,
        },
      ),
    );

    Response response = await Response.fromStream(await request.send());

    print("EPG:");
    print(response.body);
  }

  @override
  Future updateDeviceId(
    String code,
    String deviceId,
    String deviceType,
  ) async {
    String id = "0";

    switch (deviceId) {
      case ("phone"):
        id = "1";
        break;
      case ("tv"):
        id = "2";
        break;
      case ("tablet"):
        id = "3";
        break;
    }

    Request request = Request(
      "POST",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/serials/setDeviceId.php",
      ),
    );

    request.headers.addAll(
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    request.bodyFields = {
      'code': code,
      'deviceId': deviceId,
      'id': id,
    };

    Response response = await Response.fromStream(await request.send());
  }

  @override
  Future setRegisteredUser(
    String code,
    String trialStartTime,
    String trialFinishTime,
  ) async {
    Request request = Request(
      "POST",
      Uri(
        scheme: "https",
        host: "giptv.ro",
        path: "admin/api/serials/setRegisteredUser.php",
      ),
    );

    request.headers.addAll(
      {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    request.bodyFields = {
      'code': code,
      'trial_start_time': trialStartTime,
      'trial_finish_time': trialFinishTime,
    };

    Response response = await Response.fromStream(await request.send());
  }
}

/*

    @FormUrlEncoded
    @POST("serials/setRegisteredUser.php")
    Call<ResponsePHP> setRegisteredUser(@Header("Content-Type") String str, @Field("code") String code, @Field("trial_start_time") String trial_start_time,
                                        @Field("trial_finish_time") String trial_finish_time);


  legacy:      http://www.iptvrestream.online:88/xmltv.php?username=nicunicu3&password=nicunicu3

  new: http://www.iptvrestream.online:88/get.php?username=nicunicu3&password=nicunicu3&type=m3u_plus


*/
