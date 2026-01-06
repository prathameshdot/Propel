# Propel App - Complete Documentation

## 📱 App Overview
**App Name:** Propel  
**Platform:** Flutter (Cross-platform)  
**Primary Purpose:** Multi-level marketing (MLM) platform with package activation, referrals, and income tracking

---

## 🔐 Authentication Flow

### User Journey
1. **Splash Screen** → Checks login status
2. **First Time Users:** Splash → Login → Create Account
3. **Returning Users:** Splash → Login → Check Referral Code → Dashboard/Account Inactive
4. **Complete Flow:** Register (with optional referral code) → Login → Check Referral Code → Dashboard OR Account Inactive → Activate Package → Dashboard

### Login Logic (login_page.dart)
```dart
Login → Check Referral Code (KYC not checked):
  - Has referral code → Navigate to Dashboard (Active Account)
  - No referral code → Navigate to Account Inactive Page
```

### Registration Logic (create_account_page.dart)
```dart
Register:
  - If referral code provided → Create referral entry in system
  - Referral will appear in referrer's "Refer & Earn" list
  - Navigate to Login
```

---

## 🌐 API Integration Status

### ✅ FULLY INTEGRATED APIs

#### 1. Authentication APIs
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `POST /admin/user/register` | ✅ Integrated | User registration | `RegisterRequest`, `RegisterResponse` |
| `POST /admin/user/login` | ✅ Integrated | User login | `LoginRequest`, `LoginResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Methods: `ApiRepository.register()`, `ApiRepository.login()`
- Used in: `create_account_page.dart`, `login_page.dart`

---

#### 2. Packages API
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `GET /api/v1/packages-list` | ✅ Integrated | Fetch available packages | `PackagesListResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Method: `ApiRepository.getPackagesList()`
- Used in: `activation_packages_page.dart`, `package_activation_page.dart`
- Displays: Package ID, Name, Price, Description, Features

---

#### 3. Payment API
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `POST /api/v1/payments` | ✅ Integrated | Create payment record | `CreatePaymentRequest`, `CreatePaymentResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Method: `ApiRepository.createPayment()`
- Used in: `package_activation_page.dart`
- Payload:
  ```json
  {
    "user_id": 123,
    "package_id": 3,
    "amount": 2000.0,
    "payment_method": "UPI/Bank Transfer",
    "reference_id": "REF123456",
    "status": "completed"
  }
  ```

---

#### 4. Referral Code API
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `GET /api/v1/referral/code?user_id={userId}` | ✅ Integrated | Get user's referral code | `ReferralCodeResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Method: `ApiRepository.getReferralCode(userId)`
- Used in: 
  - `refer_and_earn_page.dart` - Generate referral link
  - `profile_kyc_page.dart` - Check account activation status
- Returns: `referral_code` (e.g., "H63FT5NO")
- **Link Format:** `https://propel.hoomaservice.com/?refcode=H63FT5NO` ✅ FIXED

---

#### 5. Dashboard API
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `GET /api/v1/user-get/dashboard/{userId}` | ✅ Integrated | Fetch user dashboard data | `DashboardResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Method: `ApiRepository.getDashboard(userId)`
- Used in: `dashboard_page.dart`
- Returns:
  - `wallet_balance`
  - `direct_income`
  - `matching_income`
  - `left_team_count`, `right_team_count`
  - `left_team_business`, `right_team_business`
  - `left_team[]`, `right_team[]`

---

#### 6. Referrals List API
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `GET /api/v1/referral/list?user_id={userId}&referral_code={code}` | ✅ Integrated | Fetch user's referrals | `ReferralsListResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Method: `ApiRepository.getReferralsList()`
- Used in: `refer_and_earn_page.dart`
- Returns: List of referrals with first_name, last_name, created_at

---

