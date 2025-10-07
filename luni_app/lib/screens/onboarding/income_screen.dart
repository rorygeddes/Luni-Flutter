import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _jobHoursController = TextEditingController();
  final _jobWageController = TextEditingController();
  final _sideHustleController = TextEditingController();
  final _familySupportController = TextEditingController();
  final _savingsController = TextEditingController();
  final _investingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<OnboardingProvider>();
    _jobHoursController.text = provider.jobHours?.toString() ?? '';
    _jobWageController.text = provider.jobWage?.toString() ?? '';
    _sideHustleController.text = provider.sideHustleIncome?.toString() ?? '';
    _familySupportController.text = provider.familySupportAmount?.toString() ?? '';
    _savingsController.text = provider.savingsWithdrawals?.toString() ?? '';
    _investingController.text = provider.investingWithdrawals?.toString() ?? '';
  }

  @override
  void dispose() {
    _jobHoursController.dispose();
    _jobWageController.dispose();
    _sideHustleController.dispose();
    _familySupportController.dispose();
    _savingsController.dispose();
    _investingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about your income',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'This helps us create realistic budgets for you',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 32.h),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Job section
                      _buildSection(
                        title: 'Part-time Job',
                        icon: Icons.work,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Do you have a part-time job?'),
                              value: provider.hasJob,
                              onChanged: (value) => provider.setHasJob(value),
                              activeColor: const Color(0xFFEAB308),
                            ),
                            if (provider.hasJob) ...[
                              SizedBox(height: 16.h),
                              _buildTextField(
                                controller: _jobHoursController,
                                label: 'Hours per week',
                                hint: 'e.g., 20',
                                onChanged: (value) => provider.setJobHours(int.tryParse(value)),
                              ),
                              SizedBox(height: 16.h),
                              _buildTextField(
                                controller: _jobWageController,
                                label: 'Pay per hour (\$)',
                                hint: 'e.g., 15.50',
                                onChanged: (value) => provider.setJobWage(double.tryParse(value)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Side hustle section
                      _buildSection(
                        title: 'Side Hustle',
                        icon: Icons.monetization_on,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Do you have a side hustle?'),
                              value: provider.hasSideHustle,
                              onChanged: (value) => provider.setHasSideHustle(value),
                              activeColor: const Color(0xFFEAB308),
                            ),
                            if (provider.hasSideHustle) ...[
                              SizedBox(height: 16.h),
                              _buildTextField(
                                controller: _sideHustleController,
                                label: 'Monthly income (\$)',
                                hint: 'e.g., 200',
                                onChanged: (value) => provider.setSideHustleIncome(double.tryParse(value)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Family support section
                      _buildSection(
                        title: 'Family Support',
                        icon: Icons.family_restroom,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Do you get help from family?'),
                              value: provider.hasFamilySupport,
                              onChanged: (value) => provider.setHasFamilySupport(value),
                              activeColor: const Color(0xFFEAB308),
                            ),
                            if (provider.hasFamilySupport) ...[
                              SizedBox(height: 16.h),
                              _buildTextField(
                                controller: _familySupportController,
                                label: 'Monthly amount (\$)',
                                hint: 'e.g., 500',
                                onChanged: (value) => provider.setFamilySupportAmount(double.tryParse(value)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Savings/Investing section
                      _buildSection(
                        title: 'Savings & Investing',
                        icon: Icons.savings,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _savingsController,
                              label: 'Regular savings withdrawals (\$/month)',
                              hint: 'e.g., 100',
                              onChanged: (value) => provider.setSavingsWithdrawals(double.tryParse(value)),
                            ),
                            SizedBox(height: 16.h),
                            _buildTextField(
                              controller: _investingController,
                              label: 'Regular investing withdrawals (\$/month)',
                              hint: 'e.g., 50',
                              onChanged: (value) => provider.setInvestingWithdrawals(double.tryParse(value)),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Monthly income summary
                      if (provider.monthlyIncome > 0)
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
                                Icons.calculate,
                                color: Colors.green.shade700,
                                size: 24.w,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Monthly Income',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '\$${provider.monthlyIncome.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
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
              Icon(icon, color: const Color(0xFFEAB308), size: 20.w),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFEAB308), width: 2),
        ),
      ),
    );
  }
}
