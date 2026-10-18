import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/context.extension.dart';
import '../../core/theme/text_styles.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Theme & Design Tokens Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. COLOR SWATCHES
            // ==========================================
            _buildSectionHeader('1. Color Palette (context.colors)'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildColorChip('Primary', context.colors.primary),
                _buildColorChip('Secondary', context.colors.secondary),
                _buildColorChip('Background', context.colors.background, showBorder: true),
                _buildColorChip('Surface', context.colors.surface),
                _buildColorChip('Card', context.colors.card),
                _buildColorChip('InputFill', context.colors.inputFill),
                _buildColorChip('Border', context.colors.border),
                _buildColorChip('Error', context.colors.error),
                _buildColorChip('Success', context.colors.success),
              ],
            ),
            const SizedBox(height: 32),
            // ==========================================
            // 2. TYPOGRAPHY / TEXT THEME
            // ==========================================
            _buildSectionHeader('2. Typography (AppTextStyles & TextTheme)'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Headline Large (24 bold)',
                    style: AppTextStyles.white24bold.copyWith(color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Title Medium (18 semi-bold)',
                    style: AppTextStyles.titleMedium.copyWith(color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Title Small (16 semi-bold)',
                    style: AppTextStyles.titleSmall.copyWith(color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Body Large - Primary description text (16 regular)',
                    style: AppTextStyles.bodyLarge.copyWith(color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Body Medium - Secondary helper text (14 regular)',
                    style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Caption / Small - Muted hint text (12 regular)',
                    style: AppTextStyles.caption.copyWith(color: context.colors.hint),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // ==========================================
            // 3. TEXT FIELDS (InputDecorationTheme)
            // ==========================================
            _buildSectionHeader('3. Text Fields'),
            const SizedBox(height: 12),
            // Normal text field with prefix icon
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'e.g. alex@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            // Password field with toggle visibility suffix icon
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Text field showing Error State
            const TextField(
              decoration: InputDecoration(
                labelText: 'Invalid Input Field',
                hintText: 'Shows error border and text',
                prefixIcon: Icon(Icons.error_outline),
                errorText: 'Please enter a valid value',
              ),
            ),
            const SizedBox(height: 32),
            // ==========================================
            // 4. BUTTONS & ACTIONS
            // ==========================================
            _buildSectionHeader('4. Buttons'),
            const SizedBox(height: 12),
            // Elevated Pill Button (Figma CTA)
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme SnackBar working properly!')),
                );
              },
              child: const Text('Primary CTA Button (Show SnackBar)'),
            ),
            const SizedBox(height: 14),
            // Outlined Pill Button
            OutlinedButton(
              onPressed: () {},
              child: const Text('Secondary Outlined Button'),
            ),
            const SizedBox(height: 14),
            // Text Button
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Text Button Action (e.g. Forgot Password?)'),
              ),
            ),
            const SizedBox(height: 32),
            // ==========================================
            // 5. CARDS & GRADIENT PREVIEW
            // ==========================================
            _buildSectionHeader('5. Card & Gradient (From Figma)'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Full Body Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '45 mins • 350 kcal • Intermediate',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: context.colors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildColorChip(String label, Color color, {bool showBorder = false}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: showBorder ? Border.all(color: Colors.white24) : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
            style: TextStyle(
              fontSize: 9,
              color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
