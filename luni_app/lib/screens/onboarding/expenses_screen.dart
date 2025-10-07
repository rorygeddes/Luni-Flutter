import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _rentController = TextEditingController();
  final _groceryAmountController = TextEditingController();
  final _groceryFrequencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<OnboardingProvider>();
    _rentController.text = provider.rent?.toString() ?? '';
    _groceryAmountController.text = provider.groceryAmount?.toString() ?? '';
    _groceryFrequencyController.text = provider.groceryFrequency?.toString() ?? '';
  }

  @override
  void dispose() {
    _rentController.dispose();
    _groceryAmountController.dispose();
    _groceryFrequencyController.dispose();
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
                'Tell us about your expenses',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'This helps us create realistic budgets',
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
                      // Rent section
                      _buildSection(
                        title: 'Housing',
                        icon: Icons.home,
                        child: _buildTextField(
                          controller: _rentController,
                          label: 'Monthly rent (\$)',
                          hint: 'e.g., 1200',
                          onChanged: (value) => provider.setRent(double.tryParse(value)),
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Groceries section
                      _buildSection(
                        title: 'Groceries',
                        icon: Icons.shopping_cart,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _groceryAmountController,
                              label: 'Amount per grocery trip (\$)',
                              hint: 'e.g., 80',
                              onChanged: (value) => provider.setGroceryAmount(double.tryParse(value)),
                            ),
                            SizedBox(height: 16.h),
                            _buildTextField(
                              controller: _groceryFrequencyController,
                              label: 'Trips per month',
                              hint: 'e.g., 4',
                              onChanged: (value) => provider.setGroceryFrequency(int.tryParse(value)),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Monthly grocery budget summary
                      if (provider.monthlyGroceryBudget > 0)
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
                                Icons.calculate,
                                color: Colors.blue.shade700,
                                size: 24.w,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Monthly Grocery Budget',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '\$${provider.monthlyGroceryBudget.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        color: Colors.blue.shade700,
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
