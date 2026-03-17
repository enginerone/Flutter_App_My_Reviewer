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

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _meaningController = TextEditingController(text: widget.existing?.meaning ?? '');
    _termController = TextEditingController(text: widget.existing?.correctTerm ?? '');
    _loadSubjects();
  }

  @override
  void dispose() {
    _meaningController.dispose();
    _termController.dispose();
    super.dispose();
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
        _selectedTopic = null; // reset when changing subjects
      }
    });
  }

  Future<void> _loadSubjects() async {
    final list = await _service.getAllSubjects();
    if (!mounted) return;
    setState(() {
      _subjects = list;
      _loadingSubjects = false;
      // Pre-select subject if editing
      if (_isEditing) {
        _selectedSubject = list.firstWhere(
          (s) => s.id == widget.existing!.subjectId,
          orElse: () => list.isNotEmpty ? list.first : SubjectModel(subjectName: ''),
        );
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
    setState(() => _isLoading = true);

    final question = QuestionModel(
      id: widget.existing?.id,
      subjectId: _selectedSubject!.id!,
      topicId: _selectedTopic?.id,
      meaning: _meaningController.text.trim(),
      correctTerm: _termController.text.trim(),
    );

    if (_isEditing) {
      await _service.updateQuestion(question);
    } else {
      await _service.addQuestion(question);
      _meaningController.clear();
      _termController.clear();
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
                          size: 64, color: AppConstants.textSecondary),
                      const SizedBox(height: AppConstants.paddingMedium),
                      const Text(
                        'No subjects found.\nPlease add a subject first.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppConstants.textSecondary),
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
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Card(
                          elevation: AppConstants.cardElevation,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.paddingLarge),
                            child: Column(
                              children: [
                                // Subject dropdown
                                DropdownButtonFormField<SubjectModel>(
                                  value: _selectedSubject,
                                  decoration: InputDecoration(
                                    labelText: 'Select Subject',
                                    prefixIcon: const Icon(Icons.book_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
                                      setState(() => _selectedSubject = v);
                                      _loadTopics(v.id!);
                                    }
                                  },
                                ),
                                const SizedBox(height: AppConstants.paddingMedium),

                                // Topic dropdown (if any)
                                if (_loadingTopics)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: CircularProgressIndicator(),
                                  )
                                else if (_topics.isNotEmpty) ...[
                                  DropdownButtonFormField<CategoryTopicModel>(
                                    value: _selectedTopic,
                                    decoration: InputDecoration(
                                      labelText: 'Select Topic (Optional)',
                                      prefixIcon: const Icon(Icons.category_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                      ),
                                    ),
                                    items: [
                                      const DropdownMenuItem<CategoryTopicModel>(
                                        value: null,
                                        child: Text('No Topic'),
                                      ),
                                      ..._topics.map((t) {
                                        return DropdownMenuItem(
                                          value: t,
                                          child: Text(t.topicName),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (v) => setState(() => _selectedTopic = v),
                                  ),
                                  const SizedBox(height: AppConstants.paddingMedium),
                                ],

                                // Meaning
                                TextFormField(
                                  controller: _meaningController,
                                  maxLines: 4,
                                  validator: (v) => Validators.validateRequired(v, 'Meaning'),
                                  decoration: InputDecoration(
                                    labelText: 'Meaning / Definition',
                                    alignLabelWithHint: true,
                                    prefixIcon: const Icon(Icons.description_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingMedium),

                                // Correct term
                                TextFormField(
                                  controller: _termController,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (v) => Validators.validateRequired(v, 'Correct term'),
                                  decoration: InputDecoration(
                                    labelText: 'Correct Term (Answer)',
                                    prefixIcon: const Icon(Icons.check_circle_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                label: _isEditing ? 'Update Question' : 'Save Question',
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


