import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:games_hub/games/ballsortgame/ball_sort_app.dart';
import 'package:games_hub/games/emoji-pair-master/emoji-pair-master-view.dart';
import 'package:games_hub/games/chess/chess_screen.dart';
import 'package:games_hub/games/hungry_worm/components/game_screen.dart';
import 'package:games_hub/games/ludo/presentation/screens/ludo_home_screen.dart';
import 'package:games_hub/games/mind_wash/screens/mind_wash_screen.dart';
import 'package:games_hub/games/sliding_puzzle_game/sliding_puzzle/sliding_puzzle_screen.dart';
import 'package:games_hub/games/sudoku/sudoku_screen.dart';
import 'package:games_hub/games/tictactoe/views/sellect_level_screen.dart';
import 'package:games_hub/games/word_search_game/screens/ws_home_screen.dart';
import 'package:games_hub/games/word_search_game/services/ws_game_provider.dart';
import 'package:provider/provider.dart';

class _T {
  static const bg        = Color(0xFF0F1117);
  static const surface   = Color(0xFF1A1D27);
  static const card      = Color(0xFF20232F);
  static const cardHigh  = Color(0xFF272B3A);
  static const amber     = Color(0xFFFFB830);
  static const amberDim  = Color(0xFF7A5210);
  static const red       = Color(0xFFFF4757);
  static const green     = Color(0xFF2ED573);
  static const textPri   = Color(0xFFF1F2F6);
  static const textSec   = Color(0xFF8B91A7);
  static const textHint  = Color(0xFF4A506A);
}

class GameModel {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final String tag;
  final Color accentColor;
  final Widget Function(BuildContext) screenBuilder;

  const GameModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.tag,
    required this.accentColor,
    required this.screenBuilder,
  });

  // Helper method for searching
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        subtitle.toLowerCase().contains(lowerQuery) ||
        tag.toLowerCase().contains(lowerQuery);
  }
}

class RecentGamesManager {
  static final RecentGamesManager _i = RecentGamesManager._();
  factory RecentGamesManager() => _i;
  RecentGamesManager._();

  final Map<String, DateTime> _played = {};
  void markPlayed(String id) => _played[id] = DateTime.now();

  List<String> getIds() {
    final s = _played.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return s.map((e) => e.key).toList();
  }

  bool get hasAny => _played.isNotEmpty;
}

class GameHubScreen extends StatefulWidget {
  const GameHubScreen({super.key});
  @override
  State<GameHubScreen> createState() => _GameHubScreenState();
}

