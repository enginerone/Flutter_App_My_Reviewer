import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/subject_model.dart';
import '../../models/category_topic_model.dart';
import '../../services/category_topic_service.dart';
import '../../services/question_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';

class AddQuestionScreen extends StatefulWidget {
  final QuestionModel? existing;
  const AddQuestionScreen({super.key, this.existing});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _meaningController;
  late final TextEditingController _termController;
  final _service = QuestionService();
  final _topicService = CategoryTopicService();

  List<SubjectModel> _subjects = [];
  SubjectModel? _selectedSubject;
  List<CategoryTopicModel> _topics = [];
  CategoryTopicModel? _selectedTopic;
  bool _loadingTopics = false;
  bool _isLoading = false;
  bool _loadingSubjects = true;

  // Answer type
  String _answerType = 'identification'; // 'identification' | 'multiple_choice'
  // Distractor controllers (for MC — the correct term is a separate field)
  final List<TextEditingController> _choiceControllers = [];

  bool get _isEditing => widget.existing != null;
  bool get _isMC => _answerType == 'multiple_choice';

  @override
  void initState() {
    super.initState();
    _meaningController =
        TextEditingController(text: widget.existing?.meaning ?? '');
    _termController =
        TextEditingController(text: widget.existing?.correctTerm ?? '');

    if (_isEditing) {
      _answerType = widget.existing!.answerType;
      // Restore saved distractors
      for (final c in widget.existing!.choices) {
        _choiceControllers.add(TextEditingController(text: c));
      }
    }
    // Ensure at least 2 distractor rows for MC
    if (_isMC && _choiceControllers.length < 2) {
      while (_choiceControllers.length < 2) {
        _choiceControllers.add(TextEditingController());
      }
    }

    _loadSubjects();
  }

  @override
  void dispose() {
    _meaningController.dispose();
    _termController.dispose();
    for (final c in _choiceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _switchAnswerType(String type) {
    setState(() {
      _answerType = type;
      if (_isMC && _choiceControllers.length < 2) {
        while (_choiceControllers.length < 2) {
          _choiceControllers.add(TextEditingController());
        }
      }
    });
  }

  void _addChoice() {
    if (_choiceControllers.length >= 3) return; // max 3 distractors (4 total with correct)
    setState(() => _choiceControllers.add(TextEditingController()));
  }

  void _removeChoice(int index) {
    if (_choiceControllers.length <= 2) return; // enforce minimum 2 distractors
    final ctrl = _choiceControllers.removeAt(index);
    ctrl.dispose();
    setState(() {});
  }

  Future<void> _loadTopics(int subjectId) async {
    setState(() => _loadingTopics = true);
    final topics = await _topicService.getTopicsBySubject(subjectId);
    if (!mounted) return;
    setState(() {
      _topics = topics;
      _loadingTopics = false;
      if (_isEditing && widget.existing!.topicId != null) {
        _selectedTopic = topics.firstWhere(
          (t) => t.id == widget.existing!.topicId,
          orElse: () => topics.first,
        );
      } else {
        _selectedTopic = null;
      }
    });
  }

  Future<void> _loadSubjects() async {
    final list = await _service.getAllSubjects();
    if (!mounted) return;
    setState(() {
      _subjects = list;
      _loadingSubjects = false;
      if (_isEditing) {
        _selectedSubject = list.firstWhere(
          (s) => s.id == widget.existing!.subjectId,
          orElse: () =>
              list.isNotEmpty ? list.first : SubjectModel(subjectName: ''),
        );
        if (_selectedSubject?.id != null) {
          _loadTopics(_selectedSubject!.id!);
        }
      }
    });
  }

  Future<void> _save() async {
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    // Extra MC validation
    if (_isMC) {
      final distractors =
          _choiceControllers.map((c) => c.text.trim()).toList();
      if (distractors.any((d) => d.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all choice fields.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        return;
      }
      final correctTerm = _termController.text.trim().toLowerCase();
      if (distractors
          .any((d) => d.toLowerCase() == correctTerm)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Choices must not duplicate the correct term.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final distractors = _isMC
        ? _choiceControllers.map((c) => c.text.trim()).toList()
        : <String>[];

    final question = QuestionModel(
      id: widget.existing?.id,
      subjectId: _selectedSubject!.id!,
      topicId: _selectedTopic?.id,
      meaning: _meaningController.text.trim(),
      correctTerm: _termController.text.trim(),
      answerType: _answerType,
      choices: distractors,
    );

    if (_isEditing) {
      await _service.updateQuestion(question);
    } else {
      await _service.addQuestion(question);
      _meaningController.clear();
      _termController.clear();
      if (_isMC) {
        for (final c in _choiceControllers) {
          c.clear();
        }
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Question updated!' : 'Question saved!'),
        backgroundColor: AppConstants.successColor,
      ),
    );
    if (_isEditing) Navigator.of(context).pop(true);
  }

  // ── UI Helpers ─────────────────────────────────────────────────────

  Widget _buildAnswerTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Answer Type',
          style: TextStyle(
            fontSize: AppConstants.fontSmall,
            fontWeight: FontWeight.w700,
            color: AppConstants.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _typeChip(
              label: 'Identification',
              icon: Icons.edit_outlined,
              value: 'identification',
            ),
            const SizedBox(width: 10),
            _typeChip(
              label: 'Multiple Choice',
              icon: Icons.list_alt_rounded,
              value: 'multiple_choice',
            ),
          ],
        ),
      ],
    );
  }

  Widget _typeChip({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final selected = _answerType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchAnswerType(value),
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppConstants.primaryColor
                : AppConstants.primaryColor.withAlpha(12),
            borderRadius:
                BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: selected
                  ? AppConstants.primaryColor
                  : AppConstants.dividerColor,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 22,
                  color: selected ? Colors.white : AppConstants.primaryColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.fontSmall,
                  fontWeight: FontWeight.w700,
                  color:
                      selected ? Colors.white : AppConstants.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMCChoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            const Icon(Icons.format_list_bulleted_rounded,
                size: 16, color: AppConstants.accentColor),
            const SizedBox(width: 6),
            const Text(
              'WRONG CHOICES (DISTRACTORS)',
              style: TextStyle(
                fontSize: AppConstants.fontSmall,
                fontWeight: FontWeight.w700,
                color: AppConstants.accentColor,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            Text(
              '${_choiceControllers.length}/3',
              style: const TextStyle(
                  fontSize: AppConstants.fontSmall,
                  color: AppConstants.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Add 2–3 wrong answers. The correct term above will be added automatically.',
          style: TextStyle(
            fontSize: AppConstants.fontSmall,
            color: AppConstants.textSecondary.withAlpha(180),
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        ...List.generate(_choiceControllers.length, (i) {
          return Padding(
            padding:
                const EdgeInsets.only(bottom: AppConstants.paddingSmall),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppConstants.errorColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + i), // A, B, C
                      style: const TextStyle(
                        fontSize: AppConstants.fontSmall,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.errorColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _choiceControllers[i],
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Wrong choice ${i + 1}',
                      hintStyle: const TextStyle(
                          color: AppConstants.textSecondary),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium),
                      ),
                    ),
                  ),
                ),
                if (_choiceControllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppConstants.errorColor, size: 20),
                    onPressed: () => _removeChoice(i),
                    tooltip: 'Remove choice',
                  ),
              ],
            ),
          );
        }),
        if (_choiceControllers.length < 3)
          TextButton.icon(
            onPressed: _addChoice,
            icon: const Icon(Icons.add_circle_outline,
                size: 18, color: AppConstants.primaryColor),
            label: const Text(
              'Add another choice',
              style: TextStyle(color: AppConstants.primaryColor),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Question' : 'Add Question'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loadingSubjects
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 64,
                          color: AppConstants.textSecondary),
                      const SizedBox(height: AppConstants.paddingMedium),
                      const Text(
                        'No subjects found.\nPlease add a subject first.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppConstants.textSecondary),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Card(
                          elevation: AppConstants.cardElevation,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusLarge),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                                AppConstants.paddingLarge),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // ── Answer Type Selector ────────────
                                _buildAnswerTypeSelector(),
                                const SizedBox(
                                    height: AppConstants.paddingMedium),
                                const Divider(),
                                const SizedBox(
                                    height: AppConstants.paddingSmall),

