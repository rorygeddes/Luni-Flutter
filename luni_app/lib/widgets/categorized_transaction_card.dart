import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Transaction card with gold border for categorized transactions
/// Use this in your Track screen to show transactions
class CategorizedTransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback? onTap;

  const CategorizedTransactionCard({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCategorized = transaction['is_categorized'] == true;
    final amount = (transaction['amount'] ?? 0.0).toDouble();
    final description = transaction['ai_description'] ?? transaction['description'] ?? 'Unknown';
    final rawDescription = transaction['description'] ?? 'Unknown';
    final category = transaction['category'];
    final subcategory = transaction['subcategory'];
    final date = transaction['date'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCategorized ? const Color(0xFFD4AF37) : Colors.grey.shade300,
          width: isCategorized ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: isCategorized
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Description and Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isCategorized ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isCategorized && description != rawDescription)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Raw: $rawDescription',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '\$${amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: amount < 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Category tags (if categorized)
              if (isCategorized && category != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildCategoryTag(category, isPrimary: true),
                    if (subcategory != null)
                      _buildCategoryTag(subcategory, isPrimary: false),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Uncategorized',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Date
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String label, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFFD4AF37).withOpacity(0.2)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? Border.all(color: const Color(0xFFD4AF37), width: 1)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
          color: isPrimary ? const Color(0xFFD4AF37) : Colors.grey[700],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    
    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'Unknown date';
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime).inDays;
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return DateFormat('MMM d, yyyy').format(dateTime);
      }
    } catch (e) {
      return date.toString();
    }
  }
}