#### 7. Create Referral API
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `POST /api/v1/referral/store` | ✅ Integrated | Create new referral | `CreateReferralRequest`, `CreateReferralResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Method: `ApiRepository.createReferral()`
- Used in: `refer_and_earn_page.dart` (REMOVED from UI as per user request)
- Payload:
  ```json
  {
    "referral_code": "H63FT5NO",
    "first_name": "John",
    "last_name": "Doe"
  }
  ```

---

#### 8. KYC APIs
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `POST /api/user-kyc/kyc/submit` | ✅ Integrated | Submit KYC documents | `SubmitKycResponse` |
| `GET /api/user/kyc/get?user_id={userId}` | ✅ Integrated | Get KYC status | `GetKycResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Methods: `ApiRepository.submitKyc()`, `ApiRepository.getKyc()`
- Used in: 
  - `complete_kyc_page.dart` - Submit KYC with PAN, Aadhar images
  - `app_drawer.dart` - Check KYC status for conditional menu
  - `profile_kyc_page.dart` - Display KYC verification status
- Submit Payload (multipart/form-data):
  ```
  user_id: 123
  pan_card: (file)
  aadhar_front: (file)
  aadhar_back: (file)
  ```
- Returns: `kyc_verified` (0 = Pending, 1 = Verified)

---

#### 9. Master Image Upload API
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `POST /api/user/master-image/upload` | ✅ Integrated | Upload proof of payment | `UploadMasterImageResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Method: `ApiRepository.uploadMasterImage()`
- Used in: `package_activation_page.dart`
- Payload: Single image file (multipart/form-data)

---

#### 10. MLM APIs
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `POST /api/mlm/check-position` | ✅ Integrated | Check if a position is available (referral join) | `MlmCheckPositionResponse` |
| `GET /api/mlm/tree/{userId}` | ✅ Integrated | Get user tree/downline recursively | `MlmTreeResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Methods: `ApiRepository.checkPosition()`, `ApiRepository.getMlmTree()`
- Used in: `my_team_page.dart`, `refer_and_earn_page.dart` (integration pending in UI)
- Notes: Supports `usedmyrefrencecode` query param with values `yes|no|all` (default `all`).

---

#### 11. Rewards API
| Endpoint | Status | Usage | Model |
|----------|--------|-------|-------|
| `GET /api/rewards` | ✅ Integrated | Get list of active rewards | `RewardsResponse` |

**Implementation:**
- Location: `lib/services/api_repository.dart`
- Method: `ApiRepository.getRewards()`
- Used in: `refer_and_earn_page.dart` (UI integration pending)

---

### ⚠️ PARTIALLY INTEGRATED / NOT IN USE

#### 10. Withdraw API
| Endpoint | Status | Usage |
|----------|--------|-------|
| `POST /api/withdraw-request` | ⚠️ UI Only | `withdraw_request_page.dart` has UI but no API call |

**Current Status:** Form exists but submit button doesn't call API  
**Action Required:** Implement API call in submit handler

---

#### 11. Transaction History API
| Endpoint | Status | Usage |
|----------|--------|-------|
| `GET /api/transactions/{userId}` | ⚠️ Static Data | `transaction_history_page.dart` shows static data only |

**Current Status:** UI exists but no API integration  
**Action Required:** Add API endpoint and integrate

---

#### 12. Team/Income Detail APIs
| Endpoint | Status | Usage |
|----------|--------|-------|
| `GET /api/direct-income/{userId}` | ❌ Not Integrated | `direct_referral_income_page.dart` - static data |
| `GET /api/matching-income/{userId}` | ❌ Not Integrated | `matching_income_page.dart` - static data |
| `GET /api/reward-income/{userId}` | ❌ Not Integrated | `reward_income_page.dart` - static data |
| `GET /api/my-team/{userId}` | ❌ Not Integrated | `my_team_page.dart` - static data |

**Current Status:** All income detail pages show static/placeholder data  
**Action Required:** Backend needs to provide these endpoints

---

## 📊 App Flow & Navigation

### Complete User Journey

