# 📍 Teams Tracker (TeamsLocator)

<p align="center">
  <!-- BANNER / HERO IMAGE PLACEHOLDER -->
  <img src="docs/screenshots/banner.png" alt="Teams Tracker Banner" width="100%" />
</p>

<p align="center">
  <strong>Enterprise-Grade Field Force Automation & Real-Time Sales Team Location Tracking Mobile Application</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/State_Management-RxDart-ED1B24?style=for-the-badge" alt="RxDart" />
  <img src="https://img.shields.io/badge/Networking-Dio-009688?style=for-the-badge" alt="Dio" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License" />
</p>

---

## 📖 Overview

**Teams Tracker** (also known as **TeamsLocator**) is a production-ready Flutter mobile application designed for companies managing on-field sales teams, delivery executives, and territory representatives. It bridges field operations with management oversight by offering **real-time GPS location monitoring**, **geofenced duty attendance**, **instant order booking**, **due payment collection**, **tour plan routing**, and a comprehensive **supervisor approval workflow**.

Built using **Feature-First Clean Architecture**, **RxDart reactive streams**, **Dio HTTP client**, and a modern **Glassmorphic emerald UI design**, the app provides two specialized role-based experiences:
1. **Employee (Field Officer / Sales Representative)**
2. **Supervisor (Territory Manager / Team Lead)**

---

## 📱 App Screenshots & Preview

> [!TIP]
> Replace the image paths below (`docs/screenshots/...`) with your actual screenshots or mockups.

### 🔐 Authentication & Onboarding
| Splash & Welcome | Login (Role-Based) | Registration |
| :---: | :---: | :---: |
| <img src="docs/screenshots/splash.png" width="260" alt="Splash Screen Placeholder" /><br>*(Add Splash Image)* | <img src="docs/screenshots/login.png" width="260" alt="Login Screen Placeholder" /><br>*(Add Login Image)* | <img src="docs/screenshots/register.png" width="260" alt="Registration Screen Placeholder" /><br>*(Add Register Image)* |

---

### 👔 Employee / Field Officer Suite
| Field Dashboard & GPS | Attendance Check-In / Out | Quick Action Dock |
| :---: | :---: | :---: |
| <img src="docs/screenshots/employee_home.png" width="260" alt="Employee Home Placeholder" /><br>*(Add Employee Home Image)* | <img src="docs/screenshots/employee_attendance.png" width="260" alt="Attendance Screen Placeholder" /><br>*(Add Attendance Image)* | <img src="docs/screenshots/quick_actions.png" width="260" alt="Quick Actions Placeholder" /><br>*(Add Quick Actions Image)* |

| Order Booking (Cart) | Due Payment Collection | Product Catalog |
| :---: | :---: | :---: |
| <img src="docs/screenshots/take_order.png" width="260" alt="Order Booking Placeholder" /><br>*(Add Take Order Image)* | <img src="docs/screenshots/collect_due.png" width="260" alt="Collect Due Placeholder" /><br>*(Add Collect Due Image)* | <img src="docs/screenshots/catalog.png" width="260" alt="Catalog Placeholder" /><br>*(Add Catalog Image)* |

| Tour Plan Route | Leave Application | Profile & Stats |
| :---: | :---: | :---: |
| <img src="docs/screenshots/tour_plan.png" width="260" alt="Tour Plan Placeholder" /><br>*(Add Tour Plan Image)* | <img src="docs/screenshots/leave_apply.png" width="260" alt="Leave Apply Placeholder" /><br>*(Add Leave Apply Image)* | <img src="docs/screenshots/profile.png" width="260" alt="Profile Placeholder" /><br>*(Add Profile Image)* |

---

### 🛡️ Supervisor & Territory Lead Suite
| Supervisor Dashboard | Live Team Tracking Map | Team Sales Analytics |
| :---: | :---: | :---: |
| <img src="docs/screenshots/supervisor_home.png" width="260" alt="Supervisor Home Placeholder" /><br>*(Add Supervisor Home Image)* | <img src="docs/screenshots/supervisor_map.png" width="260" alt="Live Map Placeholder" /><br>*(Add Live Map Image)* | <img src="docs/screenshots/team_sales.png" width="260" alt="Team Sales Placeholder" /><br>*(Add Team Sales Image)* |

