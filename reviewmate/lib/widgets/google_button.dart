import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class GoogleButton extends StatelessWidget {

  final VoidCallback onTap;
  final bool loading;

  const GoogleButton({
    super.key,
    required this.onTap,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(

      onTap: onTap,

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.05),
            )
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.network(
              'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
              height: 30,
            ),

            const SizedBox(width: 15),

            loading
                ? const CircularProgressIndicator()
                : Text(
              "Continue with Google",
              style: AppStyles.heading(
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}