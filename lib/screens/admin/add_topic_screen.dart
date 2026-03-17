import 'package:flutter/material.dart';
import '../../models/category_topic_model.dart';
import '../../models/subject_model.dart';
import '../../services/category_topic_service.dart';
import '../../services/question_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';

class AddTopicScreen extends StatefulWidget {
  final CategoryTopicModel? existing;
  final SubjectModel? preselectedSubject;

  const AddTopicScreen({super.key, this.existing, this.preselectedSubject});

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _topicService = CategoryTopicService();
  final _subjectService = QuestionService();

  List<SubjectModel> _subjects = [];
  SubjectModel? _selectedSubject;
  bool _isLoading = false;
  bool _loadingSubjects = true;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.topicName ?? '');
    _loadSubjects();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final list = await _subjectService.getAllSubjects();
    if (!mounted) return;
    setState(() {
      _subjects = list;
      _loadingSubjects = false;
      
      if (_isEditing) {
        _selectedSubject = list.firstWhere(
          (s) => s.id == widget.existing!.subjectId,
          orElse: () => list.isNotEmpty ? list.first : SubjectModel(subjectName: ''),
        );
      } else if (widget.preselectedSubject != null) {
        _selectedSubject = list.firstWhere(
          (s) => s.id == widget.preselectedSubject!.id,
          orElse: () => list.first,
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

    final topic = CategoryTopicModel(
      id: widget.existing?.id,
      subjectId: _selectedSubject!.id!,
      topicName: _nameController.text.trim(),
    );

    if (_isEditing) {
      await _topicService.updateTopic(topic);
    } else {
      await _topicService.addTopic(topic);
      _nameController.clear();
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Topic updated!' : 'Topic saved!'),
        backgroundColor: AppConstants.successColor,
      ),
    );
    Navigator.of(context).pop(true); // Return home to refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Topic' : 'Add Category Topic'),
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
                                  onChanged: _isEditing ? null : (v) => setState(() => _selectedSubject = v),
                                ),
                                const SizedBox(height: AppConstants.paddingMedium),

                                // Topic Name
                                TextFormField(
                                  controller: _nameController,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (v) => Validators.validateRequired(v, 'Topic Name'),
                                  decoration: InputDecoration(
                                    labelText: 'Category Topic Name',
                                    prefixIcon: const Icon(Icons.category_outlined),
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
                                label: _isEditing ? 'Update Topic' : 'Save Topic',
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
