import 'package:json_annotation/json_annotation.dart';

part 'survey_answer_model.g.dart';

@JsonSerializable()
class SurveyAnswerModel {
  final String id;
  final String userId;
  final String key;
  final dynamic valueJson;
  final DateTime createdAt;

  const SurveyAnswerModel({
    required this.id,
    required this.userId,
    required this.key,
    required this.valueJson,
    required this.createdAt,
  });

  factory SurveyAnswerModel.fromJson(Map<String, dynamic> json) => _$SurveyAnswerModelFromJson(json);
  Map<String, dynamic> toJson() => _$SurveyAnswerModelToJson(this);

  SurveyAnswerModel copyWith({
    String? id,
    String? userId,
    String? key,
    dynamic valueJson,
    DateTime? createdAt,
  }) {
    return SurveyAnswerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Survey question keys
class SurveyKeys {
  static const String school = 'school';
  static const String city = 'city';
  static const String age = 'age';
  static const String motivations = 'motivations';
  static const String hasJob = 'has_job';
  static const String jobHours = 'job_hours';
  static const String jobWage = 'job_wage';
  static const String hasSideHustle = 'has_side_hustle';
  static const String sideHustleIncome = 'side_hustle_income';
  static const String hasFamilySupport = 'has_family_support';
  static const String familySupportAmount = 'family_support_amount';
  static const String savingsWithdrawals = 'savings_withdrawals';
  static const String investingWithdrawals = 'investing_withdrawals';
  static const String rent = 'rent';
  static const String groceryAmount = 'grocery_amount';
  static const String groceryFrequency = 'grocery_frequency';
  static const String frequentMerchants = 'frequent_merchants';
  static const String customMerchants = 'custom_merchants';
}

// Motivation options
class MotivationOptions {
  static const List<String> options = [
    'I want to split my expenses better with roommates',
    'I want to be able to save for a trip',
    'Afford tuition and school fees',
    'Be able to have fun without worrying where my money is going',
    'Know my net worth at all times',
    'Be more aware of my spending habits at certain locations',
    'Where do I bleed money the most?',
  ];
}
