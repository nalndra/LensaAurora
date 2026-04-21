# Login & Register Implementation - Lensa Aurora

## 📋 Overview
Implementasi lengkap sistem login dan register dengan Firebase Authentication dan Firestore integration menggunakan GetX architecture pattern.

---

## 🏗️ Arsitektur Proyek

### Struktur Folder
```
lib/app/
├── services/
│   └── auth_service.dart          # Service untuk Firebase Auth & Firestore
├── controllers/
│   └── auth_controller.dart        # Controller untuk logic login/register (GetX)
├── modules/
│   ├── login/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   └── views/login_view.dart
│   ├── register/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   └── views/register_view.dart
│   └── splash/
│       ├── bindings/
│       ├── controllers/
│       └── views/splash_view.dart
└── routes/
    ├── app_pages.dart
    └── app_routes.dart
```

---

## 🔑 Core Components

### 1. **AuthService** (`lib/app/services/auth_service.dart`)
Service untuk menangani semua operasi Firebase.

**Key Methods:**
```dart
// Register
Future<User?> register({
  required String email,
  required String password,
  required String name,
})

// Login
Future<User?> login({
  required String email,
  required String password,
})

// Check if email exists
Future<bool> emailExists(String email)

// Logout
Future<void> logout()

// Password reset
Future<void> sendPasswordResetEmail(String email)

// Get user data from Firestore
Future<DocumentSnapshot> getUserData(String uid)

// Update profile
Future<void> updateUserProfile({
  String? name,
  String? photoUrl,
})
```

**Fitur:**
- ✅ Firebase Auth integration
- ✅ Firestore user document creation
- ✅ Email validation
- ✅ Auto login history tracking
- ✅ Session management

---

### 2. **AuthController** (`lib/app/controllers/auth_controller.dart`)
GetX controller untuk business logic login/register.

**State Management:**
```dart
var isLoading = false.obs;
var isPasswordVisible = false.obs;
var isConfirmPasswordVisible = false.obs;
var currentUser = Rxn<User>();
```

**Validations:**
```dart
String? validateEmail(String? value)       // Format valid
String? validatePassword(String? value)    // Min 6 char
String? validateName(String? value)        // Min 3 char
String? validatePasswordMatch(String? value) // Harus sama
```

**Key Methods:**
```dart
Future<bool> login()              // Login logic
Future<bool> register()           // Register logic
Future<void> logout()             // Logout
Future<void> sendPasswordResetEmail(String email)
void checkLoginStatus()           // Auto login logic
```

**Error Handling:**
```dart
case 'user-not-found':
  message = 'User tidak ditemukan';
case 'wrong-password':
  message = 'Password salah';
case 'email-already-in-use':
  message = 'Email sudah terdaftar';
case 'weak-password':
  message = 'Password terlalu lemah';
// ... dan error lainnya
```

---

### 3. **Login View** (`lib/app/modules/login/views/login_view.dart`)

**Features:**
- ✅ Form validation
- ✅ Password visibility toggle
- ✅ Loading state
- ✅ Error snackbars
- ✅ Link to register
- ✅ Forgot password link
- ✅ Clean UI dengan MaterialDesign

**Form Fields:**
- Email (dengan validator)
- Password (dengan visibility toggle)

---

### 4. **Register View** (`lib/app/modules/register/views/register_view.dart`)

**Features:**
- ✅ Form validation semua field
- ✅ Password & Confirm Password
- ✅ Real-time password match validation
- ✅ Loading state
- ✅ Error handling
- ✅ Link back to login

**Form Fields:**
- Nama Lengkap
- Email
- Password
- Confirm Password

---

### 5. **Splash Screen** (`lib/app/modules/splash/views/splash_view.dart`)

**Features:**
- ✅ Session checking on startup
- ✅ Auto redirect ke login/home
- ✅ Loading animation
- ✅ 2 detik delay untuk user experience

**Flow:**
1. App starts → Splash screen
2. Check if user logged in
3. If logged in → Redirect to `/home`
4. If not logged in → Redirect to `/login`

---

## 🔐 Validasi

### Email Validation
```dart
if (!GetUtils.isEmail(email)) {
  Get.snackbar("Error", "Email tidak valid");
  return;
}
```

### Password Validation
- Minimal 6 karakter
- Harus non-empty
- Untuk register: harus match dengan confirm password

### Name Validation
- Minimal 3 karakter
- Tidak boleh kosong

---

## 🚀 Error Handling

