import 'package:flutter/material.dart';
import '../../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/luni_button.dart';
import 'package:provider/provider.dart';
import '../../widgets/luni_button.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/luni_button.dart';
import '../../models/category_model.dart';
import '../../widgets/luni_button.dart';

class CategoriesSetupScreen extends StatefulWidget {
  const CategoriesSetupScreen({super.key});

  @override
  State<CategoriesSetupScreen> createState() => _CategoriesSetupScreenState();
}

class _CategoriesSetupScreenState extends State<CategoriesSetupScreen> {
  final Map<String, List<String>> _customSubcategories = {};
  final Map<String, TextEditingController> _controllers = {};
  
  // Define parent categories locally (matches database schema)
  static const Map<String, Map<String, dynamic>> _parentCategories = {
    'living_essentials': {'name': 'Living Essentials', 'icon': '🏠'},
    'education': {'name': 'Education', 'icon': '🎓'},
    'food': {'name': 'Food', 'icon': '🍽️'},
    'transportation': {'name': 'Transportation', 'icon': '🚌'},
    'healthcare': {'name': 'Healthcare', 'icon': '💊'},
    'entertainment': {'name': 'Entertainment', 'icon': '🎬'},
    'vacation': {'name': 'Vacation', 'icon': '✈️'},
    'income': {'name': 'Income', 'icon': '💰'},
  };

  @override
  void initState() {
    super.initState();
    _customSubcategories.addAll(context.read<OnboardingProvider>().customSubcategories);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCustomSubcategory(String parentKey) {
    final controller = TextEditingController();
    _controllers['${parentKey}_${DateTime.now().millisecondsSinceEpoch}'] = controller;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to ${_parentCategories[parentKey]!['name']}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter category name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          LuniTextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          LuniElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _customSubcategories[parentKey] ??= [];
                  _customSubcategories[parentKey]!.add(name);
                });
                context.read<OnboardingProvider>().setCustomSubcategories(_customSubcategories);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeCustomSubcategory(String parentKey, String subcategory) {
    setState(() {
      _customSubcategories[parentKey]?.remove(subcategory);
      if (_customSubcategories[parentKey]?.isEmpty == true) {
        _customSubcategories.remove(parentKey);
      }
    });
    context.read<OnboardingProvider>().setCustomSubcategories(_customSubcategories);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize your categories',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add personal subcategories to track your spending better',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 32.h),
          
          Expanded(
            child: ListView.builder(
              itemCount: _parentCategories.length,
              itemBuilder: (context, index) {
                final entry = _parentCategories.entries.elementAt(index);
                final parentKey = entry.key;
                final parentData = entry.value;
                final defaultSubs = <String>[]; // Default subcategories will be loaded from database
                final customSubs = _customSubcategories[parentKey] ?? [];
                
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            parentData['emoji']!,
                            style: TextStyle(fontSize: 24.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              parentData['name']!,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _addCustomSubcategory(parentKey),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFEAB308),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 12.h),
                      
                      // Default subcategories
                      if (defaultSubs.isNotEmpty) ...[
                        Text(
                          'Default categories:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 4.h,
                          children: defaultSubs.map((sub) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                sub, // sub is a String, not a Map
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      
                      // Custom subcategories
                      if (customSubs.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Text(
                          'Your custom categories:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFEAB308),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 4.h,
                          children: customSubs.map((sub) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAB308).withOpacity(0.1),
                                border: Border.all(color: const Color(0xFFEAB308)),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '📝 $sub',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFFEAB308),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  LuniGestureDetector(
                                    onTap: () => _removeCustomSubcategory(parentKey, sub),
                                    child: Icon(
                                      Icons.close,
                                      size: 12.w,
                                      color: const Color(0xFFEAB308),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 24.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 20.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'You can always add more categories later in the Track tab.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
