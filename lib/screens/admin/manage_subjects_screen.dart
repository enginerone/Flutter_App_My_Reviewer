import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/question_service.dart';
import '../../utils/constants.dart';
import 'add_subject_screen.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final _service = QuestionService();
  List<SubjectModel> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    final list = await _service.getAllSubjects();
    if (!mounted) return;
    setState(() {
      _subjects = list;
      _isLoading = false;
    });
  }

  Future<void> _editSubject(SubjectModel subject) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddSubjectScreen(existing: subject),
      ),
    );
    if (result == true) _loadSubjects();
  }

  Future<void> _deleteSubject(SubjectModel subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: const Text('Delete Subject'),
        content: Text(
          'Delete "${subject.subjectName}"? All associated questions will also be deleted.',
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
      await _service.deleteSubject(subject.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subject deleted.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      _loadSubjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Subjects'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubjects,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 80, color: AppConstants.textSecondary.withAlpha(80)),
                      const SizedBox(height: AppConstants.paddingMedium),
                      const Text(
                        'No subjects yet.',
                        style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontTitle),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: _subjects.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppConstants.paddingSmall),
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingSmall,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.book_rounded,
                              color: AppConstants.primaryColor),
                        ),
                        title: Text(
                          subject.subjectName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        subtitle: subject.description.isNotEmpty
                            ? Text(
                                subject.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppConstants.textSecondary,
                                    fontSize: AppConstants.fontSmall),
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded,
                                  color: AppConstants.primaryLight),
                              onPressed: () => _editSubject(subject),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded,
                                  color: AppConstants.errorColor),
                              onPressed: () => _deleteSubject(subject),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
