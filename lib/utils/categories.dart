import 'package:flutter/material.dart';

const List<String> expenseCategories = [
  'Shopping',
  'Groceries',
  'Utilities',
  'Dining',
  'Travel',
  'Entertainment',
  'Fuel',
  'Health',
  'Education',
  'Other',
];

const List<String> paymentModes = [
  'Credit Card',
  'Debit Card',
  'UPI',
  'Cash',
];

Color getCategoryColor(String category) {
  switch (category) {
    case 'Shopping':
      return const Color(0xFF6366F1); // Indigo
    case 'Groceries':
      return const Color(0xFF22C55E); // Green
    case 'Utilities':
      return const Color(0xFFF59E0B); // Amber
    case 'Dining':
      return const Color(0xFFEF4444); // Red
    case 'Travel':
      return const Color(0xFF3B82F6); // Blue
    case 'Entertainment':
      return const Color(0xFFA855F7); // Purple
    case 'Fuel':
      return const Color(0xFFF97316); // Orange
    case 'Health':
      return const Color(0xFF14B8A6); // Teal
    case 'Education':
      return const Color(0xFF0EA5E9); // Sky
    default:
      return const Color(0xFF64748B); // Slate
  }
}

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Shopping':
      return Icons.shopping_bag_outlined;
    case 'Groceries':
      return Icons.local_grocery_store_outlined;
    case 'Utilities':
      return Icons.bolt_outlined;
    case 'Dining':
      return Icons.restaurant_outlined;
    case 'Travel':
      return Icons.flight_outlined;
    case 'Entertainment':
      return Icons.movie_outlined;
    case 'Fuel':
      return Icons.local_gas_station_outlined;
    case 'Health':
      return Icons.favorite_outline;
    case 'Education':
      return Icons.school_outlined;
    default:
      return Icons.receipt_long_outlined;
  }
}
