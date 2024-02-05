class EntityChannel {
  EntityChannel({
    required this.num,
    required this.name,
    required this.streamType,
    required this.streamId,
    required this.streamIcon,
    required this.epgChannelId,
    required this.added,
    required this.customSid,
    required this.tvArchive,
    required this.directSource,
    required this.tvArchiveDuration,
    required this.categoryId,
    required this.categoryIds,
    required this.thumbnail,
    required this.videoUrl,
  });

  int num;
  String name;
  String streamType;
  int streamId;
  String streamIcon;
  String? epgChannelId;
  String added;
  String customSid;
  int tvArchive;
  String directSource;
  int tvArchiveDuration;
  String categoryId;
  List<int> categoryIds;
  String thumbnail;

  String videoUrl;
}
