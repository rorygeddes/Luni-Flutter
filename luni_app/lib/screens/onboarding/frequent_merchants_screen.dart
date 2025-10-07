import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class FrequentMerchantsScreen extends StatefulWidget {
  const FrequentMerchantsScreen({super.key});

  @override
  State<FrequentMerchantsScreen> createState() => _FrequentMerchantsScreenState();
}

class _FrequentMerchantsScreenState extends State<FrequentMerchantsScreen> {
  final _customMerchantController = TextEditingController();
  List<String> _selectedMerchants = [];
  List<String> _customMerchants = [];

  final List<Map<String, dynamic>> _commonMerchants = [
    {'name': 'Starbucks', 'emoji': '☕'},
    {'name': 'McDonald\'s', 'emoji': '🍔'},
    {'name': 'Subway', 'emoji': '🥪'},
    {'name': 'Tim Hortons', 'emoji': '🍩'},
    {'name': 'Pizza Pizza', 'emoji': '🍕'},
    {'name': 'Uber Eats', 'emoji': '🚗'},
    {'name': 'Skip the Dishes', 'emoji': '🍽️'},
    {'name': 'Netflix', 'emoji': '📺'},
    {'name': 'Spotify', 'emoji': '🎵'},
    {'name': 'Amazon Prime', 'emoji': '📦'},
    {'name': 'Apple Music', 'emoji': '🎧'},
    {'name': 'YouTube Premium', 'emoji': '📱'},
    {'name': 'Gym Membership', 'emoji': '💪'},
    {'name': 'Uber', 'emoji': '🚗'},
    {'name': 'Lyft', 'emoji': '🚙'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<OnboardingProvider>();
    _selectedMerchants = List.from(provider.frequentMerchants);
    _customMerchants = List.from(provider.customMerchants);
  }

  @override
  void dispose() {
    _customMerchantController.dispose();
    super.dispose();
  }

  void _toggleMerchant(String merchant) {
    setState(() {
      if (_selectedMerchants.contains(merchant)) {
        _selectedMerchants.remove(merchant);
      } else {
        _selectedMerchants.add(merchant);
      }
    });
    _updateProvider();
  }

  void _addCustomMerchant() {
    final merchant = _customMerchantController.text.trim();
    if (merchant.isNotEmpty && !_customMerchants.contains(merchant)) {
      setState(() {
        _customMerchants.add(merchant);
        _customMerchantController.clear();
      });
      _updateProvider();
    }
  }

  void _removeCustomMerchant(String merchant) {
    setState(() {
      _customMerchants.remove(merchant);
    });
    _updateProvider();
  }

  void _updateProvider() {
    final provider = context.read<OnboardingProvider>();
    provider.setFrequentMerchants(_selectedMerchants);
    provider.setCustomMerchants(_customMerchants);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where do you spend money?',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select places you frequently visit or subscribe to',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 32.h),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Common merchants
                  Text(
                    'Common Places',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _commonMerchants.map((merchant) {
                      final isSelected = _selectedMerchants.contains(merchant['name']);
                      return GestureDetector(
                        onTap: () => _toggleMerchant(merchant['name']),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFFEAB308).withOpacity(0.1)
                                : Colors.grey.shade100,
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFFEAB308)
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                merchant['emoji'],
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                merchant['name'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isSelected 
                                      ? const Color(0xFFEAB308)
                                      : Colors.black,
                                  fontWeight: isSelected 
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Custom merchants
                  Text(
                    'Add Your Own',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customMerchantController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Local Coffee Shop',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: Color(0xFFEAB308), width: 2),
                            ),
                          ),
                          onSubmitted: (_) => _addCustomMerchant(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                        onPressed: _addCustomMerchant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Custom merchants list
                  if (_customMerchants.isNotEmpty)
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _customMerchants.map((merchant) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAB308).withOpacity(0.1),
                            border: Border.all(color: const Color(0xFFEAB308)),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '📝',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                merchant,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFFEAB308),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              GestureDetector(
                                onTap: () => _removeCustomMerchant(merchant),
                                child: Icon(
                                  Icons.close,
                                  size: 16.w,
                                  color: const Color(0xFFEAB308),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  
                  SizedBox(height: 32.h),
                  
                  // Summary
                  if (_selectedMerchants.isNotEmpty || _customMerchants.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 24.w,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Great! We\'ll use this to help categorize your transactions automatically.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