```
┌─────────────────────┐
│   Splash Screen     │ (Checks login status)
└──────────┬──────────┘
           │
           ├─── Not Logged In ──────────┐
           │                            │
           │                   ┌────────▼─────────┐
           │                   │   Login Page     │
           │                   └────────┬─────────┘
           │                            │
           │                   ┌────────▼──────────────┐
           │                   │  Create Account Page  │
           │                   │  (Optional: Enter     │
           │                   │   Referral Code)      │
           │                   └────────┬──────────────┘
           │                            │
           │◄───────────────────────────┘
           │
           └─── Logged In ──────────────┐
                                        │
                        ┌───────────────▼────────────────┐
                        │  Check Referral Code           │
                        │  (KYC status NOT checked)      │
                        └───────┬────────────────────────┘
                                │
                ┌───────────────┴──────────────────┐
                │                                  │
        ┌───────▼────────────┐          ┌─────────▼──────────┐
        │ No Referral Code   │          │ Has Referral Code  │
        │ Account Inactive   │          │ Account Active     │
        └───────┬────────────┘          └─────────┬──────────┘
                │                                  │
        ┌───────▼──────────────┐                  │
        │ Account Inactive Page│                  │
        │  - "Activate Now"    │                  │
        └───────┬──────────────┘                  │
                │                                  │
        ┌───────▼─────────────────┐               │
        │ Activation Packages Page│               │
        │  - View Packages        │               │
        └───────┬─────────────────┘               │
                │                                  │
        ┌───────▼──────────────────┐              │
        │ Package Activation Page  │              │
        │  - Select Package        │              │
        │  - Upload Payment Proof  │              │
        │  - Create Payment Record │              │
        └───────┬──────────────────┘              │
                │                                  │
                └──────────► Payment Success ─────┤
                                                   │
                            ┌──────────────────────┘
                            │
                    ┌───────▼──────────┐
                    │  Dashboard Page  │
                    │  (Active Account)│
                    └──────────────────┘
```

---

## 🗂️ Screen-by-Screen Breakdown

### 1. Splash Screen (`splash_screen.dart`)
- **Purpose:** Initial loading screen
- **Logic:** 
  - Checks `AuthService.isLoggedIn()`
  - If logged in → Navigate to Dashboard
  - If not → Navigate to Login
- **API Calls:** None
- **Status:** ✅ Complete

---

### 2. Login Page (`login_page.dart`)
- **Purpose:** User authentication
- **API:** `POST /admin/user/login`
- **Logic:**
  ```dart
  Login Success:
    - Save token, userId
    - Check referral code (KYC status ignored)
    - Has referral code → Dashboard
    - No referral code → Account Inactive
  ```
- **Status:** ✅ Complete

---

### 3. Create Account Page (`create_account_page.dart`)
- **Purpose:** User registration
- **API:** 
  1. `POST /admin/user/register` - Register user
  2. `POST /api/v1/referral/store` - Create referral entry (if referral code provided)
- **Fields:** First Name, Last Name, Email, Phone, Password, Referral Code (optional)
- **Logic:**
  - Register user
  - If referral code provided → Create referral entry under that code
  - Referral will appear in the referrer's "Refer & Earn" list
- **Status:** ✅ Complete

---

### 4. Complete KYC Page (`complete_kyc_page.dart`)
- **Purpose:** Submit KYC documents
- **API:** `POST /api/user-kyc/kyc/submit`
- **Fields:**
  - PAN Card Image (required)
  - Aadhar Front Image (required)
  - Aadhar Back Image (required)
- **Image Selection:** Uses `image_picker` package
- **Submit Logic:**
  - Validates all images selected
  - Creates multipart request with user_id + images
  - Logs payload for debugging
  - On success → Check referral code:
    - Has referral code → Navigate to Dashboard (user already activated)
    - No referral code → Navigate to Account Inactive Page
- **Status:** ✅ Complete with smart navigation

---

### 5. Account Inactive Page (`account_inactive_page.dart`)
- **Purpose:** Inform user to activate package
- **API Calls:** None
- **Actions:**
  - "Activate Now" → Navigate to Activation Packages
  - "Share Referral Link" → Static button (no function yet)
- **Status:** ✅ Complete

---

### 6. Activation Packages Page (`activation_packages_page.dart`)
- **Purpose:** Display available packages
- **API:** `GET /api/v1/packages-list`
- **Display:** Grid of package cards with name, price, features
- **Action:** Tap package → Navigate to Package Activation with package data
- **Status:** ✅ Complete

---

### 7. Package Activation Page (`package_activation_page.dart`)
- **Purpose:** Activate selected package with payment
- **APIs:**
  1. `POST /api/user/master-image/upload` - Upload payment proof
  2. `POST /api/v1/payments` - Record payment
- **Flow:**
  1. User selects payment method (UPI/Bank Transfer)
  2. User uploads payment screenshot/proof
  3. System uploads image → gets URL
  4. Creates payment record
  5. On success → Navigate to Dashboard
