import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  final _cityController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<OnboardingProvider>();
    _schoolController.text = provider.school ?? '';
    _cityController.text = provider.city ?? '';
    _ageController.text = provider.age?.toString() ?? '';
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<OnboardingProvider>();
      provider.setSchool(_schoolController.text.trim().isEmpty ? null : _schoolController.text.trim());
      provider.setCity(_cityController.text.trim().isEmpty ? null : _cityController.text.trim());
      provider.setAge(_ageController.text.trim().isEmpty ? null : int.tryParse(_ageController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This helps us personalize your experience',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87, // Darker text for better contrast
              ),
            ),
            SizedBox(height: 40.h),
            
            _buildTextField(
              controller: _schoolController,
              label: 'School/University',
              hint: 'e.g., University of British Columbia',
              icon: Icons.school,
            ),
            
            SizedBox(height: 24.h),
            
            _buildTextField(
              controller: _cityController,
              label: 'City',
              hint: 'e.g., Vancouver',
              icon: Icons.location_city,
            ),
            
            SizedBox(height: 24.h),
            
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              hint: 'e.g., 20',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final age = int.tryParse(value);
                  if (age == null || age < 16 || age > 100) {
                    return 'Please enter a valid age (16-100)';
                  }
                }
                return null;
              },
            ),
            
            const Spacer(),
            
            Text(
              '💡 This information helps us understand your student lifestyle and provide better financial insights.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87, // Darker text for better contrast
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (value) => _saveAndContinue(),
      textInputAction: TextInputAction.next, // Better keyboard navigation
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.black87), // Darker label text
        hintStyle: TextStyle(color: Colors.grey.shade600), // Darker hint text
        prefixIcon: Icon(icon, color: const Color(0xFFEAB308)),
        filled: true,
        fillColor: Colors.white, // White background for better contrast
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFEAB308), width: 2),
        ),
      ),
    );
  }
}
