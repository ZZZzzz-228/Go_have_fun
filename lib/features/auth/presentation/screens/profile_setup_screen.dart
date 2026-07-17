import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../widgets/auth_text_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _bioCtrl = TextEditingController();
  final List<File?> _photos = List.filled(6, null);
  bool _isLoading = false;
  int _step = 0;

  Future<void> _pickPhoto(int index) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) {
      setState(() => _photos[index] = File(file.path));
    }
  }

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go(RouteNames.map);
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: List.generate(2, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: i <= _step
                            ? AppColors.primaryGradient
                            : null,
                        color: i <= _step
                            ? null
                            : AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              if (_step == 0) Expanded(child: _buildPhotoStep()),
              if (_step == 1) Expanded(child: _buildBioStep()),
              AppButton(
                label: _step == 0 ? 'Дальше' : 'Начать знакомства!',
                isLoading: _isLoading,
                onTap: () {
                  if (_step == 0) {
                    setState(() => _step = 1);
                  } else {
                    _finish();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Добавь фото',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Первое впечатление важно. Добавь хотя бы одно.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted(context),
              ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, i) {
              final photo = _photos[i];
              return GestureDetector(
                onTap: () => _pickPhoto(i),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppColors.cardBg(context),
                    border: Border.all(color: borderColor),
                    image: photo != null
                        ? DecorationImage(
                            image: FileImage(photo),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: photo == null
                      ? Icon(
                          Icons.add_rounded,
                          color: AppColors.textMuted(context),
                          size: 28,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBioStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Расскажи о себе',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Пару слов — и ты станешь интереснее',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted(context),
              ),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          controller: _bioCtrl,
          label: 'О себе',
          hint: 'Люблю кофе, велосипед и случайные встречи...',
          prefixIcon: Icons.edit_outlined,
          maxLines: 5,
          maxLength: 300,
        ),
        const Spacer(),
      ],
    );
  }
}
