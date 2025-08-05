# poortak

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

after added a string for localization we must run this command ## flutter gen-l10n

flutter build apk --release

## Shopping Cart Feature

### Overview

The shopping cart feature provides a dual-mode cart system that supports both local storage (for non-logged-in users) and server-side storage (for logged-in users) with automatic synchronization.

### Architecture

#### Core Components

1. **ShoppingCartBloc** (`lib/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart`)

   - Manages cart state and operations
   - Handles both local and server cart events
   - Provides unified interface for cart operations

2. **ShoppingCartRepository** (`lib/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart`)

   - Handles data operations for cart
   - Manages local cart persistence via PrefsOperator
   - Handles server API calls via ShoppingCartApiProvider
   - Implements cart sync functionality with retry mechanism

3. **ShoppingCartApiProvider** (`lib/featueres/feature_shopping_cart/data/data_source/shopping_cart_api_provider.dart`)

   - Direct API communication for cart operations
   - Handles authentication headers
   - Manages API endpoints for cart CRUD operations

4. **PrefsOperator** (`lib/common/utils/prefs_operator.dart`)
   - Local storage management for cart items
   - Token management for authentication
   - Login status checking

### Features

#### Dual Cart System

- **Local Cart**: For non-logged-in users, stores items locally using SharedPreferences
- **Server Cart**: For logged-in users, stores items on server via API
- **Automatic Sync**: Local cart items are automatically synced to server upon login

#### Cart Operations

- **Add to Cart**: Smart routing based on login status
- **Remove from Cart**: Supports both local and server cart removal
- **Clear Cart**: Clears all items from appropriate cart type
- **Get Cart**: Loads cart data from appropriate source

#### Cart Types

- **IKnowCourse**: Single course items (price: 75,000 Toman)
- **IKnow**: Bundle items (price: 750,000 Toman)

### Implementation Details

#### Login Integration

```dart
// In profile_bloc.dart - triggers cart sync after successful login
Future<void> _syncLocalCartToServerWithDelay() async {
  final localCartItems = await prefsOperator.getLocalCartItems();
  if (localCartItems.isNotEmpty) {
    await Future.delayed(const Duration(seconds: 2));
    final shoppingCartBloc = locator<ShoppingCartBloc>();
    shoppingCartBloc.add(SyncLocalCartToBackendEvent());
  }
}
```

#### Smart Cart Addition (Sayareh Screen)

```dart
void _addItemToCart(BuildContext context, String type, String itemId, String itemName) {
  final isLoggedIn = _prefsOperator.isLoggedIn();

  if (isLoggedIn) {
    // Add to server cart via API
    context.read<ShoppingCartBloc>().add(AddToCartEvent(ShoppingCartItem(...)));
  } else {
    // Add to local cart
    context.read<ShoppingCartBloc>().add(AddToLocalCartEvent(type, itemId));
  }
}
```

#### Cart Sync with Retry Mechanism

```dart
Future<void> syncLocalCartToBackend() async {
  final localCartItems = await prefsOperator.getLocalCartItems();

  for (final item in localCartItems) {
    int retryCount = 0;
    const maxRetries = 3;
    bool syncSuccess = false;

    while (!syncSuccess && retryCount < maxRetries) {
      try {
        await _apiProvider.addToCart(CartType.values.firstWhere((e) => e.name == itemType), itemId);
        syncSuccess = true;
      } on DioException catch (e) {
        retryCount++;
        if (e.response?.statusCode == 401) {
          // Handle authentication errors with exponential backoff
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }
    }
  }
}
```

### API Endpoints

#### Cart Operations

- `GET /api/v1/cart` - Get user's cart
- `POST /api/v1/cart` - Add item to cart
- `DELETE /api/v1/cart/{itemId}` - Remove item from cart
- `DELETE /api/v1/cart` - Clear entire cart

#### Authentication

- All cart operations require valid access token
- Tokens are automatically included in request headers
- Unauthorized requests are handled with retry mechanism

### Data Models

#### GetCartModel

