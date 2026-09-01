import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../plans/models/recipe.dart';
import '../../plans/providers/recipe_ratings_provider.dart';
import '../../streak/providers/streak_provider.dart';
import '../../goals/providers/micro_goals_provider.dart';

Future<void> showMealCompleteSheet(BuildContext context, Recipe recipe) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _MealCompleteSheet(recipe: recipe),
  );
}

class _MealCompleteSheet extends ConsumerStatefulWidget {
  final Recipe recipe;

  const _MealCompleteSheet({required this.recipe});

  @override
  ConsumerState<_MealCompleteSheet> createState() => _MealCompleteSheetState();
}

class _MealCompleteSheetState extends ConsumerState<_MealCompleteSheet> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _note_controller = TextEditingController();
  String? _photo_path;
  bool? _liked;
  bool _is_saving = false;

  @override
  void dispose() {
    _note_controller.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() => _photo_path = file.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Camera permission denied or unavailable'
                : 'Could not open gallery',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _finishMeal() async {
    if (_is_saving) return;
    setState(() => _is_saving = true);

    final slug = widget.recipe.slug;
    if (slug != null && slug.isNotEmpty && _liked != null) {
      await ref.read(recipeRatingsProvider.notifier).saveRating(
            slug: slug,
            liked: _liked!,
            note: _note_controller.text.trim().isEmpty
                ? null
                : _note_controller.text.trim(),
          );
    }

    final streak_updated =
        await ref.read(streakProvider.notifier).recordMealCompletion();
    await ref
        .read(microGoalsProvider.notifier)
        .recordMealCompletion(widget.recipe);

    if (!mounted) return;
    Navigator.of(context).pop();

    final streak = ref.read(streakProvider);
    final message = streak_updated
        ? 'Streak updated! Day ${streak.current_streak} 🔥'
        : 'Meal already logged for today';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1DB954),
      ),
    );
  }

  Widget _rating_button({
    required bool liked,
    required IconData icon,
    required String label,
  }) {
    final selected = _liked == liked;
    final color = liked ? const Color(0xFF1DB954) : const Color(0xFFFF375F);

    return Expanded(
      child: OutlinedButton(
        onPressed: _is_saving ? null : () => setState(() => _liked = liked),
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? color : Colors.white,
          backgroundColor: selected ? color.withValues(alpha: 0.12) : null,
          side: BorderSide(
            color: selected ? color : const Color(0xFF2A2A2A),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.recipe.emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nice work!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.recipe.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'How was it?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _rating_button(
                liked: true,
                icon: Icons.thumb_up_outlined,
                label: 'Loved it',
              ),
              const SizedBox(width: 10),
              _rating_button(
                liked: false,
                icon: Icons.thumb_down_outlined,
                label: 'Not for me',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note_controller,
            enabled: !_is_saving,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Optional note',
              hintStyle: const TextStyle(color: Color(0xFF666666)),
              filled: true,
              fillColor: const Color(0xFF141414),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1DB954)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_photo_path != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(_photo_path!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _is_saving
                      ? null
                      : () => _pickPhoto(ImageSource.camera),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 18),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Photo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _is_saving
                      ? null
                      : () => _pickPhoto(ImageSource.gallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 18),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Gallery',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _is_saving ? null : _finishMeal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _is_saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _photo_path != null
                          ? 'Complete with photo'
                          : 'Complete meal',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
