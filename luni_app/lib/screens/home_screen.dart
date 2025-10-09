import 'package:flutter/material.dart';
import '../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/luni_button.dart';
import 'package:provider/provider.dart';
import '../widgets/luni_button.dart';
import '../providers/app_provider.dart';
import '../widgets/luni_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luni App'),
        actions: [
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return IconButton(
                icon: Icon(
                  appProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () => appProvider.toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Luni App!',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: 8.h),
              Text(
                'This is your starting point for building your app from Figma designs.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 24.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Steps:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 12.h),
                      _buildStepItem(
                        context,
                        '1. Export assets from Figma',
                        'Export images, icons, and fonts from your Figma design',
                      ),
                      SizedBox(height: 8.h),
                      _buildStepItem(
                        context,
                        '2. Add assets to the project',
                        'Place exported files in assets/images/, assets/icons/, assets/fonts/',
                      ),
                      SizedBox(height: 8.h),
                      _buildStepItem(
                        context,
                        '3. Update theme colors',
                        'Modify colors in lib/theme/app_theme.dart to match your design',
                      ),
                      SizedBox(height: 8.h),
                      _buildStepItem(
                        context,
                        '4. Create screens and widgets',
                        'Build your UI components based on Figma designs',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: LuniElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ready to start building! 🚀'),
                      ),
                    );
                  },
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          margin: EdgeInsets.only(top: 6.h, right: 12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}