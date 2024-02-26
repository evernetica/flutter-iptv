class RepoResponse<T> {
  RepoResponse({
    required this.isSuccessful,
    this.repoFailure,
    this.output,
  }) {
    assert((isSuccessful && output != null) ||
        (!isSuccessful && repoFailure != null));
  }

  final bool isSuccessful;
  final RepoFailure? repoFailure;
  final T? output;

  bool get isFailed => !isSuccessful;
}

class RepoFailure {
  RepoFailure({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final dynamic data;
}