                                // ── Subject ──────────────────────────
                                DropdownButtonFormField<SubjectModel>(
                                  value: _selectedSubject,
                                  decoration: InputDecoration(
                                    labelText: 'Select Subject',
                                    prefixIcon: const Icon(
                                        Icons.book_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppConstants.radiusMedium),
                                    ),
                                  ),
                                  items: _subjects.map((s) {
                                    return DropdownMenuItem(
                                      value: s,
                                      child: Text(s.subjectName),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() =>
                                          _selectedSubject = v);
                                      _loadTopics(v.id!);
                                    }
                                  },
                                ),
                                const SizedBox(
                                    height: AppConstants.paddingMedium),

                                // ── Topic (optional) ─────────────────
                                if (_loadingTopics)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Center(
                                        child:
                                            CircularProgressIndicator()),
                                  )
                                else if (_topics.isNotEmpty) ...[
                                  DropdownButtonFormField<
                                      CategoryTopicModel>(
                                    value: _selectedTopic,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Select Topic (Optional)',
                                      prefixIcon: const Icon(
                                          Icons.category_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                AppConstants.radiusMedium),
                                      ),
                                    ),
                                    items: [
                                      const DropdownMenuItem<
                                          CategoryTopicModel>(
                                        value: null,
                                        child: Text('No Topic'),
                                      ),
                                      ..._topics.map((t) {
                                        return DropdownMenuItem(
                                          value: t,
                                          child: Text(t.topicName),
                                        );
                                      }),
                                    ],
                                    onChanged: (v) => setState(
                                        () => _selectedTopic = v),
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.paddingMedium),
                                ],

                                // ── Meaning ──────────────────────────
                                TextFormField(
                                  controller: _meaningController,
                                  maxLines: 4,
                                  validator: (v) =>
                                      Validators.validateRequired(
                                          v, 'Meaning'),
                                  decoration: InputDecoration(
                                    labelText: 'Meaning / Definition',
                                    alignLabelWithHint: true,
                                    prefixIcon: const Icon(
                                        Icons.description_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppConstants.radiusMedium),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    height: AppConstants.paddingMedium),

                                // ── Correct Term ──────────────────────
                                TextFormField(
                                  controller: _termController,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  validator: (v) =>
                                      Validators.validateRequired(
                                          v, 'Correct term'),
                                  decoration: InputDecoration(
                                    labelText: 'Correct Term (Answer)',
                                    prefixIcon: const Icon(
                                        Icons.check_circle_outline),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppConstants.radiusMedium),
                                    ),
                                  ),
                                ),

                                // ── MC Choices ────────────────────────
                                if (_isMC) _buildMCChoices(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: AppConstants.paddingLarge),
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator())
                            : CustomButton(
                                label: _isEditing
                                    ? 'Update Question'
                                    : 'Save Question',
                                icon: Icons.save_rounded,
                                onPressed: _save,
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
