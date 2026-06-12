class SocialPostEntity {
  final String userName;
  final String avatar;
  final String content;
  final String timeAgo;
  final bool isAchievement;
  int likes;
  bool isLiked = false;

  SocialPostEntity({
    required this.userName,
    required this.avatar,
    required this.content,
    required this.timeAgo,
    this.isAchievement = false,
    required this.likes,
  });
}
