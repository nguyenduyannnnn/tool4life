# CLAUDE.md

File hướng dẫn cho Claude Code khi làm việc trên repo này. Đọc trước khi đề xuất hoặc viết code.

## Ngôn ngữ giao tiếp

- Trả lời người dùng bằng **tiếng Việt** cho mọi giải thích, mô tả, plan.
- Giữ nguyên **tiếng Anh** cho: code, comment trong code, identifier, commit message, log/print, tên file.
- Không dùng emoji trừ khi user yêu cầu.

## Tổng quan dự án

**tool4life** — ứng dụng Flutter cá nhân để ghi nhận hoạt động hằng ngày:

- **Finance**: thu/chi cá nhân
- **Todo**: danh sách công việc
- **Places**: review địa điểm đã đi (kèm hình ảnh)
- **Recording**: ghi âm + transcript (kế thừa từ codebase gốc Chang Meeting)
- **Photos**: upload hình ảnh nơi đã đi, đồ ăn

Lưu ý: package name trong `pubspec.yaml` vẫn là `changmeeting` và codebase còn nhiều artifact của bản gốc (meeting, transcript, Azure OAuth...). Khi thêm tính năng mới của tool4life, dùng module riêng dưới `lib/presentation/modules/dashboard/module/` thay vì sửa code meeting cũ — trừ khi user yêu cầu refactor.

## Kiến trúc — Clean Architecture

Code chia 3 layer rõ ràng. Tuân thủ chiều phụ thuộc: `presentation → domain → data`. Không bao giờ import ngược.

```
lib/
├── main.dart                    # Entry point, init services, MaterialApp
├── common/                      # Config, theme, constants, utilities, l10n, utils
│   ├── config.dart              # SharedPreferences config
│   ├── theme.dart               # AppTheme.lightTheme
│   ├── constant.dart
│   ├── globals.dart
│   ├── utilities.dart           # Utilities.customPrint, hideKeyboard...
│   ├── localization/            # LangKey delegate
│   └── utils/                   # CustomNavigator, CustomDialog, debounce, image picker...
├── config/                      # OAuth config
├── data/                        # Tầng data
│   ├── local/shared_prefs/      # Local storage
│   ├── models/                  # request/, response/, base/, *_model.dart
│   ├── network/                 # api/, http/, connectivity_checker
│   ├── repository/              # *_repository.dart — gọi API qua Interaction
│   └── services/                # OAuth, meeting download/share, file services
├── domain/                      # Tầng domain
│   ├── interaction/interaction.dart  # Lớp Interaction (HTTP wrapper) cho repository
│   └── repository.dart          # Static methods, ví dụ Repository.login(...)
├── generated/                   # intl_utils auto-gen, KHÔNG sửa tay
├── l10n/                        # File dịch (en, vi)
├── presentation/                # Tầng UI
│   ├── base/base_view.dart      # BaseView + BaseBloc — abstraction lõi
│   ├── widgets/                 # Custom shared widgets (custom_button, custom_text...)
│   └── modules/
│       ├── authen_module/src/{bloc,ui}/
│       └── dashboard/
│           ├── src/{bloc,ui,widgets}/         # Vỏ dashboard
│           └── module/                         # Tính năng con
│               ├── account/
│               ├── finance/                    # MỚI — thu chi
│               ├── home/
│               │   ├── src/ui/
│               │   └── module/{recordings, notification}/
│               ├── meeting_detail/
│               ├── places/                     # MỚI — review địa điểm
│               ├── profile/
│               ├── recording/
│               ├── statistics/
│               └── todo/                       # MỚI — todo list
├── recording/                   # Service ghi âm: file_manager_service, migration_service
└── widgets/                     # Legacy widgets ngoài presentation/widgets
```

## State management — BLoC tự build (không phải `flutter_bloc`)

Repo này **KHÔNG dùng package `flutter_bloc`**. Pattern BLoC ở đây là custom abstraction trong `lib/presentation/base/base_view.dart`, dựa trên `rxdart.BehaviorSubject`.

Quy ước cho mỗi màn hình:

