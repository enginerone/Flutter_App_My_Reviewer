import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../screens/auth/login_screen.dart';
import 'add_subject_screen.dart';
import 'add_question_screen.dart';
import 'manage_subjects_screen.dart';
import 'manage_questions_screen.dart';
import 'manage_topics_screen.dart';

class AdminDashboard extends StatelessWidget {
  final UserModel admin;
  const AdminDashboard({super.key, required this.admin});

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Add Subject',
        color: const Color(0xFF1565C0),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddSubjectScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.folder_open_rounded,
        label: 'Manage Subjects',
        color: const Color(0xFF00838F),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ManageSubjectsScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.category_rounded,
        label: 'Manage Topics',
        color: const Color(0xFFEF6C00),
        onTap: () => Navigator.of(context).push(
          // We will create ManageTopicsScreen later
          MaterialPageRoute(builder: (_) => const ManageTopicsScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.post_add_rounded,
        label: 'Add Question',
        color: const Color(0xFF2E7D32),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.quiz_rounded,
        label: 'View Questions',
        color: const Color(0xFF6A1B9A),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ManageQuestionsScreen()),
        ),
      ),
    ];

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
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: AppConstants.fontBody,
                          letterSpacing: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                        tooltip: 'Logout',
                        onPressed: () => _logout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${admin.name}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppConstants.fontLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Manage your reviewer content',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: AppConstants.fontSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Grid Menu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.paddingSmall),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: AppConstants.fontTitle,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppConstants.paddingMedium,
                          mainAxisSpacing: AppConstants.paddingMedium,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: menuItems.length,
                        itemBuilder: (context, index) {
                          final item = menuItems[index];
                          return _MenuCard(item: item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: item.color.withAlpha(30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: item.color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 32),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontBody,
                fontWeight: FontWeight.w600,
                color: item.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
