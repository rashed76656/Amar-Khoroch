import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String currencySymbol = '৳';
  static const String appName = 'Amar Khoroch';
}

/// Transaction type enumeration.
class TransactionType {
  TransactionType._();
  static const int income = 0;
  static const int expense = 1;
  static const int transfer = 2;

  static String label(int type) {
    switch (type) {
      case income:
        return 'Income';
      case expense:
        return 'Expense';
      case transfer:
        return 'Transfer';
      default:
        return '';
    }
  }
}

/// Account type enumeration.
class AccountType {
  AccountType._();
  static const int cash = 0;
  static const int bank = 1;
  static const int mobileWallet = 2;

  static String label(int type) {
    switch (type) {
      case cash:
        return 'Cash';
      case bank:
        return 'Bank';
      case mobileWallet:
        return 'Mobile Wallet';
      default:
        return '';
    }
  }

  static IconData icon(int type) {
    switch (type) {
      case cash:
        return CupertinoIcons.money_dollar;
      case bank:
        return CupertinoIcons.building_2_fill;
      case mobileWallet:
        return CupertinoIcons.device_phone_portrait;
      default:
        return CupertinoIcons.circle;
    }
  }
}

/// Category type enumeration.
class CategoryType {
  CategoryType._();
  static const int income = 0;
  static const int expense = 1;
}

/// Predefined icons available for category selection.
class CategoryIcons {
  CategoryIcons._();

  static const List<IconData> available = [
    CupertinoIcons.cart,
    CupertinoIcons.bag,
    CupertinoIcons.car,
    CupertinoIcons.house,
    CupertinoIcons.heart,
    CupertinoIcons.book,
    CupertinoIcons.gamecontroller,
    CupertinoIcons.airplane,
    CupertinoIcons.device_phone_portrait,
    CupertinoIcons.lightbulb,
    CupertinoIcons.gift,
    CupertinoIcons.briefcase,
    CupertinoIcons.paintbrush,
    CupertinoIcons.music_note,
    CupertinoIcons.film,
    CupertinoIcons.paw,
    CupertinoIcons.doc_text,
    CupertinoIcons.tag,
    CupertinoIcons.flame,
    CupertinoIcons.drop,
    CupertinoIcons.leaf_arrow_circlepath,
    CupertinoIcons.star,
    CupertinoIcons.bell,
    CupertinoIcons.camera,
    CupertinoIcons.scissors,
    CupertinoIcons.wrench,
    CupertinoIcons.cube,
    CupertinoIcons.person,
    CupertinoIcons.globe,
    CupertinoIcons.cloud,
    CupertinoIcons.umbrella,
    CupertinoIcons.bandage,
    CupertinoIcons.creditcard,
    CupertinoIcons.chart_bar,
    CupertinoIcons.bus,
    CupertinoIcons.sportscourt,
    CupertinoIcons.wifi,
    CupertinoIcons.money_dollar,
    CupertinoIcons.building_2_fill,
    CupertinoIcons.tv,
  ];

  /// Lookup a const IconData by its codePoint from the predefined list.
  /// This avoids runtime `IconData()` construction, which breaks icon tree shaking.
  static IconData fromCodePoint(int codePoint) {
    return available.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => CupertinoIcons.circle,
    );
  }
}

/// Predefined colors available for category selection.
class CategoryColors {
  CategoryColors._();

  static const List<Color> available = [
    Color(0xFFFF3B30), // Red
    Color(0xFFFF9500), // Orange
    Color(0xFFFFCC00), // Yellow
    Color(0xFF34C759), // Green
    Color(0xFF007AFF), // Blue
    Color(0xFF5856D6), // Purple
    Color(0xFFAF52DE), // Violet
    Color(0xFFFF2D55), // Pink
    Color(0xFF5AC8FA), // Light Blue
    Color(0xFF00C7BE), // Teal
    Color(0xFFA2845E), // Brown
    Color(0xFF8E8E93), // Gray
  ];
}
