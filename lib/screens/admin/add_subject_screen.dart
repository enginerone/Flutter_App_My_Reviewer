import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/question_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class AddSubjectScreen extends StatefulWidget {
  final SubjectModel? existing; // non-null when editing
  const AddSubjectScreen({super.key, this.existing});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  final _service = QuestionService();
  bool _isLoading = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.subjectName ?? '');
    _descController = TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final subject = SubjectModel(
      id: widget.existing?.id,
      subjectName: _nameController.text.trim(),
      description: _descController.text.trim(),
    );

    if (_isEditing) {
      await _service.updateSubject(subject);
    } else {
      await _service.addSubject(subject);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Subject updated!' : 'Subject added!'),
        backgroundColor: AppConstants.successColor,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Subject' : 'Add Subject'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => Validators.validateRequired(v, 'Subject name'),
                        decoration: const InputDecoration(
                          labelText: 'Subject Name',
                          prefixIcon: Icon(Icons.book_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(),
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
                      label: _isEditing ? 'Update Subject' : 'Save Subject',
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
