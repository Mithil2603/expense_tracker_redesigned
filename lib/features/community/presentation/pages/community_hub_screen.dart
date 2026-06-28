import 'package:flutter/material.dart';
import 'package:fingo/features/gamification/domain/entities/animal_league.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/social_post_entity.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../widgets/hub_tab_toggle.dart';

class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  int _selectedTab = 0; // 0 = Quests, 1 = Feed
  final TextEditingController _postCtrl = TextEditingController();
  List<LeaderboardEntry>? _leaderboard;
  bool _isLoadingLeaderboard = true;

  @override
  void initState() {
    super.initState();
    sl<FingoState>().addListener(_refresh);
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final repo = sl<LeaderboardRepository>();
    final xp = sl<FingoState>().xp;
    final entries = await repo.getLeaderboard(xp);
    if (mounted) {
      setState(() {
        _leaderboard = entries;
        _isLoadingLeaderboard = false;
      });
    }
  }

  @override
  void dispose() {
    sl<FingoState>().removeListener(_refresh);
    _postCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _addPost() {
    final text = _postCtrl.text.trim();
    if (text.isEmpty) return;
    sl<FingoState>().addSocialPost(text);
    _postCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Milestone shared globally! 🌎')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = sl<FingoState>();
    final isLight = Theme.of(context).brightness == Brightness.light;
    final outlineColor = isLight
        ? const Color(0xFFE5E5E5)
        : AppColors.outlineDark;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHPadding,
                vertical: 12,
              ),
              child: HubTabToggle(
                selectedIndex: _selectedTab,
                onTabChanged: (val) {
                  setState(() {
                    _selectedTab = val;
                  });
                },
              ),
            ),
            Expanded(
              child: _selectedTab == 0
                  ? _buildQuestsView(state, isLight)
                  : _buildFeedView(state, isLight, outlineColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsView(FingoState state, bool isLight) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: AppSizes.screenHPadding,
        right: AppSizes.screenHPadding,
        bottom: 100, // spacing for bottom bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Mascot Comic Box (Duolingo Style Speech bubble)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/fingo_mascot.png',
                width: 90,
                height: 90,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '🪙',
                      style: TextStyle(fontSize: 40),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  decoration: BoxDecoration(
                    color: isLight
                        ? AppColors.surfaceLight
                        : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusLG,
                    ),
                    border: Border.all(
                      color: isLight
                          ? AppColors.outlineLight
                          : AppColors.outlineDark,
                      width: AppSizes.borderThick,
                    ),
                  ),
                  child: Text(
                    'Break today’s budget rocks to collect rewards and climb the Ruby division! 💎',
                    style: AppTextStyles.bodySM.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Monthly Quest Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'JUNE CHALLENGE',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.accentDark,
                      ),
                    ),
                    const Text('🥚', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Hatch Fingo the Frog',
                  style: AppTextStyles.labelMD.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Harness smart budget habits to earn 100 XP points this month.',
                  style: AppTextStyles.bodySM,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: (state.xp / 100.0).clamp(0.0, 1.0),
                            color: AppColors.accent,
                            backgroundColor: isLight
                                ? const Color(0xFFE5E5E5)
                                : AppColors.bgDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${state.xp}/100 XP',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Daily Quests Header
          Row(
            children: [
              Text("Daily Quests", style: AppTextStyles.h2),
              const SizedBox(width: 6),
              const Icon(
                Icons.rocket_launch_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily Quests (Rock breaking theme)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.quests.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final quest = state.quests[index];

              final String rockIcon;
              if (quest.completed) {
                rockIcon = '🪙';
              } else if (quest.progress > 0) {
                rockIcon = '🔨';
              } else {
                rockIcon = '🪨';
              }

              return AppCard(
                onTap: () {
                  state.completeQuest(quest.id);
                },
                color: quest.completed
                    ? (isLight
                        ? AppColors.successSurfaceLight
                        : AppColors.successSurfaceDark)
                    : null,
                borderColor: quest.completed
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : null,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: quest.completed
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (isLight ? Colors.white : AppColors.bgDark),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: quest.completed
                              ? AppColors.primary
                              : AppColors.outline,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        rockIcon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  quest.title,
                                  style: AppTextStyles.labelMD.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                '+${quest.xpReward} XP',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accentDark,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(quest.description, style: AppTextStyles.bodySM),
                          if (quest.target > 1) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusFull,
                              ),
                              child: SizedBox(
                                height: 6,
                                child: LinearProgressIndicator(
                                  value:
                                      (quest.progress / quest.target).clamp(0.0, 1.0),
                                  color: AppColors.primary,
                                  backgroundColor: isLight
                                      ? const Color(0xFFE5E5E5)
                                      : AppColors.bgDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${quest.progress}/${quest.target}',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          // Duolingo-style horizontal league progression
          SizedBox(
            height: 85,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AnimalLeague.values.length,
              separatorBuilder: (context, idx) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final league = AnimalLeague.values[idx];
                final currentLeague = LeagueUtils.getLeagueForLevel(state.level);
                
                final isFuture = idx > currentLeague.index;
                final isCurrent = idx == currentLeague.index;
                final isPast = idx < currentLeague.index;
                
                final Color borderColor;
                final Color bgColor;
                
                if (isCurrent) {
                  borderColor = AppColors.primary;
                  bgColor = AppColors.primary.withValues(alpha: 0.15);
                } else if (isPast) {
                  borderColor = AppColors.primary.withValues(alpha: 0.4);
                  bgColor = Colors.transparent;
                } else {
                  borderColor = isLight ? AppColors.outlineLight : AppColors.outlineDark;
                  bgColor = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;
                }
                
                return Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bgColor,
                        border: Border.all(
                          color: borderColor,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isFuture
                          ? Icon(
                              Icons.lock_rounded, 
                              color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                              size: 24,
                            )
                          : Opacity(
                              opacity: isPast ? 0.6 : 1.0,
                              child: Text(
                                league.emoji,
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isFuture ? 'Locked' : league.displayName,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                        color: isCurrent 
                            ? AppColors.primary 
                            : (isFuture ? AppColors.textSecondary : AppColors.textPrimary),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Weekly Leaderboard Header
          Row(
            children: [
              Text("Weekly Leaderboard", style: AppTextStyles.h2),
              const SizedBox(width: 6),
              const Text('🏆', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: _isLoadingLeaderboard 
              ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  children: List.generate(_leaderboard!.length, (index) {
                    final entry = _leaderboard![index];
                    final isFirst = index == 0;
                    final isSecond = index == 1;
                    final isThird = index == 2;
                    
                    String medal = '';
                    if (isFirst) medal = '🥇 ';
                    if (isSecond) medal = '🥈 ';
                    if (isThird) medal = '🥉 ';

                    return Column(
                      children: [
                        if (index > 0) const AppDivider(indent: 16),
                        _buildLeaderboardRow(
                          index + 1,
                          '$medal${entry.name}',
                          '${entry.xp} XP',
                          level: entry.level,
                          isCurrentUser: entry.isCurrentUser,
                          isGold: isFirst,
                          isBot: entry.isBot,
                        ),
                      ],
                    );
                  }),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(
    int rank,
    String name,
    String xpText, {
    required int level,
    required bool isCurrentUser,
    bool isGold = false,
    bool isBot = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: AppTextStyles.labelMD.copyWith(
                fontWeight: FontWeight.w900,
                color: isGold
                    ? AppColors.accentDark
                    : (isCurrentUser ? AppColors.primary : Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${LeagueUtils.getLeagueForLevel(level).emoji} $name',
                    style: AppTextStyles.labelMD.copyWith(
                      fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.w700,
                      color: isCurrentUser ? AppColors.primary : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Text(
            xpText,
            style: AppTextStyles.labelMD.copyWith(
              fontWeight: FontWeight.w900,
              color: isCurrentUser ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedView(FingoState state, bool isLight, Color outlineColor) {
    return Column(
      children: [
        // Post creation card
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenHPadding,
          ),
          child: AppCard(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postCtrl,
                    style: AppTextStyles.bodySM,
                    decoration: InputDecoration(
                      hintText:
                          'Share a save, milestone or ask a question...',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppTextStyles.caption,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppIconButton(
                  icon: Icons.send_rounded,
                  color: AppColors.primary,
                  onTap: _addPost,
                  tooltip: 'Post Milestone',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Posts list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(
              left: AppSizes.screenHPadding,
              right: AppSizes.screenHPadding,
              bottom: 100, // spacing for bottom bar
            ),
            itemCount: state.feedItems.length,
            separatorBuilder: (context, idx) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final SocialPostEntity post = state.feedItems[idx];
              return AppCard(
                color: post.isAchievement
                    ? (isLight
                        ? AppColors.successSurfaceLight
                        : AppColors.successSurfaceDark)
                    : null,
                borderColor: post.isAchievement
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isLight
                                ? Colors.white
                                : AppColors.bgDark,
                            shape: BoxShape.circle,
                            border: Border.all(color: outlineColor),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            post.avatar,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.userName,
                                style: AppTextStyles.labelSM.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                post.timeAgo,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        if (post.isAchievement) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MILESTONE 🏆',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(post.content, style: AppTextStyles.bodySM),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            state.toggleLikePost(post);
                          },
                          child: Row(
                            children: [
                              Icon(
                                post.isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${post.likes}',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
