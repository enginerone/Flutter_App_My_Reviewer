import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/subject_model.dart';
import '../../services/question_service.dart';
import '../../utils/constants.dart';
import 'add_question_screen.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  final _service = QuestionService();
  List<QuestionModel> _questions = [];
  Map<int, String> _subjectNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final questions = await _service.getAllQuestions();
    final subjects = await _service.getAllSubjects();
    if (!mounted) return;
    setState(() {
      _questions = questions;
      _subjectNames = {for (SubjectModel s in subjects) s.id!: s.subjectName};
      _isLoading = false;
    });
  }

  Future<void> _editQuestion(QuestionModel question) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddQuestionScreen(existing: question),
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _deleteQuestion(QuestionModel question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.errorColor),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteQuestion(question.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question deleted.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group questions by subject
    final Map<int, List<QuestionModel>> groupedQuestions = {};
    for (var q in _questions) {
      if (!groupedQuestions.containsKey(q.subjectId)) {
        groupedQuestions[q.subjectId] = [];
      }
      groupedQuestions[q.subjectId]!.add(q);
    }

    // Sort subjects by name
    final sortedSubjectIds = groupedQuestions.keys.toList()
      ..sort((a, b) => (_subjectNames[a] ?? '').compareTo(_subjectNames[b] ?? ''));

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text('All Questions (${_questions.length})'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 80, color: AppConstants.textSecondary.withAlpha(80)),
                      const SizedBox(height: AppConstants.paddingMedium),
                      const Text(
                        'No questions yet.',
                        style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: AppConstants.fontTitle),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: sortedSubjectIds.length,
                  itemBuilder: (context, subjectIndex) {
                    final subjectId = sortedSubjectIds[subjectIndex];
                    final subjectName = _subjectNames[subjectId] ?? 'Unknown';
                    final subjectQuestions = groupedQuestions[subjectId]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (subjectIndex > 0)
                          const Divider(height: AppConstants.paddingXLarge * 2),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.paddingMedium, left: 4),
                          child: Text(
                            subjectName,
                            style: const TextStyle(
                              fontSize: AppConstants.fontLarge,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                        ...subjectQuestions.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final QuestionModel q = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppConstants.primaryColor.withAlpha(20),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            subjectName,
                                            style: const TextStyle(
                                              fontSize: AppConstants.fontSmall,
                                              fontWeight: FontWeight.w600,
                                              color: AppConstants.primaryColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '#${index + 1}',
                                          style: const TextStyle(
                                            fontSize: AppConstants.fontSmall,
                                            color: AppConstants.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      q.meaning,
                                      style: const TextStyle(
                                        fontSize: AppConstants.fontBody,
                                        color: AppConstants.textPrimary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded,
                                            size: 14, color: AppConstants.successColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          q.correctTerm,
                                          style: const TextStyle(
                                            fontSize: AppConstants.fontBody,
                                            fontWeight: FontWeight.bold,
                                            color: AppConstants.successColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: AppConstants.paddingMedium),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _editQuestion(q),
                                          icon: const Icon(Icons.edit_rounded, size: 16,
                                              color: AppConstants.primaryLight),
                                          label: const Text('Edit',
                                              style: TextStyle(color: AppConstants.primaryLight)),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () => _deleteQuestion(q),
                                          icon: const Icon(Icons.delete_rounded, size: 16,
                                              color: AppConstants.errorColor),
                                          label: const Text('Delete',
                                              style: TextStyle(color: AppConstants.errorColor)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
    );
  }
}
