import '../database/app_database.dart';

enum DownloadState {
  queued,
  downloading,
  paused,
  completed,
  failed;

  static DownloadState parse(String value) => values.firstWhere(
    (state) => state.name == value,
    orElse: () => DownloadState.failed,
  );
}

extension DownloadJobRecordState on DownloadJobRecord {
  DownloadState get downloadState => DownloadState.parse(state);

  double? get progress => totalBytes == null || totalBytes! <= 0
      ? null
      : (bytesDownloaded / totalBytes!).clamp(0, 1);
}

class DownloadException implements Exception {
  const DownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LowStorageException extends DownloadException {
  const LowStorageException()
    : super('Not enough free storage to download this episode.');
}
