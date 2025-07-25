# Shopping Cart Feature

This directory contains the Shopping Cart feature implementation for the Poortak app.

## Structure

```
feature_shopping_cart/
├── data/
│   ├── data_source/
│   │   └── cart_api_provider.dart
│   └── models/
│       ├── CartType.model.dart
│       ├── get_cart_model.dart
│       ├── local_cart_item.dart
│       └── shopping_cart_model.dart
├── presentation/
│   └── bloc/
│       ├── shopping_cart_bloc.dart
│       ├── shopping_cart_event.dart
│       └── shopping_cart_state.dart
├── repositories/
│   └── shopping_cart_repository.dart
├── screens/
│   └── shopping_cart_screen.dart
└── widgets/
```

## Bloc Implementation

### ShoppingCartBloc

The main bloc that handles all shopping cart-related operations:

- Getting cart items
- Adding items to cart
- Removing items from cart
- Updating item quantities
- Clearing the entire cart
- **Local cart management for non-logged-in users**
- **Syncing local cart to backend after login**

### Events

- `GetCartEvent`: Fetches the current cart items
- `AddToCartEvent`: Adds a new item to the cart
- `RemoveFromCartEvent`: Removes an item from the cart by title
- `UpdateQuantityEvent`: Updates the quantity of a specific item
- `ClearCartEvent`: Clears all items from the cart
- `AddToLocalCartEvent`: Adds item to local cart (for non-logged-in users)
- `AddToBackendCartEvent`: Adds item to backend cart via API (for logged-in users)
- `GetLocalCartEvent`: Gets local cart items
- `RemoveFromLocalCartEvent`: Removes item from local cart
- `ClearLocalCartEvent`: Clears local cart
- `SyncLocalCartToBackendEvent`: Syncs local cart to backend after login

### States

- `ShoppingCartInitial`: Initial state
- `ShoppingCartLoading`: Loading state
- `ShoppingCartLoaded`: Cart loaded successfully with items
- `ShoppingCartError`: Error state with message
- `LocalCartLoaded`: Local cart items loaded
- `LocalCartItemAdded`: Item added to local cart
- `LocalCartItemRemoved`: Item removed from local cart
- `LocalCartCleared`: Local cart cleared
- `LocalCartSyncSuccess`: Local cart synced to backend successfully
- `LocalCartSyncError`: Error syncing local cart to backend

## Data Models

### ShoppingCartItem

Represents a single item in the shopping cart:

```dart
class ShoppingCartItem {
  final String title;
  final String description;
  final String image;
  final bool isLock;
  final int price;
}
```

### LocalCartItem

Represents a single item in the local cart (for non-logged-in users):

```dart
class LocalCartItem {
  final CartType type;
  final String itemId;
  final DateTime addedAt;
}
```

### ShoppingCart

Represents the entire shopping cart:

```dart
class ShoppingCart {
  List<ShoppingCartItem> items;

  void addItem(ShoppingCartItem item);
  void removeItem(String title);
  void updateQuantity(String title, int quantity);
}
```

## Smart Cart Management

The cart feature intelligently handles both logged-in and non-logged-in users:

### Get Cart Functionality

- **For logged-in users**: Fetches cart items from backend API
- **For non-logged-in users**: Shows items from local cart storage

```dart
// This automatically fetches from backend for logged-in users, local storage for non-logged-in users
context.read<ShoppingCartBloc>().add(GetCartEvent());
```

### Add to Cart Functionality

- **For logged-in users**: Adds items directly to backend via API
- **For non-logged-in users**: Adds items to local storage

```dart
// This automatically uses online cart for logged-in users, local cart for non-logged-in users
context.read<ShoppingCartBloc>().addCourseToCart('course-id-123');
```

## Local Cart Functionality

### For Non-Logged-In Users

The cart feature supports local storage for non-logged-in users:

- **Single Course**: Type `iknowCourse` with the course ID
- **All Courses**: Type `iknow` with ID `2c17c9d6-c5a1-43c3-851a-cedbfc6b0c6e`

### For Logged-In Users

Logged-in users automatically use the online cart (backend):

- **Single Course**: Type `iknowCourse` with the course ID (sent to server)
- **All Courses**: Type `iknow` with ID `2c17c9d6-c5a1-43c3-851a-cedbfc6b0c6e` (sent to server)

### Usage Examples

```dart
// Get cart items (automatically uses backend for logged-in, local for non-logged-in)
context.read<ShoppingCartBloc>().add(GetCartEvent());

// Add single course to cart (automatically uses online for logged-in, local for non-logged-in)
context.read<ShoppingCartBloc>().addCourseToCart('course-id-123');

// Add all courses to cart (automatically uses online for logged-in, local for non-logged-in)
context.read<ShoppingCartBloc>().addCourseToCart('any-id', isAllCourses: true);

// Sync local cart after login
context.read<ShoppingCartBloc>().syncLocalCartAfterLogin();
```

### Local Cart Operations

