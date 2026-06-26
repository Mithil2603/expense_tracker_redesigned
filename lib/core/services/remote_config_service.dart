import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';
import 'detection/pattern_matcher.dart';
import 'detection/category_mapper.dart';
import 'detection/exclusion_filter.dart';
import 'detection/models/detection_pattern.dart';
import '../../features/expenses/domain/entities/transaction_entity.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // 1. Set default values from local assets
      await _setDefaultsFromAssets();

      // 2. Fetch and activate remote configs
      await _remoteConfig.fetchAndActivate();

      // 3. Apply the configs to the respective classes
      _applyConfigs();

      AppLogger.i('RemoteConfigService initialized and configs applied.');
    } catch (e) {
      AppLogger.e('Failed to initialize RemoteConfigService: $e');
      // If network fails, we just apply whatever defaults/local values are present
      _applyConfigs();
    }
  }

  Future<void> _setDefaultsFromAssets() async {
    try {
      final patternsStr = await rootBundle.loadString('assets/config/detection_patterns.json');
      final categoriesStr = await rootBundle.loadString('assets/config/category_mappings.json');
      final exclusionsStr = await rootBundle.loadString('assets/config/exclusion_rules.json');

      await _remoteConfig.setDefaults({
        'detection_patterns': patternsStr,
        'category_mappings': categoriesStr,
        'exclusion_rules': exclusionsStr,
      });
    } catch (e) {
      AppLogger.e('Failed to load default configs from assets: $e');
    }
  }

  void _applyConfigs() {
    try {
      _applyPatterns();
      _applyCategories();
      _applyExclusions();
    } catch (e) {
      AppLogger.e('Error applying remote configs: $e');
    }
  }

  void _applyPatterns() {
    final jsonStr = _remoteConfig.getString('detection_patterns');
    if (jsonStr.isEmpty) return;
    
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final List<DetectionPattern> patterns = [];
    
    for (final item in jsonList) {
      final map = item as Map<String, dynamic>;
      final extractionMapRaw = map['extractionMap'] as Map<String, dynamic>;
      
      patterns.add(DetectionPattern(
        id: map['id'],
        bank: map['bank'],
        type: map['type'],
        senderPatterns: List<String>.from(map['senderPatterns']),
        regex: RegExp(map['regex'], caseSensitive: false),
        extractionMap: extractionMapRaw.map((k, v) => MapEntry(k, v.toString())),
        paymentMethod: map['paymentMethod'],
        confidenceBoost: (map['confidenceBoost'] as num).toDouble(),
        version: map['version'],
        enabled: map['enabled'] ?? true,
      ));
    }
    
    PatternMatcher.updatePatterns(patterns);
  }

  void _applyCategories() {
    final jsonStr = _remoteConfig.getString('category_mappings');
    if (jsonStr.isEmpty) return;

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    
    final merchantMapRaw = map['merchantExpenseMap'] as Map<String, dynamic>? ?? {};
    final keywordMapRaw = map['keywordExpenseMap'] as Map<String, dynamic>? ?? {};
    final incomeMapRaw = map['keywordIncomeMap'] as Map<String, dynamic>? ?? {};

    final merchantMap = <String, ExpenseCategory>{};
    for (var entry in merchantMapRaw.entries) {
      final cat = ExpenseCategory.values.firstWhere(
        (e) => e.name == entry.value,
        orElse: () => ExpenseCategory.other,
      );
      merchantMap[entry.key] = cat;
    }

    final keywordMap = <String, ExpenseCategory>{};
    for (var entry in keywordMapRaw.entries) {
      final cat = ExpenseCategory.values.firstWhere(
        (e) => e.name == entry.value,
        orElse: () => ExpenseCategory.other,
      );
      keywordMap[entry.key] = cat;
    }

    final incomeMap = <String, IncomeCategory>{};
    for (var entry in incomeMapRaw.entries) {
      final cat = IncomeCategory.values.firstWhere(
        (e) => e.name == entry.value,
        orElse: () => IncomeCategory.other,
      );
      incomeMap[entry.key] = cat;
    }

    CategoryMapper.updateMappings(
      merchantExpenseMap: merchantMap,
      keywordExpenseMap: keywordMap,
      keywordIncomeMap: incomeMap,
    );
  }

  void _applyExclusions() {
    final jsonStr = _remoteConfig.getString('exclusion_rules');
    if (jsonStr.isEmpty) return;

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    
    ExclusionFilter.updateRules(
      otpPatterns: List<String>.from(map['otpPatterns'] ?? []),
      promoPatterns: List<String>.from(map['promoPatterns'] ?? []),
      reminderPatterns: List<String>.from(map['reminderPatterns'] ?? []),
      deliveryPatterns: List<String>.from(map['deliveryPatterns'] ?? []),
      transactionVerbs: List<String>.from(map['transactionVerbs'] ?? []),
    );
  }
}