- **Status:** ✅ Complete

---

### 8. Dashboard Page (`dashboard_page.dart`)
- **Purpose:** Main home screen showing user stats
- **API:** `GET /api/v1/user-get/dashboard/{userId}`
- **Displays:**
  - Wallet Balance
  - Direct Income
  - Matching Income
  - Left Team Count/Business
  - Right Team Count/Business
  - Tree visualization
- **Navigation:** Access to all main features via cards
- **Status:** ✅ Complete

---

### 9. Profile & KYC Page (`profile_kyc_page.dart`)
- **Purpose:** View user profile and account status
- **APIs:**
  1. `GET /api/user/kyc/get?user_id={userId}` - KYC status
  2. `GET /api/v1/referral/code?user_id={userId}` - Account activation status
- **Displays:**
  - User Info (static: name, phone, email, location)
  - **Account Status:** Active (green) if referral code exists, Inactive (orange) if not
  - **KYC Status:** Verified (green) if kyc_verified=1, Pending (orange) if 0
- **Actions:**
  - Upload Documents (placeholder)
  - Log Out
- **Status:** ✅ Complete with dynamic status

---

### 10. Refer & Earn Page (`refer_and_earn_page.dart`)
- **Purpose:** Share referral link and view referrals
- **APIs:**
  1. `GET /api/v1/referral/code?user_id={userId}` - Get referral code
  2. `GET /api/v1/referral/list?user_id={userId}&referral_code={code}` - Get referrals list
- **Displays:**
  - **Referral Link:** `https://propel.hoomaservice.com/?refcode=H63FT5NO` ✅ FIXED
  - Copy & Share buttons
  - List of referrals with name and date
- **Status:** ✅ Complete (Add referral form removed as requested)

---

### 11. Wallet Page (`wallet_page.dart`)
- **Purpose:** View wallet balance and income breakdown
- **API Calls:** None (static data)
- **Displays:**
  - Total Balance
  - Direct Income
  - Matching Income
  - Reward Income
- **Actions:**
  - View Income Details → Navigate to detail pages
  - Withdraw → Navigate to Withdraw Request
  - View Transactions → Navigate to Transaction History
- **Status:** ⚠️ UI Complete, needs API integration for live data

---

### 12. Withdraw Request Page (`withdraw_request_page.dart`)
- **Purpose:** Submit withdrawal request
- **API:** ❌ Not integrated yet
- **UI Elements:**
  - Amount input
  - Bank account details display
  - Submit button (no function yet)
- **Status:** ⚠️ UI Only - needs API endpoint

---

### 13. Transaction History Page (`transaction_history_page.dart`)
- **Purpose:** View all transactions
- **API:** ❌ Not integrated
- **Display:** Static transaction list
- **Status:** ⚠️ UI Only - needs API endpoint

---

### 14. Income Detail Pages
- **direct_referral_income_page.dart**
- **matching_income_page.dart**
- **reward_income_page.dart**
- **Status:** ⚠️ All show static data, need API endpoints

---

### 15. My Team Page (`my_team_page.dart`)
- **Purpose:** View team structure
- **API:** ❌ Not integrated
- **Display:** Static team members
- **Status:** ⚠️ UI Only - needs API endpoint

---

### 16. Support & Static Pages
- `support_page.dart` - Contact info
- `terms_conditions_page.dart` - Terms text
- `rank_system_page.dart` - Rank description
- **Status:** ✅ Complete (static content)

---

## 🎯 App Drawer Menu (`app_drawer.dart`)

### Structure:
```dart
StatefulWidget - Fetches KYC status dynamically
```

### Displayed Menu Items:
1. **Profile & KYC** - Always visible
2. **Complete KYC** - Only if `kyc_verified == 0` (shows orange "Pending" badge)
3. **Packages** - Always visible
4. **Daily Income** - Always visible
5. **Rank System** - Always visible
6. **Support** - Always visible
7. **Terms & Conditions** - Always visible

### Removed Items (as per user request):
- ❌ Wallet
- ❌ Withdraw
- ❌ Transaction History
- ❌ My Team
- ❌ Refer & Earn

**Status:** ✅ Complete with conditional display

---

## 📦 Models & Data Structures

