# tracker_flutter Project Resume & Context

## 1. Project Overview
- **Name**: `tracker_flutter` (Package Name: `location_tracker`)
- **Type**: Real-time Field Force & Employee Location Tracking Flutter Application
- **Architecture**: Softvence Flutter Template (Feature-first, RxDart reactive flow, Dio singleton client, GetIt/GetStorage, ScreenUtil UI)

## 2. Directory Structure
```
lib/
├── assets_helper/      # Colors, fonts, icons, images, lottie
├── common_widgets/     # Reusable custom UI widgets & buttons
├── constants/          # Storage keys, app constants, theme definitions
├── features/
│   ├── auth_screen/    # Login, Register, Forgot Password, OTP, Reset Password
│   ├── employee_part/  # Employee Dashboard, GPS tracking, Attendance toggle, Sales, Tour, Profile
│   └── supervisor_part/# Supervisor Dashboard, Team tracking, Tour plan approval, Team sales, Profile
├── helpers/            # DI, Navigation, Toasts, Helpers, PostLogin
└── networks/           # Dio client, Centralized Endpoints, RxBase, Exception Handling, ApiAccess
```

## 3. Core Architecture Standards
1. **Feature Layout**: Each feature contains `presentation/`, `data/`, `model/`, `widget/`.
2. **State Management**: RxDart with `RxResponseInt` and `BehaviorSubject<Map>`. Global Rx objects are registered in `lib/networks/api_acess.dart` with `RxObj` suffix.
3. **Networking**: Dio singleton wrapper (`getHttp`, `postHttp`, `putHttp`, `deleteHttp`) with centralized endpoints in `lib/networks/endpoints.dart`.
4. **Local Storage**: `GetStorage` accessed via `appData` helper in `lib/helpers/di.dart`.
5. **Session Management**: `performPostLoginActions()` configures authenticated Dio with Bearer tokens; automatic 401/403 logout with backstack clearing.

## 4. Backend Environment
- **Server**: Local Apache / PHP backend (XAMPP `C:\xampp\htdocs\team_track\user\`)
- **Database**: MySQL `team_track` database
- **Base URL**: `http://localhost/team_track/user` (or `http://10.0.2.2/team_track/user` on Android Emulator)
- **Roles**: `employee`, `supervisor`, `admin`, `super_admin`
