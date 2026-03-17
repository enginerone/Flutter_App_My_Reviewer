import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../models/user_model.dart';
import '../../services/question_service.dart';
import '../../services/quiz_session_service.dart';
import '../../models/quiz_session_model.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import 'question_screen.dart';

class SubjectListScreen extends StatefulWidget {
  final UserModel user;
  const SubjectListScreen({super.key, required this.user});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final _service = QuestionService();
  final _sessionService = QuizSessionService();
  List<SubjectModel> _subjects = [];
  Map<int, int> _questionCounts = {};
  Map<int, QuizSessionModel?> _activeSessions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    final subjects = await _service.getAllSubjects();
    final Map<int, int> counts = {};
    final Map<int, QuizSessionModel?> sessions = {};
    for (final s in subjects) {
      final qs = await _service.getQuestionsBySubject(s.id!);
      counts[s.id!] = qs.length;
      final session = await _sessionService.getActiveSession(widget.user.id!, s.id!);
      sessions[s.id!] = session;
    }
    if (!mounted) return;
    setState(() {
      _subjects = subjects;
      _questionCounts = counts;
      _activeSessions = sessions;
      _isLoading = false;
    });
  }

  void _handleSubjectTap(SubjectModel subject, QuizSessionModel? session, int count) async {
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No questions available for ${subject.subjectName} yet.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    if (session != null) {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          title: const Text('Resume Quiz?'),
          content: const Text('You have an unfinished quiz for this subject. Would you like to resume where you left off or restart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('restart'),
              child: const Text('Restart Quiz', style: TextStyle(color: AppConstants.errorColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
              onPressed: () => Navigator.of(ctx).pop('resume'),
              child: const Text('Resume Quiz', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (choice == null) return;
      
      if (choice == 'restart') {
        await _sessionService.deleteSession(session.id!);
        _startQuiz(subject, null);
      } else {
        _startQuiz(subject, session);
      }
    } else {
      _startQuiz(subject, null);
    }
  }

  void _startQuiz(SubjectModel subject, QuizSessionModel? session) async {
    final questions = await _service.getQuestionsBySubject(subject.id!);
    if (!mounted) return;
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No questions available for ${subject.subjectName} yet.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestionScreen(
          user: widget.user,
          subject: subject,
          questions: questions,
          session: session,
        ),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Color palette for subject cards
  static const _cardColors = [
    Color(0xFF1565C0),
    Color(0xFF00838F),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFC62828),
    Color(0xFFE65100),
    Color(0xFF37474F),
    Color(0xFF00695C),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLarge,
                AppConstants.paddingLarge,
                AppConstants.paddingLarge,
                AppConstants.paddingXLarge,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppConstants.primaryColor, AppConstants.primaryLight],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviewer',
                        style: TextStyle(color: Colors.white70, fontSize: AppConstants.fontBody),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                        tooltip: 'Logout',
                        onPressed: _logout,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${widget.user.name}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppConstants.fontLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Select a subject to start reviewing',
                            style: TextStyle(color: Colors.white70, fontSize: AppConstants.fontSmall),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Subjects grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _subjects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_rounded,
                                  size: 80,
                                  color: AppConstants.textSecondary.withAlpha(80)),
                              const SizedBox(height: AppConstants.paddingMedium),
                              const Text(
                                'No subjects available.\nAsk your admin to add subjects.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppConstants.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadSubjects,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(AppConstants.paddingLarge),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppConstants.paddingMedium,
                              mainAxisSpacing: AppConstants.paddingMedium,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: _subjects.length,
                            itemBuilder: (context, index) {
                              final subject = _subjects[index];
                              final color =
                                  _cardColors[index % _cardColors.length];
                              final count = _questionCounts[subject.id] ?? 0;
                              return GestureDetector(
                                onTap: () => _handleSubjectTap(subject, _activeSessions[subject.id], count),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        color,
                                        color.withAlpha(180),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusLarge),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withAlpha(80),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        AppConstants.paddingMedium),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                              Icons.book_rounded,
                                              color: Colors.white,
                                              size: 26),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              subject.subjectName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    AppConstants.fontTitle,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$count question${count == 1 ? '' : 's'}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize:
                                                    AppConstants.fontSmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
