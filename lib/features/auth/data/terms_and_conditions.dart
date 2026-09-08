import '../../../core/config/app_brand.dart';

class TermsAndConditions {
  static const version = '1.1';

  static const last_updated = 'September 2026';

  static String get intro =>
      'By creating an account or using ${AppBrand.name}, you agree to these Terms & Conditions. '
      'Please read them carefully before continuing.';

  static const sections = <TermsSection>[
    TermsSection(
      title: '1. About NutriFit',
      body:
          'NutriFit is a wellness and meal-planning application. It helps you explore recipes, '
          'track habits, and receive personalized suggestions. It is not a licensed medical, '
          'dietetic, or healthcare service.',
    ),
    TermsSection(
      title: '2. Not Medical Advice',
      body:
          'Content in this app—including meal plans, BMI information, symptom tracking, and health '
          'insights—is provided for general educational and lifestyle purposes only. It does not '
          'constitute medical advice, diagnosis, or treatment. Always consult a qualified healthcare '
          'professional before making changes to your diet, exercise, or health routine, especially '
          'if you have allergies, chronic conditions, are pregnant, or take medication.',
    ),
    TermsSection(
      title: '3. AI-Generated Content',
      body:
          'Several features use artificial intelligence, including meal recommendations, symptom '
          'analysis, fridge-based recipe matching, and personalized tips. AI outputs may be '
          'inaccurate, incomplete, outdated, or inconsistent—this is sometimes called '
          '"hallucination." You must independently verify ingredients, nutrition facts, cooking '
          'instructions, allergen safety, and health-related suggestions before relying on them. '
          'Do not treat AI responses as factual or medically authoritative.',
    ),
    TermsSection(
      title: '4. Your Responsibility',
      body:
          'You are responsible for the information you provide, how you use the app, and any '
          'decisions you make based on its content. You agree not to use NutriFit as a '
          'substitute for professional care or emergency services. In a medical emergency, '
          'contact local emergency services immediately.',
    ),
    TermsSection(
      title: '5. Account & Acceptable Use',
      body:
          'You agree to provide accurate account information and keep your login credentials secure. '
          'You will not misuse the app, attempt unauthorized access, scrape data, or use the '
          'service for unlawful purposes. We may suspend or terminate accounts that violate these terms.',
    ),
    TermsSection(
      title: '6. Data & Privacy',
      body:
          'We store profile, preference, and usage data to personalize your experience and sync '
          'across devices. Health-related inputs you submit may be processed by AI services to '
          'generate recommendations. Do not enter information you are not comfortable storing or '
          'processing for this purpose.',
    ),
    TermsSection(
      title: '7. Limitation of Liability',
      body:
          'To the fullest extent permitted by law, NutriFit and its operators are not liable for '
          'any injury, illness, allergic reaction, nutritional harm, data loss, or other damages '
          'arising from your use of the app or reliance on AI-generated content. The app is provided '
          '"as is" without warranties of accuracy, fitness for a particular purpose, or uninterrupted '
          'availability.',
    ),
    TermsSection(
      title: '8. Changes to These Terms',
      body:
          'We may update these Terms from time to time. Material changes may require renewed acceptance '
          'before you continue using certain features. The version shown in the app reflects the terms '
          'you are agreeing to.',
    ),
    TermsSection(
      title: '9. Contact',
      body:
          'Questions about these Terms can be sent to ${AppBrand.support_email}.',
    ),
  ];
}

class TermsSection {
  final String title;
  final String body;

  const TermsSection({
    required this.title,
    required this.body,
  });
}
