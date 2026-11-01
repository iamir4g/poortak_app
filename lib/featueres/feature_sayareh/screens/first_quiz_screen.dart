import 'package:poortak/featueres/feature_sayareh/screens/quiz_screen.dart';

/// Compatibility entry point for starting a quiz.
/// The actual player lives in [QuizScreen] so progress stays on one route.
class FirstQuizScreen extends QuizScreen {
  static const routeName = "/first-quiz";

  const FirstQuizScreen({
    super.key,
    required super.quizId,
    required super.courseId,
    required super.title,
    super.description,
  });
}
