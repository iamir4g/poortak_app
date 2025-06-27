# Litner Feature

This directory contains the Litner feature implementation for the Poortak app.

## Structure

```
feature_litner/
├── data/
│   ├── data_source/
│   │   └── litner_api_provider.dart
│   └── models/
│       ├── create_word_model.dart
│       ├── review_words_model.dart
│       └── submit_review_word.dart
├── presentation/
│   └── bloc/
│       ├── litner_bloc.dart
│       ├── litner_event.dart
│       └── litner_state.dart
├── repositories/
│   └── litner_repository.dart
├── screens/
│   └── litner_main_screen.dart
└── widgets/
    └── litner_card.dart
```

## Bloc Implementation

### LitnerBloc

The main bloc that handles all litner-related operations:

- Creating words
- Reviewing words
- Submitting word reviews

### Events

- `CreateWordEvent`: Creates a new word in the litner system
- `ReviewWordsEvent`: Fetches words for review
- `SubmitReviewWordEvent`: Submits a word review (success/failure)

### States

- `LitnerInitial`: Initial state
- `LitnerLoading`: Loading state
- `CreateWordSuccess`: Word created successfully
- `ReviewWordsSuccess`: Words fetched successfully
- `SubmitReviewWordSuccess`: Review submitted successfully
- `LitnerError`: Error state with message

## Integration with Vocabulary Screen

The LitnerBloc is integrated with the vocabulary screen in the following way:

1. **Global Registration**: The LitnerBloc is registered as a singleton in the locator and provided globally in main.dart
2. **Vocabulary Screen**: The vocabulary screen uses MultiBlocProvider to provide both VocabularyBloc and LitnerBloc
3. **Add to Litner**: When the user clicks the "Add to Litner" button, it dispatches a CreateWordEvent
4. **UI Feedback**: The screen shows loading state and success/error messages using BlocListener

### Usage in Vocabulary Screen

```dart
// Add word to litner
void _addToLitner(String word, String translation) {
  context.read<LitnerBloc>().add(CreateWordEvent(
    word: word,
    translation: translation,
  ));
}

// Listen for state changes
BlocListener<LitnerBloc, LitnerState>(
  listener: (context, state) {
    if (state is CreateWordSuccess) {
      // Show success message
    } else if (state is LitnerError) {
      // Show error message
    }
  },
  child: // ... rest of the UI
)
```

## API Endpoints

The LitnerApiProvider handles the following endpoints:

- `POST /leitner/create`: Create a new word
- `GET /leitner/review`: Get words for review
- `PATCH /leitner/review/{wordId}`: Submit a word review

## Dependencies

- `flutter_bloc`: For state management
- `equatable`: For value equality
- `dio`: For HTTP requests
- `get_it`: For dependency injection
