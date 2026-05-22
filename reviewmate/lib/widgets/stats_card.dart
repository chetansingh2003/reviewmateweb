import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class StatsCard extends StatelessWidget {

  final String title;
  final String subtitle;

  const StatsCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),

      child: Column(
        children: [

          Text(
            title,
            style: AppStyles.heading(
              size: 24,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: AppStyles.body(),
          ),
        ],
      ),
    );
  }
}