```dart
class GetCartModel {
  bool ok;
  Meta meta;
  Data data;
}

class Cart {
  String id;
  String userId;
  DateTime createdAt;
  DateTime updatedAt;
  List<CartItem>? items; // Optional to handle empty carts
}

class CartItem {
  String id;
  String cartId;
  String itemId;
  String type;
  int quantity;
  String price;
  DateTime createdAt;
  DateTime updatedAt;
  CartItemSource source;
}
```

### Error Handling

#### Authentication Errors

- 401/404 errors trigger retry mechanism
- Exponential backoff (2, 4, 6 seconds)
- Maximum 3 retry attempts per item

#### Network Errors

- DioException handling for network issues
- Graceful fallback to local storage when server unavailable

### Logging

Comprehensive logging throughout the cart system:

```dart
log("🛒 Adding item to cart: $itemName");
log("📤 Adding item to server cart via API");
log("📱 Adding item to local cart");
log("🔄 Retry attempt ${retryCount + 1} for item ${i + 1}...");
```

### Usage Examples

#### Adding Items to Cart

```dart
// Single course
_addItemToCart(context, CartType.IKnowCourse.name, item.id, item.name);

// Bundle
_addItemToCart(context, CartType.IKnow.name, "4a61cc6b-8e3c-46e5-ad3c-5f52d0aff181", "مجموعه کامل سیاره آی نو");
```

#### Loading Cart

```dart
// Automatically loads appropriate cart based on login status
void _loadAppropriateCart(ShoppingCartBloc bloc) async {
  final isLoggedIn = prefsOperator.isLoggedIn();

  if (isLoggedIn) {
    bloc.add(GetCartEvent()); // Load from server
  } else {
    bloc.add(GetLocalCartEvent()); // Load from local storage
  }
}
```

### Dependencies

#### Required Packages

- `flutter_bloc` - State management
- `dio` - HTTP client for API calls
- `shared_preferences` - Local storage
- `get_it` - Dependency injection

#### Registration in locator.dart

```dart
// Shopping cart dependencies
locator.registerLazySingleton(() => ShoppingCartApiProvider(locator()));
locator.registerLazySingleton(() => ShoppingCartRepository(apiProvider: locator()));
locator.registerLazySingleton(() => ShoppingCartBloc(repository: locator()));
```

### Testing

#### Cart Operations

- Test local cart operations when not logged in
- Test server cart operations when logged in
- Test cart sync after login
- Test error handling and retry mechanisms

#### Edge Cases

- Empty cart handling
- Network failure scenarios
- Authentication token expiration
- Concurrent cart operations

### Future Enhancements

1. **Offline Support**: Enhanced offline cart management
2. **Cart Persistence**: Better local cart data structure
3. **Real-time Updates**: WebSocket integration for live cart updates
4. **Analytics**: Cart usage analytics and reporting
5. **Wishlist Integration**: Convert wishlist items to cart

## Profile Feature

### Overview

The profile feature provides comprehensive user authentication and profile management functionality, including OTP-based login, user data persistence, and integration with other app features like cart synchronization.

### Architecture

#### Core Components

1. **ProfileBloc** (`lib/featueres/feature_profile/presentation/bloc/profile_bloc.dart`)

   - Manages user authentication state and operations
   - Handles login, logout, and profile data management
   - Triggers cart synchronization after successful login
   - Provides unified interface for profile operations

2. **ProfileRepository** (`lib/featueres/feature_profile/repositories/profile_repository.dart`)

   - Handles profile data operations
   - Manages API calls for authentication
   - Coordinates with PrefsOperator for local data persistence
   - Implements OTP verification and user data management

3. **ProfileApiProvider** (`lib/featueres/feature_profile/data/data_sorce/profile_api_provider.dart`)

   - Direct API communication for profile operations
   - Handles authentication endpoints
   - Manages OTP request and verification
   - Handles user data retrieval and updates

4. **PrefsOperator** (`lib/common/utils/prefs_operator.dart`)
   - Local storage management for user data
   - Token management (access and refresh tokens)
   - Login status checking and persistence
   - User data caching and retrieval

### Features

#### Authentication System

