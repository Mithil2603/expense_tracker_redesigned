import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/core/utils/sms_parser.dart';
import 'package:expense_tracker_app/features/expenses/domain/entities/transaction_entity.dart';

void main() {
  group('SmsParser - Real Transaction Alert Parsing', () {
    test('Should parse a valid debit transaction correctly with category mapping', () {
      const sender = 'HDFCBK';
      const body = 'A/c XX1234 debited by INR 350.00 for payment to ZOMATO on 14-Jun-26. Bal: INR 12,345.67.';

      final parsed = SmsParser.parse(sender, body);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(350.0));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.title, equals('ZOMATO'));
      expect(parsed.expenseCategory, equals(ExpenseCategory.foodAndDining));
    });

    test('Should parse a valid credit transaction (salary) correctly with category mapping', () {
      const sender = 'SBIBNK';
      const body = 'Salary of Rs. 75,000.00 credited to Acc ending 5678 on 01-Jun-26. Payroll ref: 994827.';

      final parsed = SmsParser.parse(sender, body);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(75000.0));
      expect(parsed.type, equals(TransactionType.income));
      expect(parsed.incomeCategory, equals(IncomeCategory.salary));
    });

    test('Should identify payment method from body (UPI)', () {
      const sender = 'KOTAK';
      const body = 'UPI Ref 49282710: Rs. 120.50 paid to Swiggy from A/c XX8943.';

      final parsed = SmsParser.parse(sender, body);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(120.50));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.paymentMethod, equals(PaymentMethod.upi));
      expect(parsed.expenseCategory, equals(ExpenseCategory.foodAndDining));
    });
  });

  group('SmsParser - False Positive Mitigation (Exclusion filters)', () {
    test('Should ignore OTP verification code SMS', () {
      const sender = 'ICICIB';
      const body = 'Your OTP for transaction of Rs. 2,500.00 at Amazon is 582937. Do not share this code with anyone.';

      final parsed = SmsParser.parse(sender, body);

      expect(parsed, isNull);
    });

    test('Should ignore pre-approved loan offers', () {
      const sender = 'AXISBK';
      const body = 'Congratulation! You are eligible for a pre-approved personal loan of Rs 5,00,000. Apply now via Axis Mobile App.';

      final parsed = SmsParser.parse(sender, body);

      expect(parsed, isNull);
    });

    test('Should ignore recharge promotions', () {
      const sender = 'JIOINF';
      const body = 'Recharge now for Rs. 299 and get unlimited calls and 2GB data/day for 28 days. Offer valid till tomorrow!';

      final parsed = SmsParser.parse(sender, body);

      expect(parsed, isNull);
    });

    test('Should ignore cashback rewards/referral offers', () {
      const sender = 'PAYTM';
      const body = 'Get cashback of up to Rs. 100 on your first booking using Paytm. T&C apply.';

      final parsed = SmsParser.parse(sender, body);

      expect(parsed, isNull);
    });
  });

  group('SmsParser - Validation Rules', () {
    test('Should ignore personal messages from mobile numbers that lack transaction markers', () {
      const sender = '+919876543210';
      const body = 'Hey, check out this amount: Rs 1500. It is awesome!';

      final parsed = SmsParser.parse(sender, body);

      expect(parsed, isNull);
    });

    test('Should ignore messages lacking account or card reference', () {
      const sender = 'AXISBK';
      const body = 'Spent Rs. 500 at restaurant on 14-Jun-26.'; // missing account ending/card/vpa references

      final parsed = SmsParser.parse(sender, body);

      expect(parsed, isNull);
    });
  });
}
