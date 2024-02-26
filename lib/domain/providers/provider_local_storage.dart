import 'package:giptv_flutter/domain/repo_response.dart';
import 'package:giptv_flutter/domain/repositories_i/i_repository_local_storage.dart';

class ProviderLocalStorage {
  ProviderLocalStorage({
    required IRepositoryLocalStorage repository,
  }) : _repository = repository;

  final IRepositoryLocalStorage _repository;

  Future<RepoResponse> saveData(Map<String, String> data) =>
      _repository.saveData(data);

  Future<RepoResponse> getData(String data) => _repository.getData(data);
}
