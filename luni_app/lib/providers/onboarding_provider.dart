import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_answer_model.dart';
import '../models/category_model.dart';
import '../services/auth_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Personal info
  String? _school;
  String? _city;
  int? _age;
  
  // Motivations
  List<String> _motivations = [];
  
  // Income
  bool _hasJob = false;
  int? _jobHours;
  double? _jobWage;
  bool _hasSideHustle = false;
  double? _sideHustleIncome;
  bool _hasFamilySupport = false;
  double? _familySupportAmount;
  double? _savingsWithdrawals;
  double? _investingWithdrawals;
  
  // Expenses
  double? _rent;
  double? _groceryAmount;
  int? _groceryFrequency; // times per month
  
  // Merchants
  List<String> _frequentMerchants = [];
  List<String> _customMerchants = [];
  
  // Categories
  Map<String, List<String>> _customSubcategories = {};

  // New onboarding fields
  String? _lifeStage; // Student, Young Professional, Settling In, Parent, Retiring/Retired
  bool _demoMode = false;

  // Getters
  String? get school => _school;
  String? get city => _city;
  int? get age => _age;
  List<String> get motivations => _motivations;
  bool get hasJob => _hasJob;
  int? get jobHours => _jobHours;
  double? get jobWage => _jobWage;
  bool get hasSideHustle => _hasSideHustle;
  double? get sideHustleIncome => _sideHustleIncome;
  bool get hasFamilySupport => _hasFamilySupport;
  double? get familySupportAmount => _familySupportAmount;
  double? get savingsWithdrawals => _savingsWithdrawals;
  double? get investingWithdrawals => _investingWithdrawals;
  double? get rent => _rent;
  double? get groceryAmount => _groceryAmount;
  int? get groceryFrequency => _groceryFrequency;
  List<String> get frequentMerchants => _frequentMerchants;
  List<String> get customMerchants => _customMerchants;
  Map<String, List<String>> get customSubcategories => _customSubcategories;
  String? get lifeStage => _lifeStage;
  bool get demoMode => _demoMode;

  // Setters
  void setSchool(String? school) {
    _school = school;
    notifyListeners();
  }

  void setCity(String? city) {
    _city = city;
    notifyListeners();
  }

  void setAge(int? age) {
    _age = age;
    notifyListeners();
  }

  void setMotivations(List<String> motivations) {
    _motivations = motivations;
    notifyListeners();
  }

  void setHasJob(bool hasJob) {
    _hasJob = hasJob;
    if (!hasJob) {
      _jobHours = null;
      _jobWage = null;
    }
    notifyListeners();
  }

  void setJobHours(int? hours) {
    _jobHours = hours;
    notifyListeners();
  }

  void setJobWage(double? wage) {
    _jobWage = wage;
    notifyListeners();
  }

  void setHasSideHustle(bool hasSideHustle) {
    _hasSideHustle = hasSideHustle;
    if (!hasSideHustle) {
      _sideHustleIncome = null;
    }
    notifyListeners();
  }

  void setSideHustleIncome(double? income) {
    _sideHustleIncome = income;
    notifyListeners();
  }

  void setHasFamilySupport(bool hasFamilySupport) {
    _hasFamilySupport = hasFamilySupport;
    if (!hasFamilySupport) {
      _familySupportAmount = null;
    }
    notifyListeners();
  }

  void setFamilySupportAmount(double? amount) {
    _familySupportAmount = amount;
    notifyListeners();
  }

  void setSavingsWithdrawals(double? withdrawals) {
    _savingsWithdrawals = withdrawals;
    notifyListeners();
  }

  void setInvestingWithdrawals(double? withdrawals) {
    _investingWithdrawals = withdrawals;
    notifyListeners();
  }

  void setRent(double? rent) {
    _rent = rent;
    notifyListeners();
  }

  void setGroceryAmount(double? amount) {
    _groceryAmount = amount;
    notifyListeners();
  }

  void setGroceryFrequency(int? frequency) {
    _groceryFrequency = frequency;
    notifyListeners();
  }

  void setFrequentMerchants(List<String> merchants) {
    _frequentMerchants = merchants;
    notifyListeners();
  }

  void setCustomMerchants(List<String> merchants) {
    _customMerchants = merchants;
    notifyListeners();
  }

  void setCustomSubcategories(Map<String, List<String>> subcategories) {
    _customSubcategories = subcategories;
    notifyListeners();
  }

  void setLifeStage(String? value) {
    _lifeStage = value;
    notifyListeners();
  }

  void setDemoMode(bool value) {
    _demoMode = value;
    notifyListeners();
  }

  // Calculate monthly income
  double get monthlyIncome {
    double income = 0;
    
    // Job income
    if (_hasJob && _jobHours != null && _jobWage != null) {
      income += _jobHours! * _jobWage! * 4.33; // 4.33 weeks per month
    }
    
    // Side hustle income
    if (_hasSideHustle && _sideHustleIncome != null) {
      income += _sideHustleIncome!;
    }
    
    // Family support
    if (_hasFamilySupport && _familySupportAmount != null) {
      income += _familySupportAmount!;
    }
    
    // Savings/investing withdrawals
    if (_savingsWithdrawals != null) {
      income += _savingsWithdrawals!;
    }
    if (_investingWithdrawals != null) {
      income += _investingWithdrawals!;
    }
    
    return income;
  }

  // Calculate monthly grocery budget
  double get monthlyGroceryBudget {
    if (_groceryAmount != null && _groceryFrequency != null) {
      return _groceryAmount! * _groceryFrequency!;
    }
    return 0;
  }

  // Save onboarding data to database
  Future<void> saveOnboardingData() async {
    final user = AuthService.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Save survey answers
      final surveyAnswers = [
        if (_school != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.id,
          key: SurveyKeys.school,
          valueJson: _school,
          createdAt: DateTime.now(),
        ),
        if (_city != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '1',
          userId: user.id,
          key: SurveyKeys.city,
          valueJson: _city,
          createdAt: DateTime.now(),
        ),
        if (_age != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '2',
          userId: user.id,
          key: SurveyKeys.age,
          valueJson: _age,
          createdAt: DateTime.now(),
        ),
        SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '3',
          userId: user.id,
          key: SurveyKeys.motivations,
          valueJson: _motivations,
          createdAt: DateTime.now(),
        ),
        SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '4',
          userId: user.id,
          key: SurveyKeys.hasJob,
          valueJson: _hasJob,
          createdAt: DateTime.now(),
        ),
        if (_jobHours != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '5',
          userId: user.id,
          key: SurveyKeys.jobHours,
          valueJson: _jobHours,
          createdAt: DateTime.now(),
        ),
        if (_jobWage != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '6',
          userId: user.id,
          key: SurveyKeys.jobWage,
          valueJson: _jobWage,
          createdAt: DateTime.now(),
        ),
        SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '7',
          userId: user.id,
          key: SurveyKeys.hasSideHustle,
          valueJson: _hasSideHustle,
          createdAt: DateTime.now(),
        ),
        if (_sideHustleIncome != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '8',
          userId: user.id,
          key: SurveyKeys.sideHustleIncome,
          valueJson: _sideHustleIncome,
          createdAt: DateTime.now(),
        ),
        SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '9',
          userId: user.id,
          key: SurveyKeys.hasFamilySupport,
          valueJson: _hasFamilySupport,
          createdAt: DateTime.now(),
        ),
        if (_familySupportAmount != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '10',
          userId: user.id,
          key: SurveyKeys.familySupportAmount,
          valueJson: _familySupportAmount,
          createdAt: DateTime.now(),
        ),
        if (_savingsWithdrawals != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '11',
          userId: user.id,
          key: SurveyKeys.savingsWithdrawals,
          valueJson: _savingsWithdrawals,
          createdAt: DateTime.now(),
        ),
        if (_investingWithdrawals != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '12',
          userId: user.id,
          key: SurveyKeys.investingWithdrawals,
          valueJson: _investingWithdrawals,
          createdAt: DateTime.now(),
        ),
        if (_rent != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '13',
          userId: user.id,
          key: SurveyKeys.rent,
          valueJson: _rent,
          createdAt: DateTime.now(),
        ),
        if (_groceryAmount != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '14',
          userId: user.id,
          key: SurveyKeys.groceryAmount,
          valueJson: _groceryAmount,
          createdAt: DateTime.now(),
        ),
        if (_groceryFrequency != null) SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '15',
          userId: user.id,
          key: SurveyKeys.groceryFrequency,
          valueJson: _groceryFrequency,
          createdAt: DateTime.now(),
        ),
        SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '16',
          userId: user.id,
          key: SurveyKeys.frequentMerchants,
          valueJson: _frequentMerchants,
          createdAt: DateTime.now(),
        ),
        SurveyAnswerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '17',
          userId: user.id,
          key: SurveyKeys.customMerchants,
          valueJson: _customMerchants,
          createdAt: DateTime.now(),
        ),
      ];

      // Insert survey answers
      for (final answer in surveyAnswers) {
        await _supabase
            .from('survey_answers')
            .insert(answer.toJson());
      }

      // Create default categories
      await _createDefaultCategories(user.id);

    } catch (e) {
      throw Exception('Failed to save onboarding data: $e');
    }
  }

  Future<void> _createDefaultCategories(String userId) async {
    // Note: Default categories are now seeded via SQL (setup_categories_database.sql)
    // This method now only handles user's custom subcategories from onboarding
    
    // Create custom subcategories selected during onboarding
    if (_customSubcategories.isEmpty) return;
    
    for (final entry in _customSubcategories.entries) {
      for (final subName in entry.value) {
        try {
          await _supabase.from('categories').insert({
            'user_id': userId,
            'parent_key': entry.key,
            'name': subName,
            'icon': '📝',
            'is_default': false,
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('Error creating custom category: $e');
          // Continue with other categories even if one fails
        }
      }
    }
    
    print('✅ Created ${_customSubcategories.length} custom category groups');
  }
}