### Authentication Models
- `LoginRequest` - email, password
- `LoginResponse` - status, code, message, data (user, token)
- `RegisterRequest` - firstName, lastName, email, phone, password, referralCode
- `RegisterResponse` - status, code, message, data

### Package Models
- `PackagesListResponse` - status, code, message, data (packages[])
- `Package` - id, name, price, description, features

### Payment Models
- `CreatePaymentRequest` - userId, packageId, amount, paymentMethod, referenceId, status
- `CreatePaymentResponse` - status, code, message, data

### Referral Models
- `ReferralCodeResponse` - status, code, message, data (referralCode)
- `ReferralsListResponse` - status, code, message, data (referrals[])
- `Referral` - id, userId, referralCode, firstName, lastName, createdAt

### Dashboard Models
- `DashboardResponse` - status, code, message, data
- `DashboardData` - walletBalance, directIncome, matchingIncome, leftTeamCount, rightTeamCount, etc.

### KYC Models
- `SubmitKycResponse` - status, message, data
- `GetKycResponse` - status, message, data (kyc_verified: 0 or 1)

### Image Upload Models
- `UploadMasterImageResponse` - status, message, data (imageUrl)

---

## 🔧 Services & Utilities

### 1. AuthService (`services/auth_service.dart`)
**Purpose:** Manage authentication state using SharedPreferences

**Methods:**
- `isLoggedIn` → Get login status
- `setLoggedIn(bool)` → Set login status
- `getToken()` → Get auth token
- `saveToken(String)` → Save auth token
- `clearToken()` → Remove token
- `getUserId()` → Get user ID
- `saveUserId(String)` → Save user ID
- `clearUserId()` → Remove user ID

**Status:** ✅ Complete

---

### 2. ApiService (`services/api_service.dart`)
**Purpose:** Low-level HTTP client

**Methods:**
- `get(endpoint, queryParams)` → GET request
- `post(endpoint, body)` → POST request
- `multipartPost(endpoint, fields, files)` → Multipart POST for file uploads

**Base URL:** Configured via constant (likely in constants file)  
**Status:** ✅ Complete

---

### 3. ApiRepository (`services/api_repository.dart`)
**Purpose:** High-level API interface with typed responses

**All Methods:**
- `login(LoginRequest)` → `LoginResponse?`
- `register(RegisterRequest)` → `RegisterResponse?`
- `getPackagesList()` → `PackagesListResponse?`
- `createPayment(CreatePaymentRequest)` → `CreatePaymentResponse?`
- `getReferralCode(userId)` → `ReferralCodeResponse?`
- `getDashboard(userId)` → `DashboardResponse?`
- `getReferralsList({userId, referralCode})` → `ReferralsListResponse?`
- `createReferral(CreateReferralRequest)` → `CreateReferralResponse?`
- `submitKyc(fields, files)` → `SubmitKycResponse?`
- `getKyc(userId)` → `GetKycResponse?`
- `uploadMasterImage(image)` → `UploadMasterImageResponse?`

**Status:** ✅ Complete

---

### 4. AppRouter (`routes/app_router.dart`)
**Purpose:** Centralized navigation management

**All Routes:**
```dart
static const String splash = '/';
static const String login = '/login';
static const String createAccount = '/create-account';
static const String completeKYC = '/complete-kyc';
static const String accountInactive = '/account-inactive';
static const String activationPackages = '/activation-packages';
static const String packageActivation = '/package-activation';
static const String home = '/home'; // Dashboard
static const String profileKYC = '/profile-kyc';
static const String wallet = '/wallet';
static const String withdrawRequest = '/withdraw-request';
static const String transactionHistory = '/transaction-history';
static const String referAndEarn = '/refer-and-earn';
static const String myTeam = '/my-team';
static const String directIncome = '/direct-income';
static const String matchingIncome = '/matching-income';
static const String rewardIncome = '/reward-income';
static const String support = '/support';
static const String termsConditions = '/terms-conditions';
static const String rankSystem = '/rank-system';
static const String dailyIncome = '/daily-income';
static const String globalTurnover = '/global-turnover';
```

**Status:** ✅ Complete

---

## 📱 UI Components

### Custom Widgets
1. **AppDrawer** (`widgets/app_drawer.dart`)
   - Drawer menu with conditional KYC item
   - Fetches KYC status on init
   - Status: ✅ Complete

