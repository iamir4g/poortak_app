# Dictionary API Integration

This document describes how the Dictionary feature is implemented using the Free Dictionary API.

## API Source
- **YAML Specification**: `/Users/macbookpro/Downloads/free-dictionary-api.yaml`
- **Base URL**: `https://freedictionaryapi.com/api/v1`
- **Endpoint Used**: `/entries/en/{word}`

## Implementation Details

### Architecture
The feature is implemented using the BLoC pattern with clean architecture principles:
- **Data Layer**: 
  - `DictionaryModel`: Parses the JSON response to extract the word and its Persian translations.
  - `DictionaryRepository`: Handles API calls using `Dio`.
- **Presentation Layer**:
  - `DictionaryBloc`: Manages the state (Initial, Loading, Loaded, Error, Empty).
  - `DictionaryBottomSheet`: The UI widget displaying the search box and results.

### Features
- **Search**: Users can search for English words.
- **Debounce**: Search requests are debounced by 500ms to minimize API calls.
- **Persian Translation**: The app filters the API response to show only Persian (`fa`) translations.
- **UI**: A bottom sheet with a search bar and a list of results (English word on left, Persian on right).

### Usage

1. Open the Lesson Screen.
2. Click on the Dictionary button (floating action button or icon).
3. The bottom sheet opens.
4. Type an English word in the search box.
5. View the Persian translations in the list.

### Code Structure

- **Model**: `lib/featueres/fetures_sayareh/data/models/dictionary_model.dart`
- **Repository**: `lib/featueres/fetures_sayareh/data/repositories/dictionary_repository.dart`
- **Bloc**: `lib/featueres/fetures_sayareh/presentation/bloc/dictionary_bloc/`
- **Widget**: `lib/featueres/fetures_sayareh/widgets/dictionary_bottom_sheet.dart`

### Dependencies
- `dio`: For HTTP requests.
- `flutter_bloc`: For state management.
- `equatable`: For value equality in Bloc states/events.
