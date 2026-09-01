import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/bmi_profile.dart';

class BmiProfileNotifier extends Notifier<BmiProfile> {
  @override
  BmiProfile build() => const BmiProfile();

  void applyCloudProfile({
    String? gender,
    required int age,
    required double height_cm,
    required double weight_kg,
  }) {
    state = BmiProfile(
      gender: gender,
      age: age,
      height_cm: height_cm,
      weight_kg: weight_kg,
      is_calculated: true,
    );
  }

  Future<void> saveFromCalculator({
    required String gender,
    required int age,
    required double height_cm,
    required double weight_kg,
  }) async {
    state = BmiProfile(
      gender: gender,
      age: age,
      height_cm: height_cm,
      weight_kg: weight_kg,
      is_calculated: true,
    );

    await ApiService.saveUserProfile({
      'gender': gender,
      'age': age,
      'height_cm': height_cm,
      'weight_kg': weight_kg,
    });
  }

  void reset() {
    state = const BmiProfile();
  }
}

final bmiProfileProvider =
    NotifierProvider<BmiProfileNotifier, BmiProfile>(BmiProfileNotifier.new);
