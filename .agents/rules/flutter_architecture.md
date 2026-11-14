# Softvence Flutter Architecture Guidelines

## Architecture & Layers
1. **Feature Directory Structure**:
   - Features reside strictly under `lib/features/<feature>/`.
   - Each feature must use: `presentation/`, `data/rx_<verb>_<resource>/`, `model/`, `widget/`.
2. **State Management (RxDart)**:
   - Use `RxResponseInt` with `BehaviorSubject<Map>()`.
   - Global instances are registered in `lib/networks/api_acess.dart` named with the `RxObj` suffix (e.g., `*RxObj`).
3. **Networking (Dio Singleton)**:
   - Never instantiate `Dio()` inside features. Use `getHttp`, `postHttp`, `putHttp`, `deleteHttp` from `lib/networks/dio/dio.dart`.
   - Endpoints must be defined centrally in `lib/networks/endpoints.dart`.
4. **Navigation**:
   - Use `Routes` constants in `lib/helpers/all_routes.dart` and `NavigationService`.
   - Do not use string literals for route navigation.
5. **Package Imports**:
   - Package imports must always use `package:location_tracker/...`, never former template names or other package names.
6. **Responsive UI**:
   - Use ScreenUtil for sizing: `.w` for width, `.h` for height, `.sp` for fonts, `.r` for radius.
7. **Verification Invariant**:
   - Always run `flutter analyze` and `flutter test` after code modifications.
