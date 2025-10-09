import 'package:flutter/material.dart';
import '../widgets/luni_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/luni_button.dart';

class WalletModal extends StatelessWidget {
  const WalletModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.h, // Make it higher on screen
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header with close button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wallet & Accounts',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                LuniGestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 20.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64.w,
                    color: const Color(0xFFEAB308),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Detailed Wallet View',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Swipe down to close',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}