2. **BottomNav** (`widgets/bottom_nav.dart`)
   - Bottom navigation bar (if used)
   - Status: Unknown (not analyzed)

### Theme & Colors
- **Primary Brand Color:** `#3979D3` (Blue)
- **Success Color:** Green (#4CAF50)
- **Warning Color:** Orange
- **Error Color:** Red
- **Background:** Light grey (#F5F8FB)

**Defined in:** `utils/colors.dart`

---

## 📋 Pending Tasks & Recommendations

### 🔴 High Priority

1. **Withdraw API Integration**
   - Create endpoint: `POST /api/withdraw-request`
   - Integrate in `withdraw_request_page.dart`
   - Validate bank account info

2. **Transaction History API**
   - Create endpoint: `GET /api/transactions/{userId}`
   - Integrate in `transaction_history_page.dart`
   - Support pagination

3. **Real-time Balance Updates**
   - Implement WebSocket or polling for wallet balance
   - Update dashboard on payment completion

---

### 🟡 Medium Priority

4. **Income Detail APIs**
   - `GET /api/direct-income/{userId}`
   - `GET /api/matching-income/{userId}`
   - `GET /api/reward-income/{userId}`
   - Integrate in respective pages

5. **Team View API**
   - `GET /api/my-team/{userId}`
   - Show real team structure
   - Add search/filter functionality

6. **Notification System**
   - Implement push notifications
   - Show in-app notifications
   - Notification bell in app bar (currently static)

---

### 🟢 Low Priority

7. **Profile Picture Upload**
   - Add upload functionality in profile page
   - Currently shows static `assets/profile.avif`

8. **Bank Account Management**
   - Add/Edit bank account details
   - Currently shows "Not Added" static text

9. **Sharing Functionality**
   - Implement actual share via WhatsApp/Telegram/SMS
   - Currently "Share Link Via..." button does nothing

---

## 🧪 Testing Checklist

### ✅ Completed Tests
- [x] User registration flow
- [x] Login flow with KYC check
- [x] KYC submission with image upload
- [x] Package activation flow
- [x] Dashboard data display
- [x] Referral link generation (FIXED format)
- [x] Profile status display (dynamic)

### ⏳ Pending Tests
- [ ] Withdrawal request submission
- [ ] Transaction history loading
- [ ] Income calculation accuracy
- [ ] Team tree visualization
- [ ] Error handling for network failures
- [ ] Offline mode behavior

---

## 🔒 Security Considerations

### ✅ Implemented
- Token-based authentication
- Secure password handling (not stored locally)
- HTTPS API calls (assumed)
- File upload validation (image types)

### ⚠️ Needs Attention
- Token expiration handling (no refresh token logic visible)
- Input sanitization on forms
- Rate limiting on API calls
- Secure storage for sensitive data (consider flutter_secure_storage)

---

## 📞 API Base URL Configuration

**Location:** Check `lib/constants/api_constants.dart` or `lib/services/api_service.dart`

**Expected format:**
```dart
static const String baseUrl = 'https://api.propel.hoomaservice.com';
```

**Production URL:** Should be `https://propel.hoomaservice.com/api` or similar

---

## 🎨 Assets & Resources

### Images
- `assets/profile.avif` - Default profile picture

### Logo
- Path mentioned in request: `propples\assets\Group 1 (1).png`
- **Action Required:** Update AndroidManifest.xml and iOS Info.plist with correct logo path

---

## 📦 Dependencies (pubspec.yaml)

### Core Dependencies
```yaml
flutter:
  sdk: flutter
http: ^1.1.0                    # HTTP client
shared_preferences: ^2.1.1      # Local storage
image_picker: ^1.0.7            # Image selection
google_fonts: ^6.1.0            # Typography
```

### Required for Future
- `flutter_secure_storage` - For token security
- `share_plus` - For sharing functionality
- `url_launcher` - For opening links
- `flutter_local_notifications` - For notifications

---

## 📄 File Structure Summary

```
lib/
├── main.dart                    # App entry point
├── constants/
│   ├── api_constants.dart       # API endpoints
│   └── api_endpoints.dart       # (duplicate, cleanup needed)
├── models/                      # All data models
│   ├── login_response.dart
│   ├── register_response.dart
│   ├── packages_list_response.dart
│   ├── payment_models.dart
│   ├── referral_code_response.dart
│   ├── referrals_list_response.dart
│   ├── dashboard_response.dart
│   ├── kyc_models.dart
│   └── upload_image_response.dart
├── routes/
│   └── app_router.dart          # Navigation
├── screens/                     # All UI screens (22 files)
│   ├── splash_screen.dart
│   ├── login_page.dart
│   ├── create_account_page.dart
│   ├── complete_kyc_page.dart
│   ├── account_inactive_page.dart
│   ├── activation_packages_page.dart
│   ├── package_activation_page.dart
│   ├── dashboard_page.dart
│   ├── profile_kyc_page.dart
│   ├── refer_and_earn_page.dart
│   ├── wallet_page.dart
│   ├── withdraw_request_page.dart
│   ├── transaction_history_page.dart
│   ├── my_team_page.dart
│   ├── direct_referral_income_page.dart
│   ├── matching_income_page.dart
│   ├── reward_income_page.dart
│   ├── support_page.dart
│   ├── terms_conditions_page.dart
│   ├── rank_system_page.dart
│   ├── home_page.dart
│   └── global_turnover_page.dart
├── services/
│   ├── auth_service.dart        # Authentication state
│   ├── api_service.dart         # HTTP client
│   └── api_repository.dart      # Typed API methods
├── utils/
│   └── colors.dart              # Theme colors
└── widgets/
    ├── app_drawer.dart          # Navigation drawer
    └── bottom_nav.dart          # Bottom navigation
```

---

## 🚀 Deployment Checklist

### Android
- [x] App name changed to "Propel"
- [ ] Update logo in `android/app/src/main/res/` folders
- [ ] Update package name if needed
- [ ] Configure release signing
- [ ] Test on multiple Android versions

### iOS
- [ ] Update app name in Info.plist
- [ ] Update logo assets
- [ ] Configure bundle identifier
- [ ] Test on multiple iOS versions

### Backend
- [ ] Ensure all endpoints are production-ready
- [ ] Set up proper error handling
- [ ] Configure CORS if needed
- [ ] Set up monitoring/logging

---
### January 1, 2026 - v1.1.0
- ✅ Fixed KYC submission flow to check referral code before navigation
- ✅ Updated login flow to check both KYC status AND referral code
- ✅ Smart navigation: If user already has referral code after KYC, go directly to dashboard
- ✅ Added debug logging for KYC payload, responses, and navigation decisions
- ✅ Fixed app drawer KYC status display with proper API integration
- ✅ Removed unused `_loading` field from app drawer (fixed analyzer warning)
- ✅ Updated profile page with debug logging for status fetching

### January 1, 2026 - v1.0.0
## 📝 Changelog

### January 1, 2026
- ✅ Fixed referral link format to `https://propel.hoomaservice.com/?refcode=H63FT5NO`
- ✅ Updated profile page with dynamic Account Status and KYC Status
- ✅ Removed add referral form from Refer & Earn page
- ✅ Updated app drawer to show conditional "Complete KYC" menu item
- ✅ Fixed all analyzer errors related to KYC models and app drawer
- ✅ Created comprehensive documentation

---

## 🎯 Summary

### What's Working ✅
1. Complete authentication flow (Register → Login → KYC → Activate → Dashboard)
2. Package activation with payment proof upload
3. Referral system with proper link format
4. Dashboard with real-time stats from API
5. KYC submission and status checking
6. Dynamic UI based on user state (KYC pending/verified, account active/inactive)

### What Needs Work ⚠️
1. Withdrawal API integration
2. Transaction history API
3. Income detail pages with real data
4. Team view API
5. Sharing functionality implementation
6. Bank account management

### What's Ready for Production 🚀
- Core user journey (registration through activation)
- Authentication system
- Package purchase flow
- Referral system
- Basic dashboard

**Overall Status:** 70% Complete - Core features working, peripheral features need API integration

---

## 📧 Support & Maintenance

For technical issues, refer to:
1. This documentation
2. API endpoint documentation (if available separately)
3. Flutter official docs
4. Individual file comments

**Last Updated:** January 1, 2026  
**Version:** 1.0.0  
**Author:** Propel Development Team