| Team Attendance Logs | Employee Roster | Leave & Tour Approvals |
| :---: | :---: | :---: |
| <img src="docs/screenshots/supervisor_attendance.png" width="260" alt="Supervisor Attendance Placeholder" /><br>*(Add Supervisor Attendance Image)* | <img src="docs/screenshots/view_employees.png" width="260" alt="Employee Roster Placeholder" /><br>*(Add Employee Roster Image)* | <img src="docs/screenshots/leave_approvals.png" width="260" alt="Leave Approvals Placeholder" /><br>*(Add Approvals Image)* |

---

## 🌟 Key Features

### 👤 1. Field Employee Module
- **Live GPS & Device Health Tracking**: Monitors real-time coordinates, current street address, and device battery level.
- **One-Tap Duty Toggle**: Seamless Check-In and Check-Out with exact timestamp recording and working hours calculation.
- **New Order Booking**: Browse catalogue, pick retail shops, add products to cart, and generate orders on the spot.
- **Market Due Collection**: Collect payments from retail shop owners and instantly generate collection records.
- **Tour Plan Management**: Create and submit route plans for daily field visits and market targets.
- **Client & Retailer Onboarding**: Quick modal sheet to add new client stores and assign coordinates directly from the field.
- **Digital Product Catalog**: High-resolution product images, trade prices, specifications, and inventory availability.
- **Leave Application**: Submit sick, casual, or annual leaves directly to the supervisor for fast-track approvals.

### 🛡️ 2. Supervisor & Territory Lead Module
- **Team Command Center**: Real-time overview of active field officers, territory metrics, and total sales volume.
- **Live Team Tracking**: Monitor where field executives are located with real-time GPS pings.
- **Attendance Oversight**: Monitor daily team attendance, punctuality, late arrivals, and absent staff members.
- **Team Sales & Revenue Dashboard**: Real-time analytics of total targets vs. actual achievement across the entire assigned territory.
- **Field Request Approvals**: One-click verification and approval of pending leave applications and weekly tour routes.
- **Customer & Store Directory**: Complete directory of territory retailers with outstanding credit balances and order history.
- **Supervisor Own Duty**: Dedicated check-in/out and expense reporting for territory managers.

### ⚡ 3. Technical & Architectural Highlights
- **Role-Based Dynamic Routing**: Automatically detects user role (`supervisor` vs. `employee`) on app startup and boots into the respective module.
- **RxDart Reactive State Management**: Clean state emission using `BehaviorSubject`, isolating UI from business logic.
- **Robust Dio Networking**: Configured with request/response logging, centralized error handling, and authorization interceptors.
- **Micro-Animations & Glassmorphism**: Custom frosted-glass bottom bar, ambient gradient glowing orbs, and buttery-smooth `FadedTransitionRoute` transitions.
- **Local Persistence**: Fast and reliable key-value local storage with `GetStorage` and service location via `GetIt`.
- **Responsive Layout**: Pixel-perfect adaptation across devices using `flutter_screenutil` (base size: 375x812).

---

## 🏗️ Project Architecture

The project follows a clean **Feature-First Structure**:

