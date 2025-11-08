import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:med_parser/features/onboarding/data/onboarding_repository.dart';

import '../../../test_util/mocks.dart';

void main() {
  group('OnboardingRepository Tests', () {
    late OnboardingRepository onboardingRepository;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      onboardingRepository = OnboardingRepository(mockSharedPreferences);
    });

    test('isOnboardingComplete returns true when SharedPreferences has true',
        () {
      when(() => mockSharedPreferences.getBool(
          OnboardingRepository.onboardingCompleteKey)).thenReturn(true);
      expect(onboardingRepository.isOnboardingComplete(), isTrue);
    });

    test('isOnboardingComplete returns false when SharedPreferences has false',
        () {
      when(() => mockSharedPreferences.getBool(
          OnboardingRepository.onboardingCompleteKey)).thenReturn(false);
      expect(onboardingRepository.isOnboardingComplete(), isFalse);
    });

    test(
        'isOnboardingComplete returns false (default) when SharedPreferences has null',
        () {
      when(() => mockSharedPreferences.getBool(
          OnboardingRepository.onboardingCompleteKey)).thenReturn(null);
      expect(onboardingRepository.isOnboardingComplete(), isFalse);
    });

    test('setOnboardingComplete calls setBool with true and completes',
        () async {
      when(() => mockSharedPreferences.setBool(
              OnboardingRepository.onboardingCompleteKey, true))
          .thenAnswer((_) async => true);

      await onboardingRepository.setOnboardingComplete();

      verify(() => mockSharedPreferences.setBool(
          OnboardingRepository.onboardingCompleteKey, true)).called(1);
    });
  });
}
