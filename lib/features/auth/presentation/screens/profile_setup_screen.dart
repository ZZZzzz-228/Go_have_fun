import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _bioCtrl = TextEditingController();
  final List<File?> _photos = List.filled(6, null);
  bool _isLoading = false;
  int _step = 0; // 0 — фото, 1 — о себе

  Future<void> _pickPhoto(int index) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() => _photos[index] = File(file.path));
    }
  }

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // TODO: upload & save
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Прогресс
              Row(
                children: List.generate(2, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: i <= _step
                          ? AppColors.primaryGradient
                          : const LinearGradient(
                              colors: [AppColors.surfaceVariant, AppColors.surfaceVariant]),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 32),

              if (_step == 0) _buildPhotoStep(),
              if (_step == 1) _buildBioStep(),

              const Spacer(),

              GradientButton(
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Добавь фото 📸',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Первое впечатление важно.\nДобавь хотя бы одно.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
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
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surfaceVariant,
                      image: photo != null
                          ? DecorationImage(
                              image: FileImage(photo),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photo == null
                        ? const Center(
                            child: Icon(
                              Icons.add_rounded,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioStep() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Расскажи о себе ✍️',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Пару слов — и ты станешь интереснее',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _bioCtrl,
            maxLength: 300,
            maxLines: 6,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Люблю кофе, велосипед и случайные встречи...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              counterStyle:
                  const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