class _GameHubScreenState extends State<GameHubScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.88);
  int _currentBanner = 0;
  Timer? _timer;
  final _recent = RecentGamesManager();
  
  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  List<GameModel> get _all => [
        GameModel(
          id: 'tictactoe',
          title: 'Tic-Tac-Toe',
          subtitle: 'Classic Strategy',
          imagePath: 'assets/images/tictoctoeimage.png',
          tag: 'Strategy',
          accentColor: const Color(0xFF8B5CF6),
          screenBuilder: (_) => SellectLevelScreen(),
        ),
        GameModel(
          id: 'chess',
          title: 'Chess',
          subtitle: 'Master the Board',
          imagePath: 'assets/images/chessi.png',
          tag: 'Strategy',
          accentColor: const Color(0xFF10B981),
          screenBuilder: (_) => const ChessGameScreen(),
        ),
        GameModel(
          id: 'sudoku',
          title: 'Sudoku',
          subtitle: 'Number Puzzle',
          imagePath: 'assets/images/sudokuimage.png',
          tag: 'Puzzle',
          accentColor: const Color(0xFF3B82F6),
          screenBuilder: (_) => const SudokuScreen(),
        ),
        GameModel(
          id: 'ludo',
          title: 'Ludo',
          subtitle: 'Roll & Win',
          imagePath: 'assets/images/ludoimage.png',
          tag: 'Arcade',
          accentColor: const Color(0xFFEF4444),
          screenBuilder: (_) => LudoHomeScreen(),
        ),
        GameModel(
          id: 'emoji_pair',
          title: 'Emoji Pair',
          subtitle: 'Match Master',
          imagePath: 'assets/images/imogipair.png',
          tag: 'Puzzle',
          accentColor: const Color(0xFFEC4899),
          screenBuilder: (_) => EmojiPairMasterApp(),
        ),
        GameModel(
          id: 'hungry_snake',
          title: 'Hungry Snake',
          subtitle: 'Eat & Grow',
          imagePath: 'assets/images/hungrisnack.png',
          tag: 'Arcade',
          accentColor: const Color(0xFF22C55E),
          screenBuilder: (_) => HungryWormGameScreen(),
        ),
        GameModel(
          id: 'ball_sort',
          title: 'Ball Sort',
          subtitle: 'Color Sorter',
          imagePath: 'assets/images/ballgame.png',
          tag: 'Puzzle',
          accentColor: const Color(0xFFF59E0B),
          screenBuilder: (_) => BallSortApp(),
        ),
        GameModel(
          id: 'word_search',
          title: 'Word Search',
          subtitle: 'Find the Words',
          imagePath: 'assets/images/wordsearch.png',
          tag: 'Puzzle',
          accentColor: const Color(0xFF06B6D4),
          screenBuilder: (_) => ChangeNotifierProvider(
            create: (_) => WSGameProvider()..initialize(),
            child: const WordSearchHome(),
          ),
        ),
        GameModel(
          id: 'mind_wash',
          title: 'MindWash',
          subtitle: 'Fresh the Mind',
          imagePath: 'assets/images/mindwashh.png',
          tag: 'Puzzle',
          accentColor: const Color(0xFF8B5CF6),
          screenBuilder: (_) => ChangeNotifierProvider(
            create: (_) => WSGameProvider()..initialize(),
            child: const MindWashScreen(),
          ),
        ),
        GameModel(
          id: 'sliding_puzzle',
          title: 'Sliding Puzzle',
          subtitle: 'Slide to Solve',
          imagePath: 'assets/images/slidingimage.png',
          tag: 'Puzzle',
          accentColor: const Color(0xFF0EA5E9),
          screenBuilder: (_) => ChangeNotifierProvider(
            create: (_) => WSGameProvider()..initialize(),
            child: const SlidingPuzzleScreen(),
          ),
        ),
      ];

  List<GameModel> get _bannerGames => _all.take(10).toList();

  List<GameModel> get _recentGames {
    final ids = _recent.getIds();
    return ids
        .map((id) => _all.firstWhere((g) => g.id == id,
            orElse: () => _all.first))
        .where((g) => ids.contains(g.id))
        .toList();
  }
  
  // Get filtered games based on search query
  List<GameModel> get _filteredGames {
    if (_searchQuery.isEmpty) return _all;
    return _all.where((game) => game.matchesSearch(_searchQuery)).toList();
  }
  
  // Get filtered banner games
  List<GameModel> get _filteredBannerGames {
    if (_searchQuery.isEmpty) return _bannerGames;
    return _bannerGames.where((game) => game.matchesSearch(_searchQuery)).toList();
  }
  
  // Get filtered recent games
  List<GameModel> get _filteredRecentGames {
    if (_searchQuery.isEmpty) return _recentGames;
    return _recentGames.where((game) => game.matchesSearch(_searchQuery)).toList();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _startAutoScroll();
    
    // Add listener for search
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _isSearching = _searchQuery.isNotEmpty;
      });
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageCtrl.hasClients) return;
      if (_filteredBannerGames.isEmpty) return;
      final next = (_currentBanner + 1) % _filteredBannerGames.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _open(BuildContext ctx, GameModel g) {
    HapticFeedback.lightImpact();
    _recent.markPlayed(g.id);
    setState(() {});
    Navigator.push(ctx, MaterialPageRoute(builder: g.screenBuilder));
  }
  
  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()), // Added search bar
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            
            if (_isSearching && _filteredGames.isEmpty) ...[
              SliverFillRemaining(
                child: _buildEmptySearchState(),
              ),
            ] else ...[
              if (_recent.hasAny && !_isSearching) ...[
                SliverToBoxAdapter(
                  child: _sectionTitle('Continue Playing', showAll: true),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 12)),
                SliverToBoxAdapter(child: _buildContinuePlaying()),
                SliverToBoxAdapter(child: const SizedBox(height: 28)),
              ],
              
              SliverToBoxAdapter(
                child: _sectionTitle(_isSearching ? 'Search Results 🔍' : 'Hot Games 🔥'),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 12)),
              SliverToBoxAdapter(child: _buildHotGrid()),
              SliverToBoxAdapter(child: const SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _T.cardHigh, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: _T.textPri, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search games... (Tic-Tac-Toe, Chess, Ludo, etc.)',
            hintStyle: TextStyle(color: _T.textHint, fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded, color: _T.textSec, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: _T.textSec, size: 20),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: _T.textHint),
          const SizedBox(height: 16),
          Text(
            'No games found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _T.textPri,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for: "${_searchQuery}"',
            style: TextStyle(
              fontSize: 14,
              color: _T.textSec,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Available games: Tic-Tac-Toe, Chess, Sudoku, Ludo,\nEmoji Pair, Hungry Snake, Ball Sort, Word Search,\nMindWash, Sliding Puzzle',
            style: TextStyle(
              fontSize: 12,
              color: _T.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: _T.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: _T.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text('GAME HUB',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: _T.green, letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text('Play & Enjoy',
                style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: _T.textPri, height: 1.1, letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
         Image(image: AssetImage("assets/images/gaming2.png"),height: 45,)
        ],
      ),
    );
  }

  Widget _buildBanner() {
    if (_filteredBannerGames.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemCount: _filteredBannerGames.length,
            itemBuilder: (ctx, i) {
              return AnimatedBuilder(
                animation: _pageCtrl,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_pageCtrl.position.haveDimensions) {
                    double page = _pageCtrl.page ?? i.toDouble();
                    double diff = (page - i).abs();
                    scale = (1.0 - (diff * 0.08)).clamp(0.92, 1.0);
                  }
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () => _open(ctx, _filteredBannerGames[i]),
                  child: _BannerCard(game: _filteredBannerGames[i]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_filteredBannerGames.length, (i) {
            final active = i == _currentBanner;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? _T.amber : _T.textHint,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, {bool showAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(title,
            style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700,
              color: _T.textPri, letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (showAll)
            GestureDetector(
              onTap: () {},
              child: const Text('See all',
                style: TextStyle(
                  fontSize: 13, color: _T.amber, fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContinuePlaying() {
    final games = _filteredRecentGames;
    if (games.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 108,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: games.length,
        itemBuilder: (ctx, i) {
          final g = games[i];
          return GestureDetector(
            onTap: () => _open(ctx, g),
            child: Container(
              width: 86,
              margin: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: g.accentColor.withOpacity(0.4), width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(g.imagePath, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: g.accentColor.withOpacity(0.15),
                              child: Center(
                                child: Text(g.title[0],
                                  style: TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.bold,
                                    color: g.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: _T.green, shape: BoxShape.circle,
                            border: Border.all(color: _T.bg, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(g.title,
                    style: const TextStyle(
                      fontSize: 10, color: _T.textSec, fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotGrid() {
    final games = _filteredGames;
    if (games.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10,
          mainAxisSpacing: 12, childAspectRatio: 0.72,
        ),
        itemCount: games.length,
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => _open(ctx, games[i]),
          child: _HotCard(game: games[i], isTop: i < 3),
        ),
      ),
    );
  }
}

// ─── Icon Button ─────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  const _IconBtn({required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _T.cardHigh, width: 1),
            ),
            child: Icon(icon, color: _T.textSec, size: 20),
          ),
          if (badge)
            Positioned(
              top: -2, right: -2,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: _T.red, shape: BoxShape.circle,
                  border: Border.all(color: _T.bg, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Banner Card ─────────────────────────────────────────────────────────────
class _BannerCard extends StatelessWidget {
  final GameModel game;
  const _BannerCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.black,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full background image
          Positioned.fill(
            child: Image.asset(
              game.imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Container(
                color: game.accentColor.withOpacity(0.2),
              ),
            ),
          ),
          // Gradient overlay — left heavy
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.90),
                    Colors.black.withOpacity(0.45),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.32, 0.58, 1.0],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _T.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _T.amber.withOpacity(0.4), width: 1),
                  ),
                  child: const Text('★  FEATURED',
                    style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w800,
                      color: _T.amber, letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: game.accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(game.tag.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: game.accentColor, letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(game.title,
                  style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: _T.textPri, height: 1.1, letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(game.subtitle,
                  style: const TextStyle(fontSize: 12, color: _T.textSec),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _T.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: Colors.black, size: 16),
                      SizedBox(width: 4),
                      Text('Play Now',
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800,
                          color: Colors.black, letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hot Game Card ────────────────────────────────────────────────────────────
class _HotCard extends StatelessWidget {
  final GameModel game;
  final bool isTop;
  const _HotCard({required this.game, this.isTop = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _T.card,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(game.imagePath, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: game.accentColor.withOpacity(0.1),
                        child: Center(
                          child: Text(game.title[0],
                            style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold,
                              color: game.accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isTop)
                  Positioned(
                    top: 0, left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: const BoxDecoration(
                        color: _T.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: const Text('HOT',
                        style: TextStyle(
                          fontSize: 8, fontWeight: FontWeight.w900,
                          color: Colors.white, letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(game.title,
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: _T.textPri,
          ),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        Text(game.subtitle,
          style: const TextStyle(fontSize: 10, color: _T.textSec),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}