- **OTP-based Login**: Secure phone number verification
- **Token Management**: Automatic access and refresh token handling
- **Session Persistence**: Maintains login state across app sessions
- **Auto-logout**: Handles token expiration and invalid sessions

#### Profile Management

- **User Data Storage**: Local caching of user information
- **Profile Updates**: Real-time profile data synchronization
- **Login Status Tracking**: Persistent login state management
- **Cart Integration**: Automatic cart sync after login

#### Security Features

- **Token Encryption**: Secure storage of authentication tokens
- **Session Validation**: Automatic token validation and refresh
- **Secure Logout**: Complete session cleanup on logout

### Implementation Details

#### OTP Login Flow

```dart
// Request OTP
Future<void> requestOtp(String phoneNumber) async {
  try {
    final response = await _apiProvider.requestOtp(phoneNumber);
    emit(ProfileOtpRequested());
  } catch (e) {
    emit(ProfileError(e.toString()));
  }
}

// Verify OTP and Login
Future<void> verifyOtpAndLogin(String phoneNumber, String otp) async {
  try {
    final response = await _apiProvider.verifyOtp(phoneNumber, otp);
    await _prefsOperator.saveUserData(response);

    // Trigger cart sync after successful login
    log("🛒 Starting cart sync process...");
    await _syncLocalCartToServerWithDelay();

    emit(ProfileLoginSuccess());
  } catch (e) {
    emit(ProfileError(e.toString()));
  }
}
```

#### Cart Sync Integration

```dart
Future<void> _syncLocalCartToServerWithDelay() async {
  try {
    log("🔍 Checking for local cart items...");
    final localCartItems = await prefsOperator.getLocalCartItems();
    log("📊 Found ${localCartItems.length} local cart items");

    if (localCartItems.isNotEmpty) {
      log("⏳ Waiting 2 seconds for authentication to be properly set up...");
      await Future.delayed(const Duration(seconds: 2));
      log("✅ Authentication delay completed, proceeding with cart sync");

      log("🔄 Starting cart sync to server...");
      final shoppingCartBloc = locator<ShoppingCartBloc>();
      log("🎯 Shopping cart bloc retrieved from locator");
      log("📤 Sending SyncLocalCartToBackendEvent to shopping cart bloc...");
      shoppingCartBloc.add(SyncLocalCartToBackendEvent());
      log("✅ Cart sync event dispatched successfully");
    } else {
      log("📭 No local cart items found - skipping cart sync");
    }
  } catch (e) {
    log("💥 Error during cart sync: $e");
    log("⚠️ Cart sync failed, but login will continue");
  }
}
```

#### Token Management

```dart
// Save user data with tokens
Future<void> saveUserData(LoginWithOtpModel response) async {
  log("💾 Saving user data to local storage...");
  await _prefs.setString('access_token', response.data.accessToken);
  await _prefs.setString('refresh_token', response.data.refreshToken);
  await _prefs.setString('user_id', response.data.user.id);
  await _prefs.setString('user_name', response.data.user.name);
  await _prefs.setString('user_phone', response.data.user.phone);
  log("✅ User data saved successfully");
}

// Check login status
bool isLoggedIn() {
  final accessToken = _prefs.getString('access_token');
  final hasToken = accessToken != null && accessToken.isNotEmpty;
  log("🔍 Checking login status: ${hasToken ? 'Logged in' : 'Not logged in'}");
  return hasToken;
}
```

### API Endpoints

#### Authentication Operations

- `POST /api/v1/auth/request-otp` - Request OTP for phone number
- `POST /api/v1/auth/verify-otp` - Verify OTP and login
- `POST /api/v1/auth/refresh-token` - Refresh access token
- `POST /api/v1/auth/logout` - Logout user

#### User Data Operations

- `GET /api/v1/user/profile` - Get user profile data
- `PUT /api/v1/user/profile` - Update user profile
- `DELETE /api/v1/user/account` - Delete user account

#### Authentication Headers

```dart
// Automatic token inclusion in requests
Map<String, String> _getAuthHeaders() {
  final accessToken = _prefs.getString('access_token');
  return {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
}
```

