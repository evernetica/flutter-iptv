import 'package:flutter_iptv/domain/repo_response.dart';

abstract class IRepositoryLocalStorage {
  Future<RepoResponse> saveData(Map<String, String> data);

  Future<RepoResponse> getData(String data);
}