```dart
// Add to local cart
context.read<ShoppingCartBloc>().add(AddToLocalCartEvent(CartType.iknowCourse, 'course-id'));

// Get local cart items
context.read<ShoppingCartBloc>().add(GetLocalCartEvent());

// Remove from local cart
context.read<ShoppingCartBloc>().add(RemoveFromLocalCartEvent(CartType.iknowCourse, 'course-id'));

// Clear local cart
context.read<ShoppingCartBloc>().add(ClearLocalCartEvent());

// Sync to backend after login
context.read<ShoppingCartBloc>().add(SyncLocalCartToBackendEvent());
```

## API Integration

The CartApiProvider handles the following endpoints:

- `GET /cart`: Get current cart items
- `POST /cart`: Add item to cart
- `DELETE /cart`: Clear entire cart
- `POST /cart/checkout`: Checkout cart
- `DELETE /cart/{itemId}`: Remove specific item from cart

### Authentication

All cart operations require authentication:

- Uses Bearer token from PrefsOperator
- Handles 401/404 responses by clearing token and throwing UnauthorisedException
- Handles 409 conflicts for duplicate items

### Local Cart Sync

After user login, local cart items are automatically synced to the backend:

- Each local item is sent to the backend via API
- Local cart is cleared after successful sync
- Failed sync attempts keep local items for retry

## Repository Pattern

The ShoppingCartRepository provides a clean abstraction layer:

```dart
class ShoppingCartRepository {
  // Local cart methods
  Future<void> addToLocalCart(CartType type, String itemId);
  Future<List<LocalCartItem>> getLocalCartItems();
  Future<void> removeFromLocalCart(CartType type, String itemId);
  Future<void> clearLocalCart();
  Future<void> syncLocalCartToBackend();

  // Backend cart methods
  Future<ShoppingCart> getCart();
  Future<ShoppingCart> addToCart(ShoppingCartItem item);
  Future<ShoppingCart> removeFromCart(String title);
  Future<ShoppingCart> updateQuantity(String title, int quantity);
  Future<ShoppingCart> clearCart();
}
```

## Usage Example

### Basic Cart Operations

```dart
// Get cart items
context.read<ShoppingCartBloc>().add(GetCartEvent());

// Add item to cart
context.read<ShoppingCartBloc>().add(AddToCartEvent(item));

// Remove item from cart
context.read<ShoppingCartBloc>().add(RemoveFromCartEvent('Item Title'));

// Update quantity
context.read<ShoppingCartBloc>().add(UpdateQuantityEvent('Item Title', 3));

// Clear cart
context.read<ShoppingCartBloc>().add(ClearCartEvent());
```

### UI Integration

```dart
BlocListener<ShoppingCartBloc, ShoppingCartState>(
  listener: (context, state) {
    if (state is ShoppingCartLoaded) {
      // Update UI with cart items
    } else if (state is LocalCartItemAdded) {
      // Show success message for local cart
    } else if (state is LocalCartSyncSuccess) {
      // Show sync success message
    } else if (state is ShoppingCartError) {
      // Show error message
    }
  },
  child: BlocBuilder<ShoppingCartBloc, ShoppingCartState>(
    builder: (context, state) {
      if (state is ShoppingCartLoading) {
        return CircularProgressIndicator();
      } else if (state is ShoppingCartLoaded) {
        return CartItemsList(items: state.cart.items);
      } else if (state is LocalCartLoaded) {
        return LocalCartItemsList(items: state.items);
      } else if (state is ShoppingCartError) {
        return ErrorWidget(message: state.message);
      }
      return Container();
    },
  ),
)
```

## Cart Types

The feature supports different cart item types defined in `CartType.model.dart`:

- `IKnow`: Original IKnow type
- `IKnowBook`: IKnow book type
- `IKnowCourse`: IKnow course type
- `iknowCourse`: Single course type for non-logged-in users
- `iknow`: All courses type for non-logged-in users

## Error Handling

The feature implements comprehensive error handling following the same pattern as other repositories:

- **Status Code Checking**: All API calls check for 200/201 status codes
- **AppException Handling**: Proper handling of authentication and network errors
- **User-Friendly Messages**: Persian error messages for better UX
- **Network errors with DioException handling**
- **Authentication errors with automatic token clearing**
- **Conflict handling for duplicate items**
- **Local storage errors**
- **Sync failure handling**

## Dependencies

- `flutter_bloc`: For state management
- `equatable`: For value equality
- `dio`: For HTTP requests
- `get_it`: For dependency injection
- `shared_preferences`: For local cart storage

## Integration Points

The shopping cart feature integrates with:

- **Authentication System**: Uses PrefsOperator for token management
- **Navigation**: Accessible from main navigation
- **Product Catalog**: Items can be added from product listings
- **Checkout Flow**: Connects to payment processing
- **Login Flow**: Automatically syncs local cart after login

## Future Enhancements

Potential improvements for the shopping cart feature:

- Persistent cart storage
- Cart synchronization across devices
- Wishlist functionality
- Cart sharing capabilities
- Advanced quantity controls
- Bulk operations
- Offline cart management
- Cart expiration handling
