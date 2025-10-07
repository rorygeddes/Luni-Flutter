import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/survey_answer_model.dart';

class MotivationsScreen extends StatefulWidget {
  const MotivationsScreen({super.key});

  @override
  State<MotivationsScreen> createState() => _MotivationsScreenState();
}

class _MotivationsScreenState extends State<MotivationsScreen> {
  List<String> _selectedMotivations = [];

  @override
  void initState() {
    super.initState();
    _selectedMotivations = context.read<OnboardingProvider>().motivations;
  }

  void _toggleMotivation(String motivation) {
    setState(() {
      if (_selectedMotivations.contains(motivation)) {
        _selectedMotivations.remove(motivation);
      } else if (_selectedMotivations.length < 3) {
        _selectedMotivations.add(motivation);
      } else {
        // Replace the first selected motivation
        _selectedMotivations.removeAt(0);
        _selectedMotivations.add(motivation);
      }
    });
    
    context.read<OnboardingProvider>().setMotivations(_selectedMotivations);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why are you using Luni?',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select up to 3 that most apply to you',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${_selectedMotivations.length}/3 selected',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFEAB308),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 32.h),
          
          Expanded(
            child: ListView.builder(
              itemCount: MotivationOptions.options.length,
              itemBuilder: (context, index) {
                final motivation = MotivationOptions.options[index];
                final isSelected = _selectedMotivations.contains(motivation);
                final isDisabled = !isSelected && _selectedMotivations.length >= 3;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: GestureDetector(
                    onTap: isDisabled ? null : () => _toggleMotivation(motivation),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFEAB308).withOpacity(0.1)
                            : Colors.grey.shade50,
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFFEAB308)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? const Color(0xFFEAB308)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFFEAB308)
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 16.w,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              motivation,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: isDisabled 
                                    ? Colors.grey.shade400
                                    : Colors.black,
                                fontWeight: isSelected 
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 24.h),
          
          if (_selectedMotivations.isNotEmpty)
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
                    Icons.lightbulb_outline,
                    color: Colors.blue.shade700,
                    size: 20.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Great! We\'ll customize your experience based on these goals.',
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
