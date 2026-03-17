import 'package:flutter/material.dart';
import '../../models/category_topic_model.dart';
import '../../models/subject_model.dart';
import '../../services/category_topic_service.dart';
import '../../services/question_service.dart';
import '../../utils/constants.dart';
import 'add_topic_screen.dart';

class ManageTopicsScreen extends StatefulWidget {
  const ManageTopicsScreen({super.key});

  @override
  State<ManageTopicsScreen> createState() => _ManageTopicsScreenState();
}

class _ManageTopicsScreenState extends State<ManageTopicsScreen> {
  final _topicService = CategoryTopicService();
  final _subjectService = QuestionService(); // Using to get subjects

  List<SubjectModel> _subjects = [];
  SubjectModel? _selectedSubject;
  List<CategoryTopicModel> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    final subjects = await _subjectService.getAllSubjects();
    if (!mounted) return;
    setState(() {
      _subjects = subjects;
      if (subjects.isNotEmpty) {
        _selectedSubject = subjects.first;
      }
      _isLoading = false;
    });
    if (_selectedSubject != null) {
      _loadTopics(_selectedSubject!.id!);
    }
  }

  Future<void> _loadTopics(int subjectId) async {
    setState(() => _isLoading = true);
    final topics = await _topicService.getTopicsBySubject(subjectId);
    if (!mounted) return;
    setState(() {
      _topics = topics;
      _isLoading = false;
    });
  }

  Future<void> _deleteTopic(CategoryTopicModel topic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: const Text('Delete Topic'),
        content: const Text(
          'Are you sure you want to delete this topic?\n'
          'Questions under this topic will lose their category assignment but will remain in the subject.',
        ),
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
      await _topicService.deleteTopic(topic.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Topic deleted.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      if (_selectedSubject != null) {
        _loadTopics(_selectedSubject!.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Topics'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppConstants.primaryLight,
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => AddTopicScreen(preselectedSubject: _selectedSubject),
            ),
          );
          if (result == true && _selectedSubject != null) {
            _loadTopics(_selectedSubject!.id!);
          }
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Topic', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading && _subjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 80, color: AppConstants.textSecondary.withAlpha(80)),
                      const SizedBox(height: AppConstants.paddingMedium),
                      const Text(
                        'No subjects available.\nPlease add a subject first.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: AppConstants.fontTitle),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Subject Selector
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: DropdownButtonFormField<SubjectModel>(
                        value: _selectedSubject,
                        decoration: InputDecoration(
                          labelText: 'Select Subject',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          prefixIcon: const Icon(Icons.book_outlined),
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
                    ),

                    // Topic List
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _topics.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No topics added for this subject yet.',
                                    style: TextStyle(color: AppConstants.textSecondary),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                                  itemCount: _topics.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AppConstants.paddingSmall),
                                  itemBuilder: (context, index) {
                                    final t = _topics[index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppConstants.radiusMedium),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: AppConstants.paddingLarge,
                                            vertical: AppConstants.paddingSmall),
                                        leading: CircleAvatar(
                                          backgroundColor: AppConstants.primaryLight.withAlpha(30),
                                          child: const Icon(Icons.category_rounded,
                                              color: AppConstants.primaryLight),
                                        ),
                                        title: Text(
                                          t.topicName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        trailing: Wrap(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_rounded,
                                                  color: AppConstants.primaryLight),
                                              tooltip: 'Edit Topic',
                                              onPressed: () async {
                                                final result = await Navigator.of(context).push<bool>(
                                                  MaterialPageRoute(
                                                    builder: (_) => AddTopicScreen(
                                                      existing: t,
                                                      preselectedSubject: _selectedSubject,
                                                    ),
                                                  ),
                                                );
                                                if (result == true && _selectedSubject != null) {
                                                  _loadTopics(_selectedSubject!.id!);
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_rounded,
                                                  color: AppConstants.errorColor),
                                              tooltip: 'Delete Topic',
                                              onPressed: () => _deleteTopic(t),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
    );
  }
}
