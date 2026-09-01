import 'package:flutter/material.dart';

Future<void> showStreakBrokenSheet(
  BuildContext context, {
  required int previous_streak,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheet_context) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1014),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF4A2030)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF375F).withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2A1418),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF375F).withOpacity(0.4)),
              ),
              child: const Center(
                child: Text('💔', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Streak broken',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your $previous_streak-day streak ended because you missed a day.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFCC8899),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Complete a meal today to start fresh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(sheet_context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF375F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'I will bounce back',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
