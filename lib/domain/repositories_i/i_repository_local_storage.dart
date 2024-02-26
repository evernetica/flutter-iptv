import 'package:giptv_flutter/domain/repo_response.dart';

abstract class IRepositoryLocalStorage {
  Future<RepoResponse> saveData(Map<String, String> data);

  Future<RepoResponse> getData(String data);
}
