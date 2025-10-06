# Customer Profile API Implementation

## ✅ **What I've Implemented**

I have successfully implemented the customer profile API integration to fetch the customer profile from `/api/customer/profile` endpoint.

### **API Endpoint Details:**
- **URL**: `https://onecharge.io/api/customer/profile`
- **Method**: `GET`
- **Authentication**: Required (Bearer token)
- **Response Format**: 
```json
{
    "success": true,
    "message": "Profile retrieved successfully",
    "data": {
        "customer": {
            "id": 28,
            "name": "Ajay",
            "email": "ajayps8590@gmail.com",
            "phone": "8590713747",
            "company_name": null,
            "notes": null,
            "status": true,
            "profile_image_url": "https://onecharge.io/storage/customer-profiles/HqxywWo0JMVby05jiXrJqgblahT5OHjBCHvp8EQZ.jpg",
            "email_verified_at": null,
            "created_at": "2025-10-05T14:50:05.000000Z",
            "updated_at": "2025-10-06T07:17:06.000000Z"
        }
    }
}
```

## 🔧 **Technical Implementation**

### **1. AuthBloc Events Added:**
```dart
class FetchProfileEvent extends AuthEvent {}
```

### **2. AuthBloc States Added:**
```dart
class ProfileLoading extends AuthState {}
```

### **3. API Integration in AuthBloc:**
```dart
Future<void> _onFetchProfile(FetchProfileEvent event, Emitter<AuthState> emit) async {
  emit(ProfileLoading());
  
  try {
    final token = await StorageHelper.getString('auth_token');
    if (token == null) {
      emit(AuthError(message: 'Authentication required'));
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/customer/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 && responseBody['success'] == true) {
      final customerData = responseBody['data']['customer'];
      final customer = Customer(
        id: customerData['id'],
        name: customerData['name'],
        email: customerData['email'],
        phone: customerData['phone'],
        companyName: customerData['company_name'],
        status: customerData['status'],
        createdAt: customerData['created_at'],
        profileImageUrl: customerData['profile_image_url'],
      );
      
      // Update stored user data
      await StorageHelper.setString('user_data', jsonEncode(customerData));
      
      emit(AuthSuccess(customer: customer, token: token));
    } else {
      emit(AuthError(
        message: responseBody['message'] ?? 'Failed to fetch profile',
      ));
    }
  } catch (e) {
    emit(AuthError(message: 'Network error. Please check your connection.'));
  }
}
```

### **4. MyProfilePage Integration:**
```dart
@override
Widget build(BuildContext context) {
  // Fetch profile when the page loads
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<AuthBloc>().add(FetchProfileEvent());
  });
  
  return BlocListener<AuthBloc, AuthState>(
    // ... rest of the implementation
  );
}
```

## 🎨 **UI Enhancements**

### **Loading States Added:**
1. **Profile Image Loading**: Shows circular progress indicator while fetching
2. **Email Loading**: Shows "Loading..." text while fetching
3. **Phone Loading**: Shows "Loading..." text while fetching
4. **Camera Icon**: Hidden during loading to prevent interaction

### **User Experience:**
- ✅ **Automatic Profile Fetch**: Profile loads automatically when page opens
- ✅ **Loading Indicators**: Clear visual feedback during API calls
- ✅ **Error Handling**: Proper error messages for failed requests
- ✅ **Data Persistence**: Profile data is stored locally after successful fetch
- ✅ **State Management**: Uses BLoC pattern for clean state management

## 📱 **How It Works**

### **1. Page Load:**
1. User navigates to My Profile page
2. `FetchProfileEvent` is automatically triggered
3. `ProfileLoading` state is emitted
4. UI shows loading indicators

### **2. API Call:**
1. AuthBloc makes GET request to `/api/customer/profile`
2. Includes Bearer token in Authorization header
3. Parses JSON response
4. Creates Customer object from response data

### **3. Success Response:**
1. `AuthSuccess` state is emitted with customer data
2. UI updates to show actual profile information
3. Profile data is stored locally for future use
4. Loading indicators are removed

### **4. Error Handling:**
1. Network errors show "Network error" message
2. Authentication errors show "Authentication required"
3. API errors show server-provided error message
4. All errors are displayed as red snackbars

## 🔐 **Security Features**

- ✅ **Token Authentication**: Uses stored Bearer token
- ✅ **Secure Headers**: Includes proper Accept headers
- ✅ **Error Handling**: Graceful handling of authentication failures
- ✅ **Data Validation**: Validates API response before processing

## 🚀 **Usage**

### **To Fetch Profile Programmatically:**
```dart
// Trigger profile fetch
context.read<AuthBloc>().add(FetchProfileEvent());
```

### **To Listen for Profile States:**
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is ProfileLoading) {
      // Show loading indicator
    } else if (state is AuthSuccess) {
      // Profile loaded successfully
      final customer = state.customer;
      // Use customer data
    } else if (state is AuthError) {
      // Handle error
    }
  },
  child: YourWidget(),
)
```

## 📋 **Summary**

The customer profile API integration is now complete with:

- ✅ **API Integration**: Full implementation of `/api/customer/profile` endpoint
- ✅ **State Management**: Proper BLoC pattern implementation
- ✅ **Loading States**: Visual feedback during API calls
- ✅ **Error Handling**: Comprehensive error management
- ✅ **Data Persistence**: Local storage of profile data
- ✅ **User Experience**: Smooth loading and error states
- ✅ **Security**: Token-based authentication
- ✅ **UI Updates**: Real-time UI updates based on API response

The profile page now automatically fetches and displays the latest customer profile data from the server!
