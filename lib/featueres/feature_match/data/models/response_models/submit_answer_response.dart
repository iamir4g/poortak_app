class SubmitAnswerResponse {
  final AnswerResponse data;

  SubmitAnswerResponse({required this.data});
}

class AnswerResponse {
  final bool isCorrect;

  AnswerResponse({required this.isCorrect});
}
