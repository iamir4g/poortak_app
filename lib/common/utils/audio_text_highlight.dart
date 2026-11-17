import 'package:poortak/common/utils/sentence_splitter.dart';

/// Karaoke-style highlight state derived from audio progress.
class AudioHighlightState {
  final double progress;
  final int sentenceIndex;
  final int wordIndexInSentence;
  final int globalWordIndex;
  final double wordProgress;

  const AudioHighlightState({
    this.progress = 0,
    this.sentenceIndex = 0,
    this.wordIndexInSentence = 0,
    this.globalWordIndex = 0,
    this.wordProgress = 0,
  });

  static const idle = AudioHighlightState();

  @override
  bool operator ==(Object other) {
    return other is AudioHighlightState &&
        other.progress == progress &&
        other.sentenceIndex == sentenceIndex &&
        other.wordIndexInSentence == wordIndexInSentence &&
        other.globalWordIndex == globalWordIndex &&
        other.wordProgress == wordProgress;
  }

  @override
  int get hashCode => Object.hash(
        progress,
        sentenceIndex,
        wordIndexInSentence,
        globalWordIndex,
        wordProgress,
      );
}

class HighlightWord {
  /// Display text for this token (may include trailing spaces / emoji).
  final String text;
  final int sentenceIndex;
  final int wordIndexInSentence;
  final int globalWordIndex;
  final double weight;

  const HighlightWord({
    required this.text,
    required this.sentenceIndex,
    required this.wordIndexInSentence,
    required this.globalWordIndex,
    required this.weight,
  });
}

class HighlightTimeline {
  final List<String> sentences;
  final List<HighlightWord> words;
  final List<double> cumulativeWeights;
  final double totalWeight;

  const HighlightTimeline({
    required this.sentences,
    required this.words,
    required this.cumulativeWeights,
    required this.totalWeight,
  });
}

final _speakableCharPattern = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// Builds a char-weighted timeline for [text], with a short virtual pause
/// between sentences (~8% of the preceding sentence weight).
///
/// Emoji / punctuation-only tokens get **no** timeline weight and are merged
/// into adjacent speakable words so karaoke never stalls on them.
HighlightTimeline buildHighlightTimeline(String text) {
  final rawSentences = splitIntoSentences(text);
  final sentences = _collapseNonSpeakableSentences(rawSentences);
  if (sentences.isEmpty) {
    return const HighlightTimeline(
      sentences: [],
      words: [],
      cumulativeWeights: [],
      totalWeight: 0,
    );
  }

  final words = <HighlightWord>[];
  final cumulative = <double>[];
  var total = 0.0;
  var globalWordIndex = 0;

  for (var s = 0; s < sentences.length; s++) {
    final sentence = sentences[s];
    final tokens = _mergeNonSpeakableTokens(
      _wordTokensWithTrailingSpace(sentence),
    );
    var sentenceWordWeight = 0.0;
    var wordIndexInSentence = 0;

    for (final token in tokens) {
      final weight = _wordWeight(token);
      // Skip pure non-speakable leftovers (should be rare after merge).
      if (weight <= 0 && words.isNotEmpty) {
        final prev = words.last;
        words[words.length - 1] = HighlightWord(
          text: prev.text + token,
          sentenceIndex: prev.sentenceIndex,
          wordIndexInSentence: prev.wordIndexInSentence,
          globalWordIndex: prev.globalWordIndex,
          weight: prev.weight,
        );
        continue;
      }

      total += weight;
      sentenceWordWeight += weight;
      words.add(
        HighlightWord(
          text: token,
          sentenceIndex: s,
          wordIndexInSentence: wordIndexInSentence,
          globalWordIndex: globalWordIndex,
          weight: weight,
        ),
      );
      cumulative.add(total);
      wordIndexInSentence++;
      globalWordIndex++;
    }

    // Virtual pause between sentences absorbed into the last word.
    if (s < sentences.length - 1 &&
        sentenceWordWeight > 0 &&
        words.isNotEmpty) {
      final pause = sentenceWordWeight * 0.08;
      total += pause;
      final last = words.last;
      words[words.length - 1] = HighlightWord(
        text: last.text,
        sentenceIndex: last.sentenceIndex,
        wordIndexInSentence: last.wordIndexInSentence,
        globalWordIndex: last.globalWordIndex,
        weight: last.weight + pause,
      );
      cumulative[cumulative.length - 1] = total;
    }
  }

  return HighlightTimeline(
    sentences: sentences,
    words: words,
    cumulativeWeights: cumulative,
    totalWeight: total,
  );
}