### Firebase Auth Exception Mapping
```dart
switch (e.code) {
  case 'user-not-found':
    // User tidak ditemukan
  case 'wrong-password':
    // Password salah
  case 'email-already-in-use':
    // Email sudah terdaftar
  case 'weak-password':
    // Password terlalu lemah
  case 'invalid-email':
    // Email format salah
  case 'too-many-requests':
    // Terlalu banyak percobaan
  case 'network-request-failed':
    // Gagal terhubung
}
```

### User-Friendly Messages
Semua error ditampilkan dalam Bahasa Indonesia via snackbar.

---

## 📦 Firestore Integration

### User Document Structure
```json
{
  "uid": "user_id_firebase",
  "email": "user@email.com",
  "name": "Nama Lengkap",
  "photoUrl": "",
  "isActive": true,
  "createdAt": Timestamp(2026-04-21),
  "updatedAt": Timestamp(2026-04-21),
  "lastLogin": Timestamp(2026-04-21)
}
```

### Saat Register
1. Create user di Firebase Auth
2. Update display name
3. Create document di Firestore `/users/{uid}`

### Saat Login
1. Sign in dengan email & password
2. Update `lastLogin` timestamp di Firestore

---

## 🔄 Session Management

### Auto Login Check
```dart
void checkLoginStatus() {
  if (authService.isLoggedIn) {
    Get.offAllNamed('/home');
  } else {
    Get.offAllNamed('/login');
  }
}
```

### Route Flow
```
/splash (check session)
    ↓
    ├── Logged in → /home
    └── Not logged in → /login
```

---

## 📱 Menggunakan AuthController di View

```dart
class MyView extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Form fields
          TextFormField(
            controller: controller.loginEmailController,
            validator: controller.validateEmail,
          ),
          
          // Loading state
          Obx(() => 
            controller.isLoading.value 
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () => controller.login(),
                  child: Text('Login'),
                )
          ),
        ],
      ),
    );
  }
}
```

---

## 🔌 Setup Routes

Routes sudah dikonfigurasi di:
- `lib/app/routes/app_pages.dart`
- `lib/app/routes/app_routes.dart`

**Available Routes:**
- `/splash` - Splash screen (INITIAL)
- `/login` - Login page
- `/register` - Register page
- `/home` - Home page (after login)

---

## 📋 Checklist Implementation

- ✅ Firebase Authentication setup
- ✅ Firestore user collection
- ✅ AuthService dengan semua methods
- ✅ AuthController dengan GetX
- ✅ Login view dengan form validation
- ✅ Register view dengan confirm password
- ✅ Splash screen untuk session check
- ✅ Error handling mapping
- ✅ Password visibility toggle
- ✅ Auto login/logout
- ✅ Email verification methods
- ✅ Password reset email

---

## 🚦 Testing Flows

### Flow 1: Login dengan Valid Email/Password
1. Masuk ke login page
2. Isi email & password valid
3. Click "Masuk"
4. Sukses → Redirect ke home
5. Check Firestore: `lastLogin` updated

### Flow 2: Register Akun Baru
1. Masuk ke register page
2. Isi nama, email, password
3. Isi confirm password (sama)
4. Click "Daftar"
5. Sukses → Redirect ke login
6. Check Firestore: user document created

### Flow 3: Register dengan Email Sudah Ada
1. Register dengan email yang sudah terdaftar
2. Error: "Email sudah terdaftar"

### Flow 4: Login dengan Password Salah
1. Login dengan email valid + password salah
2. Error: "Password salah"

### Flow 5: Session Check (Auto Login)
1. App restart saat user sudah login
2. Splash → Check session
3. Redirect ke home (tidak perlu login ulang)

---

## 🛠️ Next Steps (Optional)

### Untuk Enhance:
1. **Email Verification**: Verify email saat register
2. **Social Login**: Google/Apple sign in
3. **Two Factor Auth**: 2FA setup
4. **Profile Picture**: Upload foto ke Storage
5. **Phone Number Verification**: OTP verification
6. **User Preferences**: Dark mode, language selection
7. **Activity Logging**: Track user activities
8. **Session Timeout**: Auto logout setelah idle

---

## 📚 Dependencies

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.14.0
  get: ^4.7.3
  flutter:
    sdk: flutter
```

---

## 🎯 Key Features Summary

| Feature | Status | Details |
|---------|--------|---------|
| Email Validation | ✅ | Format check + exists check |
| Password Validation | ✅ | Min 6 chars, match check |
| Firebase Auth | ✅ | Email/password auth |
| Firestore Integration | ✅ | User data persistence |
| Error Handling | ✅ | Mapped error messages |
| Session Management | ✅ | Auto login/logout |
| Loading States | ✅ | Progress indicator |
| UI/UX | ✅ | Material design |
| Password Toggle | ✅ | Visibility icon |

---

Created on: April 21, 2026
Updated: Today
Version: 1.0.0
