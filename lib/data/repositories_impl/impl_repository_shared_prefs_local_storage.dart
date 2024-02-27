import 'package:flutter_iptv/domain/repo_response.dart';
import 'package:flutter_iptv/domain/repositories_i/i_repository_local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImplRepositorySharedPrefsLocalStorage extends IRepositoryLocalStorage {
  @override
  Future<RepoResponse> saveData(Map<String, String> data) async {
    var prefs = await SharedPreferences.getInstance();

    Map<String, bool> output = {};

    for (MapEntry entry in data.entries) {
      output.addAll(
        {
          entry.value: await prefs.setString(entry.key, entry.value),
        },
      );
    }

    bool isSuccessful = !output.values.contains(false);

    return RepoResponse(
      isSuccessful: isSuccessful,
      repoFailure: isSuccessful
          ? null
          : RepoFailure(
              code: 0,
              message: "Some entries was not saved correctly",
              data: output,
            ),
      output: isSuccessful ? output : null,
    );
  }

  @override
  Future<RepoResponse> getData(String data) async {
    var prefs = await SharedPreferences.getInstance();

    var output = prefs.get(data);

    bool isSuccessful = output != null;

    return RepoResponse(
      isSuccessful: isSuccessful,
      repoFailure: isSuccessful
          ? null
          : RepoFailure(
              code: 0,
              message: "get() returned null",
              data: output,
            ),
      output: isSuccessful ? output : null,
    );
  }
}