```plaintext
lib/
├── assets_helper/               # Asset constants (colors, fonts, icons, images, lottie)
│   ├── app_colors.dart          # Emerald green and slate dark/light theme palette
│   ├── app_fonts.dart           # Font definitions (Outfit, etc.)
│   ├── app_icons.dart           # Vector and icon constants
│   ├── app_image.dart           # Image path constants
│   └── app_lottie.dart          # Lottie animations
├── common_widgets/              # Reusable UI widgets across modules
├── constants/                   # App constants, validators, regex, color states
│   ├── app_constants.dart       # Storage keys, order statuses, app preferences
│   └── textfield_validation.dart
├── features/                    # Core business modules
│   ├── auth_screen/             # Authentication (Login, Register, Session)
│   │   ├── data/                # Auth APIs, Rx streams, requests
│   │   ├── signin_screen.dart
│   │   └── signup_screen.dart
│   ├── employee_part/           # Employee field module
│   │   ├── attendence_screen/   # Attendance logs & history
│   │   ├── catalog_screen/      # Product catalog & pricing
│   │   ├── home_screen/         # Live GPS home & duty check-in
│   │   ├── leave_screen/        # Leave application
│   │   ├── order_screen/        # New orders & due collection
│   │   ├── profile_screen/      # Profile, notifications & settings
│   │   ├── tour_plan_screen/    # Field visiting routes
│   │   └── employee_bottom_nav.dart # Floating docked navigation
│   └── supervisor_part/         # Supervisor management module
│       ├── supervisor_attendence_screen/ # Team attendance overview
│       ├── supervisor_dashboard_screen/  # Analytics & expense tracking
│       ├── supervisor_home_screen/       # Control center & team summary
│       ├── supervisor_profile_screen/    # Supervisor profile
│       ├── supervisor_sales_screen/      # Territory sales performance
│       └── supervisor_bottom_nav.dart    # Supervisor navigation dock
├── helpers/                     # Application helpers & utilities
│   ├── all_routes.dart          # Route generator & custom faded page transitions
│   ├── di.dart                  # Dependency injection setup (GetIt)
│   └── navigation_service.dart  # Global navigation context service
├── networks/                    # Centralized network layer
│   ├── dio/                     # Dio instance, interceptors, logger
│   ├── exception_handler/       # API error mappings & status responses
│   ├── endpoints.dart           # Base URLs and API endpoint constants
│   └── rx_base.dart             # RxDart base stream wrappers
└── main.dart                    # App entry point, theme & initial route resolver
```

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology / Package | Description |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart SDK `^3.10.8`) | Cross-platform mobile development |
| **State Management** | [RxDart](https://pub.dev/packages/rxdart) `^0.28.0` | Reactive programming with Streams & BehaviorSubject |
| **Networking** | [Dio](https://pub.dev/packages/dio) `^5.7.0` | HTTP client with interceptors and token management |
| **Dependency Injection** | [GetIt](https://pub.dev/packages/get_it) `^8.0.0` | Fast Service Locator |
| **Local Storage** | [GetStorage](https://pub.dev/packages/get_storage) `^2.1.1` | High-performance key-value storage |
| **Screen Sizing** | [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) `^5.9.3` | Responsive UI adaptation across screen sizes |
| **Typography** | [google_fonts](https://pub.dev/packages/google_fonts) `^6.2.1` | Modern Google Fonts typography (Outfit) |
| **Animations** | [Lottie](https://pub.dev/packages/lottie) & [DotLottie](https://pub.dev/packages/dotlottie_loader) | High-fidelity vector animations |
| **Device & Permissions** | [permission_handler](https://pub.dev/packages/permission_handler), [device_info_plus](https://pub.dev/packages/device_info_plus) | Hardware & permission utilities |
| **Image & Media** | [cached_network_image](https://pub.dev/packages/cached_network_image), [image_picker](https://pub.dev/packages/image_picker) | Media caching & camera selection |

---

## 🚀 Getting Started

Follow these steps to set up and run the project locally.

### 📋 Prerequisites
Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.10.8`)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extension
- Physical Android/iOS device or Emulator with location services enabled

### 🔧 Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/teams_tracker_flutter.git
   cd teams_tracker_flutter
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoints:**
   Open `lib/networks/endpoints.dart` and update the base URL to match your backend environment:
   ```dart
   const String baseUrl = "https://your-api-domain.com/user";
   ```

4. **Run the Application:**
   ```bash
   # Run in Debug mode
   flutter run

   # Or run on a specific connected device
   flutter devices
   flutter run -d <device_id>
   ```

5. **Build APK for Testing (Android):**
   ```bash
   flutter build apk --release
   ```

---

## 🔐 Credentials & Role Switching

When running the application, you can test both user experiences:

| Role | Interface | Key Capabilities |
| :--- | :--- | :--- |
| **Employee** | `EmployeeBottomNav` | Check-in/out, take orders, collect dues, apply leaves, tour plans |
| **Supervisor** | `SupervisorBottomNav` | Live team tracking, review leaves & tours, view sales & collections |

*Note: Roles are automatically persisted in `GetStorage` under `kKeyUserRole` (`employee` or `supervisor`).*

---

## 🤝 Contributing

Contributions are always welcome!
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.

---

<p align="center">
  Developed with ❤️ by <strong>Trodev / Your Team</strong>
</p>
