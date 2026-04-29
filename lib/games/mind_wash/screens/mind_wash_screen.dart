import 'package:flutter/material.dart';
import '../data/preferences_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/quiz_widgets.dart';
import 'quiz_screen.dart';

class MindWashScreen extends StatefulWidget {
  const MindWashScreen({super.key});

  @override
  State<MindWashScreen> createState() => _MindWashScreenState();
}

class _MindWashScreenState extends State<MindWashScreen>
    with SingleTickerProviderStateMixin {
  int _userLevel = 1;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _subjects = [
    'Pak Study',
    'Math',
    'Urdu',
    'English',
    'General Science',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserLevel();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLevel() async {
    final level = await PreferencesService.loadLevel();
    if (mounted) setState(() => _userLevel = level);
  }

  void _startSubjectQuiz(String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(subject: subject, isMixedMode: false),
      ),
    ).then((_) => _loadUserLevel());
  }

  void _startMixedQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuizScreen(subject: 'Mixed', isMixedMode: true),
      ),
    ).then((_) => _loadUserLevel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1F4E), Color(0xFF2C3E7A), Color(0xFF1B5E8C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Level badge
                            LevelBadge(level: _userLevel),
                            const SizedBox(height: 22),

                            // Mixed Quiz button
                            _buildMixedButton(),
                            const SizedBox(height: 26),

                            // Section label
                            const Text(
                              'Choose a Subject',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Subject cards — NO GridView, using Column+Row
                            // This fixes overflow completely
                            _buildSubjectList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header (on dark gradient background) ─────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          
          // Icon box
          GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MindWash',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Quiz & Brain Challenge',
                  style: TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
          // Stars decoration
          const Text('🧠', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }

  // ── Mixed Quiz Banner ─────────────────────────────────────
  Widget _buildMixedButton() {
    return GestureDetector(
      onTap: _startMixedQuiz,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E7A), Color(0xFF4ECDC4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C3E7A).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🎲', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Play Mixed Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '10 random questions · All subjects',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ── Subject List — replaces GridView to fix overflow ──────
  // Uses pairs of subjects in rows manually
  Widget _buildSubjectList() {
    return Column(
      children: [
        // Row 1: Pak Study + Math
        _buildSubjectRow(_subjects[0], _subjects[1]),
        const SizedBox(height: 14),
        // Row 2: Urdu + English
        _buildSubjectRow(_subjects[2], _subjects[3]),
        const SizedBox(height: 14),
        // Row 3: General Science (full width)
        _buildSubjectCardWide(_subjects[4]),
      ],
    );
  }

  // Two subject cards side by side
  Widget _buildSubjectRow(String subject1, String subject2) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: _buildSubjectCard(subject1)),
          const SizedBox(width: 14),
          Expanded(child: _buildSubjectCard(subject2)),
        ],
      ),
    );
  }

  // Single subject card (half width)
  Widget _buildSubjectCard(String subject) {
    final color =
        AppTheme.subjectColors[subject] ?? AppTheme.primaryColor;
    final emoji = AppTheme.subjectEmojis[subject] ?? '📝';

    return GestureDetector(
      onTap: () => _startSubjectQuiz(subject),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
           
          
            const SizedBox(height: 6),
            Text(
              subject,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Start →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wide card for last subject (full width)
  Widget _buildSubjectCardWide(String subject) {
    final color =
        AppTheme.subjectColors[subject] ?? AppTheme.primaryColor;
    final emoji = AppTheme.subjectEmojis[subject] ?? '📝';
    final icon = AppTheme.subjectIcons[subject] ?? Icons.quiz;

    return GestureDetector(
      onTap: () => _startSubjectQuiz(subject),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Icon(icon, color: Colors.white60, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Start →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}