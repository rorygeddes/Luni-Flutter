import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/category_model.dart';
import '../services/backend_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Map<String, List<CategoryModel>> _categoriesByParent = {};
  bool _isLoading = true;
  String? _expandedParent;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await BackendService.getCategories();
      
      // Group categories by parent
      final grouped = <String, List<CategoryModel>>{};
      for (final category in categories) {
        if (!grouped.containsKey(category.parentKey)) {
          grouped[category.parentKey] = [];
        }
        grouped[category.parentKey]!.add(category);
      }

      if (mounted) {
        setState(() {
          _categoriesByParent = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Categories',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: const Color(0xFFEAB308)),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Info banner
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAB308).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: const Color(0xFFEAB308), size: 20.w),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Organize your spending with custom categories. Tap to expand parent categories.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Parent categories
                  ..._categoriesByParent.keys.map((parentKey) {
                    final subcategories = _categoriesByParent[parentKey]!;
                    return _buildParentCategory(parentKey, subcategories);
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildParentCategory(String parentKey, List<CategoryModel> subcategories) {
    final isExpanded = _expandedParent == parentKey;
    final parentName = CategoryModel.getParentDisplayName(parentKey);
    final parentIcon = CategoryModel.getParentIcon(parentKey);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Parent header
          InkWell(
            onTap: () {
              setState(() {
                _expandedParent = isExpanded ? null : parentKey;
              });
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Text(
                    parentIcon,
                    style: TextStyle(fontSize: 28.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parentName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${subcategories.length} subcategories',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          
          // Subcategories (expanded)
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            ...subcategories.map((category) => _buildSubcategory(category, parentKey)).toList(),
            
            // Add subcategory button
            InkWell(
              onTap: () => _showAddSubcategoryDialog(parentKey, parentName),
              child: Container(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: const Color(0xFFEAB308), size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      'Add Subcategory',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFEAB308),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubcategory(CategoryModel category, String parentKey) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 40.w), // Indent for hierarchy
          if (category.icon != null) ...[
            Text(category.icon!, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
          if (!category.isDefault)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20.w),
              onPressed: () => _deleteCategory(category),
            ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final parentKeyController = TextEditingController();
    String? selectedIcon;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Parent Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: parentKeyController,
              decoration: const InputDecoration(
                labelText: 'Parent Key (e.g., custom_category)',
                hintText: 'lowercase_with_underscores',
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., Custom Category',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (parentKeyController.text.isNotEmpty && nameController.text.isNotEmpty) {
                await BackendService.createCategory(
                  parentKey: parentKeyController.text.toLowerCase().replaceAll(' ', '_'),
                  name: nameController.text,
                  icon: selectedIcon,
                );
                Navigator.of(context).pop();
                _loadCategories();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEAB308),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog(String parentKey, String parentName) {
    final nameController = TextEditingController();
    String? selectedIcon;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add to $parentName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Subcategory Name',
                  hintText: 'e.g., Starbucks',
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Select Icon (optional):',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  '☕', '🍕', '🍔', '🚗', '🎬', '📚', '💊', '✈️', '🏠', '💰'
                ].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedIcon = emoji;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: selectedIcon == emoji 
                            ? const Color(0xFFEAB308).withOpacity(0.2)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: selectedIcon == emoji 
                              ? const Color(0xFFEAB308)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(emoji, style: TextStyle(fontSize: 24.sp)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await BackendService.createCategory(
                    parentKey: parentKey,
                    name: nameController.text,
                    icon: selectedIcon,
                  );
                  Navigator.of(context).pop();
                  _loadCategories();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEAB308),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BackendService.deleteCategory(category.id);
      _loadCategories();
    }
  }
}