### Data Models

#### Login Models

```dart
class RequestOtpModel {
  bool ok;
  String message;
  RequestOtpData data;
}

class LoginWithOtpModel {
  bool ok;
  String message;
  LoginData data;
}

class LoginData {
  String accessToken;
  String refreshToken;
  User user;
}

class User {
  String id;
  String name;
  String phone;
  String email;
  DateTime createdAt;
  DateTime updatedAt;
}
```

#### Profile States

```dart
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileOtpRequested extends ProfileState {}
class ProfileLoginSuccess extends ProfileState {}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
```

### Error Handling

#### Authentication Errors

- Invalid phone number format
- OTP expiration handling
- Network connectivity issues
- Server error responses
- Token expiration and refresh

#### Network Errors

- DioException handling for network issues
- Graceful error messages for user feedback
- Retry mechanisms for failed requests

### Logging

Comprehensive logging throughout the profile system:

```dart
log("🔐 Starting OTP request for: $phoneNumber");
log("✅ OTP sent successfully");
log("🔍 Verifying OTP: $otp");
log("🎉 Login successful - user: ${response.data.user.name}");
log("💾 Saving user data to local storage...");
log("🛒 Starting cart sync process...");
log("📤 Sending SyncLocalCartToBackendEvent to shopping cart bloc...");
```

### Usage Examples

#### Login Flow

```dart
// Request OTP
context.read<ProfileBloc>().add(RequestOtpEvent(phoneNumber));

// Verify OTP and Login
context.read<ProfileBloc>().add(VerifyOtpEvent(phoneNumber, otp));

// Check login status
final isLoggedIn = prefsOperator.isLoggedIn();
```

#### Profile Data Access

```dart
// Get user data from local storage
final userName = prefsOperator.getUserName();
final userPhone = prefsOperator.getUserPhone();
final userId = prefsOperator.getUserId();

// Check authentication status
final hasValidToken = prefsOperator.isLoggedIn();
```

#### Logout

```dart
// Clear user data and logout
await prefsOperator.clearUserData();
context.read<ProfileBloc>().add(LogoutEvent());
```

### Dependencies

#### Required Packages

- `flutter_bloc` - State management
- `dio` - HTTP client for API calls
- `shared_preferences` - Local storage
- `get_it` - Dependency injection
- `dart:developer` - Logging functionality

#### Registration in locator.dart

```dart
// Profile dependencies
locator.registerLazySingleton(() => ProfileApiProvider(locator()));
locator.registerLazySingleton(() => ProfileRepository(apiProvider: locator()));
locator.registerLazySingleton(() => ProfileBloc(repository: locator()));
```

### Testing

#### Authentication Flow

- Test OTP request with valid phone numbers
- Test OTP verification with valid/invalid codes
- Test login success and failure scenarios
- Test token refresh mechanism

#### Profile Operations

- Test user data persistence
- Test login status checking
- Test logout functionality
- Test cart sync after login

#### Edge Cases

- Invalid phone number formats
- Expired OTP codes
- Network failure scenarios
- Token expiration handling
- Concurrent login attempts

### Integration Points

#### Cart Synchronization

- Automatic cart sync after successful login
- Local cart items transferred to server
- Seamless user experience across login states

#### Navigation Integration

- Profile screen accessible from main navigation
- Login screen for unauthenticated users
- Profile data display for authenticated users

### Security Considerations

#### Token Security

- Secure storage of access and refresh tokens
- Automatic token refresh before expiration
- Secure logout with token cleanup

#### Data Privacy

- Local storage encryption for sensitive data
- Secure transmission of authentication data
- Proper session management

### Future Enhancements

1. **Biometric Authentication**: Fingerprint/Face ID integration
2. **Social Login**: Google, Apple, Facebook login options
3. **Two-Factor Authentication**: Enhanced security with 2FA
4. **Profile Customization**: User avatar and profile settings
5. **Account Recovery**: Password reset and account recovery
6. **Session Management**: Multiple device session handling
7. **Analytics Integration**: User behavior tracking
8. **Push Notifications**: Login alerts and security notifications