AudioHighlightState mapProgressToHighlight(
  double progress, {
  required HighlightTimeline timeline,
}) {
  final p = progress.clamp(0.0, 1.0);
  if (timeline.words.isEmpty || timeline.totalWeight <= 0) {
    return AudioHighlightState(progress: p);
  }

  final target = p * timeline.totalWeight;
  var index = 0;
  for (; index < timeline.cumulativeWeights.length; index++) {
    if (target <= timeline.cumulativeWeights[index]) break;
  }
  if (index >= timeline.words.length) {
    index = timeline.words.length - 1;
  }

  // Never land on a zero-weight token; prefer the previous speakable word.
  while (index > 0 && timeline.words[index].weight <= 0) {
    index--;
  }

  final word = timeline.words[index];
  final prevCumulative =
      index == 0 ? 0.0 : timeline.cumulativeWeights[index - 1];
  final span = (timeline.cumulativeWeights[index] - prevCumulative).clamp(
    0.0001,
    double.infinity,
  );
  final wordProgress = ((target - prevCumulative) / span).clamp(0.0, 1.0);

  return AudioHighlightState(
    progress: p,
    sentenceIndex: word.sentenceIndex,
    wordIndexInSentence: word.wordIndexInSentence,
    globalWordIndex: word.globalWordIndex,
    wordProgress: wordProgress,
  );
}

AudioHighlightState highlightStateForText(String text, double progress) {
  return mapProgressToHighlight(
    progress,
    timeline: buildHighlightTimeline(text),
  );
}

int _speakableCount(String token) {
  return _speakableCharPattern.allMatches(token).length;
}

/// Weight only real spoken letters/digits. Emoji and punctuation do not
/// consume karaoke timeline (UTF-16 emoji length was stalling highlights).
double _wordWeight(String token) {
  final speakable = _speakableCount(token);
  if (speakable == 0) return 0.0;
  return speakable.toDouble();
}

/// Merge sentences that have no speakable text into the previous sentence
/// (e.g. `"👋"` after `"Hello!"`).
List<String> _collapseNonSpeakableSentences(List<String> sentences) {
  if (sentences.isEmpty) return const [];
  final merged = <String>[];
  for (final sentence in sentences) {
    if (merged.isNotEmpty && _speakableCount(sentence) == 0) {
      merged[merged.length - 1] = merged.last + sentence;
    } else {
      merged.add(sentence);
    }
  }
  return merged;
}

/// Attach emoji / punctuation-only tokens to the previous speakable word.
/// Leading non-speakable tokens wait for the next speakable word.
List<String> _mergeNonSpeakableTokens(List<String> tokens) {
  if (tokens.isEmpty) return const [];
  final merged = <String>[];
  final pendingLeading = StringBuffer();

  for (final token in tokens) {
    if (_speakableCount(token) == 0) {
      if (merged.isEmpty) {
        pendingLeading.write(token);
      } else {
        merged[merged.length - 1] = merged.last + token;
      }
      continue;
    }

    if (pendingLeading.isNotEmpty) {
      merged.add(pendingLeading.toString() + token);
      pendingLeading.clear();
    } else {
      merged.add(token);
    }
  }

  if (pendingLeading.isNotEmpty) {
    if (merged.isEmpty) {
      merged.add(pendingLeading.toString());
    } else {
      merged[merged.length - 1] = merged.last + pendingLeading.toString();
    }
  }

  return merged;
}

/// Tokens like `"Hello "` / `"world!"` so spacing is preserved in Text.rich.
List<String> _wordTokensWithTrailingSpace(String text) {
  if (text.isEmpty) return const [];
  final matches = RegExp(r'\S+\s*').allMatches(text).toList();
  if (matches.isEmpty) return [text];

  final tokens = <String>[];
  final firstStart = matches.first.start;
  if (firstStart > 0) {
    tokens.add(text.substring(0, firstStart) + matches.first.group(0)!);
    for (var i = 1; i < matches.length; i++) {
      tokens.add(matches[i].group(0)!);
    }
  } else {
    for (final m in matches) {
      tokens.add(m.group(0)!);
    }
  }
  return tokens;
}