- `something_screen.dart` extends `BaseView` (chỉ chứa UI, không có state).
- `something_bloc.dart` extends `BaseBloc<SomethingScreen>` — chính là `State<SomethingScreen>`.
- `BaseBloc` cung cấp 4 hook thay cho `initState/dispose`: `onInit()`, `onReady()`, `onResumed()`, `onDispose()`.
- Truy cập `widget.context` và `widget.setState` từ BLoC (đã được wire trong `BaseBloc.initState`).
- Stream/state expose qua `BehaviorSubject<T>`. Có extension tiện ích: `subject.set(value)`, `subject.setError(msg)`, `subject.output` (= stream).
- UI build dùng `StreamBuilder` đọc từ `bloc.subject.output`.

Khi tạo feature mới, follow đúng cấu trúc folder `bloc/` + `ui/`. Tham khảo:
- `lib/presentation/modules/authen_module/src/bloc/splash_bloc.dart`
- `lib/presentation/modules/authen_module/src/ui/splash_screen.dart`

## Networking & repository pattern

- `domain/interaction/interaction.dart` là HTTP wrapper (có `.get()`, `.post()`...) — nhận `context`, `url`, `param`, `showError`.
- `domain/repository.dart` expose **static methods** trả về kết quả Interaction. Ví dụ:
  ```dart
  Repository.login(context, model, showError)
  ```
- `data/repository/*_repository.dart` là các repository chuyên biệt (azure_login, meeting_detail, upload_recording...).
- `data/network/api/` định nghĩa endpoint (class `API`).
- Models: `request/`, `response/`, base classes ở `data/models/base/`.

Khi thêm API mới: thêm endpoint vào `API` → tạo model trong `data/models/{request,response}/` → thêm method vào repository tương ứng (hoặc tạo mới).

## Local storage

- `shared_preferences` qua `Config.getPreferences()` (gọi trong `main.dart`).
- File hệ thống: `path_provider` + `recording/services/file_manager_service.dart` cho audio.
- Khi cần lưu offline cho finance/todo/places, cân nhắc đề xuất với user trước (sqlite/hive/json file) — repo hiện chưa có DB.

## Convention thực thi

- Đọc file trước khi sửa (tool `Read`).
- **Không** thêm comment giải thích WHAT — chỉ thêm khi giải thích WHY không hiển nhiên.
- **Không** tự refactor/cleanup ngoài scope task được giao.
- **Không** thêm error handling/validation cho trường hợp không thể xảy ra.
- Tuân thủ `analysis_options.yaml` (flutter_lints).
- Asset image: bỏ vào `assets/image/`, font vào `assets/font/`, icon vào `assets/icon/` rồi khai báo trong `pubspec.yaml`.
- Dịch text: đặt key trong `assets/language/` + `lib/l10n/`, dùng qua `LangKey`.
- Font mặc định: `IBM Plex Sans`, có sẵn `Roboto Serif` và `SF Pro Display`.
- Locale: `en_US` (hardcode trong `main.dart`), supported `vi_VN`.

## Lệnh hay dùng

- `flutter pub get` — sau khi sửa `pubspec.yaml`.
- `flutter run` — chạy debug.
- `flutter analyze` — lint check.
- `flutter pub run intl_utils:generate` — gen lại file dịch sau khi sửa l10n.
- `flutter pub run flutter_launcher_icons` — gen lại app icon.
- `flutter pub run flutter_native_splash:create` — gen lại splash screen.

## Permission (Android)

`android/app/src/main/AndroidManifest.xml` đang được sửa. Khi thêm permission mới (camera, location, storage cho places/photos), nhớ:
- Thêm `<uses-permission>` trong manifest.
- Yêu cầu runtime qua `permission_handler` — đã có wrapper `lib/common/custom_permission_request.dart`.
- iOS: thêm key tương ứng vào `ios/Runner/Info.plist`.

## Khi không chắc — hỏi user

- Trước khi tạo abstraction mới (DB layer, DI, navigation router...) — repo đang đơn giản, đừng tự thêm hệ thống mới.
- Trước khi đổi tên package `changmeeting` → `tool4life` — cần đổi ở nhiều nơi (Android applicationId, iOS bundle, import path).
- Trước khi xóa code "meeting"/"recording" cũ — có thể vẫn còn dùng.
