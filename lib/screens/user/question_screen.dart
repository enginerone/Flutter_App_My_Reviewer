import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/subject_model.dart';
import '../../models/user_model.dart';
import '../../models/result_model.dart';
import '../../services/result_service.dart';
import '../../services/quiz_session_service.dart';
import '../../services/category_topic_service.dart';
import '../../models/quiz_session_model.dart';
import '../../utils/constants.dart';
import '../../widgets/question_card.dart';
import '../../widgets/popup_message.dart';
import 'result_screen.dart';

class QuestionScreen extends StatefulWidget {
  final UserModel user;
  final SubjectModel subject;
  final List<QuestionModel> questions;
  final QuizSessionModel? session;

  const QuestionScreen({
    super.key,
    required this.user,
    required this.subject,
    required this.questions,
    this.session,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _answerController = TextEditingController();
  final _resultService = ResultService();
  final _sessionService = QuizSessionService();

  int _currentIndex = 0;
  int _correctCount = 0;
  bool _isProcessing = false;
  final Set<int> _skippedIds = {};
  int? _sessionId;
  Map<int, String> _topicNames = {};
  // Cache shuffled choices per question index (so rebuilds don't reshuffle)
  final Map<int, List<String>> _shuffledChoicesCache = {};

  QuestionModel get _currentQuestion => widget.questions[_currentIndex];

  List<String> get _currentShuffledChoices {
    final q = _currentQuestion;
    if (q.answerType != 'multiple_choice') return [];
    if (!_shuffledChoicesCache.containsKey(_currentIndex)) {
      final all = [...q.choices, q.correctTerm];
      all.shuffle(Random());
      _shuffledChoicesCache[_currentIndex] = all;
    }
    return _shuffledChoicesCache[_currentIndex]!;
  }

  @override
  void initState() {
    super.initState();
    _loadTopics();
    if (widget.session != null) {
      _sessionId = widget.session!.id;
      _currentIndex = widget.session!.currentQuestionIndex;
      _skippedIds.addAll(widget.session!.skippedQuestionIds);
      _correctCount = widget.session!.correctCount;
    }
  }

  Future<void> _loadTopics() async {
    final topics = await CategoryTopicService().getTopicsBySubject(widget.subject.id!);
    if (!mounted) return;
    setState(() {
      _topicNames = {for (var t in topics) t.id!: t.topicName};
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    if (_isProcessing) return;
    final userAnswer = _answerController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    if (userAnswer.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please type your answer before submitting.'),
          backgroundColor: AppConstants.errorColor,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final isCorrect = userAnswer.toLowerCase() ==
        _currentQuestion.correctTerm.toLowerCase();

    setState(() => _isProcessing = true);

    if (isCorrect) {
      _correctCount++;
      await showPopupMessage(
        context,
        type: PopupType.correct,
        title: '✔ Correct!',
        message: 'The correct answer is:',
        correctTerm: _currentQuestion.correctTerm,
        autoDismiss: true,
        autoDismissDuration: const Duration(seconds: 2),
      );
      _answerController.clear();
      if (!mounted) return;
      _goToNext(wasSkipped: false);
    } else {
      await showPopupMessage(
        context,
        type: PopupType.incorrect,
        title: '✖ Incorrect',
        message: 'That\'s not quite right. Please try again!',
        onDismiss: () {
          _answerController.clear();
        },
      );
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _skipQuestion() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    _skippedIds.add(_currentQuestion.id!);
    
    await showPopupMessage(
      context,
      type: PopupType.info,
      title: 'Skipped',
      message: 'The correct answer is:',
      correctTerm: _currentQuestion.correctTerm,
    );

    if (mounted) {
      _answerController.clear();
      setState(() => _isProcessing = false);
      _goToNext(wasSkipped: true);
    }
  }

  String _generateClue(String term) {
    if (term.isEmpty) return '';
    final words = term.split(' ');
    final clueWords = words.map((word) {
      if (word.length <= 2) return word;
      final first = word[0];
      final last = word[word.length - 1];
      final middle = List.filled(word.length - 2, '_').join('');
      return '$first$middle$last';
    });
    return clueWords.join('   ');
  }

  void _goToNext({required bool wasSkipped}) async {
    // Save progress after answering or skipping
    await _saveSession(false);

    int nextIndex = _currentIndex + 1;
    
    // Check if we reached the end of the normal questions list
    if (nextIndex >= widget.questions.length) {
      // If we have skipped questions, find the first skipped question we haven't answered yet
      if (_skippedIds.isNotEmpty) {
        // Try to loop back to the first skipped question
        for (int i = 0; i < widget.questions.length; i++) {
          if (_skippedIds.contains(widget.questions[i].id)) {
            setState(() => _currentIndex = i);
            return;
          }
        }
      }
      // If we reach here, we're done (no more questions and no skipped ones left)
      _finishQuiz();
    } else {
      // Normal progression, but we should skip questions we've already answered 
      // This happens when iterating through skipped questions at the end
      while (nextIndex < widget.questions.length) {
        // If we are just proceeding normally OR if we are on a skipped question
        setState(() => _currentIndex = nextIndex);
        return;
      }
      _finishQuiz();
    }
  }

  void _goToPrevious() {
    if (_currentIndex <= 0) return;
    _answerController.clear();
    setState(() => _currentIndex = _currentIndex - 1);
  }

  Future<void> _saveSession(bool isCompleted) async {
    final session = QuizSessionModel(
      id: _sessionId,
      userId: widget.user.id!,
      subjectId: widget.subject.id!,
      currentQuestionIndex: _currentIndex,
      skippedQuestionIds: _skippedIds.toList(),
      correctCount: _correctCount,
      isCompleted: isCompleted,
      lastActivity: DateTime.now().toIso8601String(),
      totalQuestions: widget.questions.length,
    );

    if (_sessionId == null) {
      _sessionId = await _sessionService.createSession(session);
    } else {
      await _sessionService.updateSession(session);
    }
  }

  Future<void> _finishQuiz() async {
    await _saveSession(true);
    await _sessionService.clearCompletedSessions(widget.user.id!); // clean up

    final total = widget.questions.length;
    final score = ((_correctCount / total) * 100).round();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final result = ResultModel(
      userId: widget.user.id!,
      subjectId: widget.subject.id!,
      totalQuestions: total,
      correctAnswers: _correctCount,
      score: score,
      dateTaken: dateStr,
    );

    await _resultService.saveResult(result);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          user: widget.user,
          subject: widget.subject,
          questions: widget.questions,
          result: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.subject.subjectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: QuestionCard(
            questionNumber: _currentIndex + 1,
            totalQuestions: widget.questions.length,
            meaning: _currentQuestion.meaning,
            answerController: _answerController,
            onSubmit: _submitAnswer,
            isLoading: _isProcessing,
            onSkip: _skipQuestion,
            onPrevious: _goToPrevious,
            canGoBack: _currentIndex > 0,
            topicName: _topicNames[_currentQuestion.topicId],
            clue: _generateClue(_currentQuestion.correctTerm),
            answerType: _currentQuestion.answerType,
            shuffledChoices: _currentShuffledChoices,
          ),
        ),
      ),
    );
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: const Text('Quit Quiz?'),
        content: const Text(
            'Your progress will be lost if you exit. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Quit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) navigator.pop();
  }
}
