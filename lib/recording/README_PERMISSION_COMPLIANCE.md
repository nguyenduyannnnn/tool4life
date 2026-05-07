# Apple App Store Compliant Recording Implementation

This implementation fully complies with **Apple App Store Guideline 5.1.1 (Privacy - Data Collection and Storage)** by implementing proper permission handling and user consent for audio processing.

## 🚫 What Was Fixed

### 1. **REMOVED Pre-Permission Dialog** ❌
- **Before**: App showed custom dialog before requesting microphone permission
- **After**: Permission requested directly when user taps "Start Recording"
- **Compliance**: No custom dialogs before system permission request

### 2. **ADDED Upload Consent Dialog** ✅
- **Before**: Audio uploaded without explicit user consent
- **After**: Clear consent dialog before first upload explaining data processing
- **Compliance**: Explicit user consent for data collection and processing

## ✅ Current Compliant Implementation

### 1. **Apple-Compliant Permission Flow**

#### When User Taps "Start Recording":
```dart
// NO pre-permission dialog - directly request permission
final status = await Permission.microphone.request();

if (status.isGranted) {
  // Start recording immediately
  await startRecording();
} else if (status.isDenied) {
  // Show passive UI (no aggressive prompting)
  showPassiveDeniedUI();
} else if (status.isPermanentlyDenied) {
  // Show "Open Settings" button only
  showOpenSettingsButton();
}
```

#### Strictly Forbidden Actions ❌
- ❌ No custom dialog before system permission request
- ❌ No "Continue" or "Cancel" options before permission
- ❌ No aggressive re-prompting after denial
- ❌ No blocking UI forcing permission

### 2. **Upload Consent System**

#### Before First Upload:
```dart
// Show consent dialog explaining data processing
final userAgreed = await showConsentDialog(
  title: "Audio Processing Notice",
  message: "Your audio will be uploaded to Meobeo servers for transcription...",
  buttons: ["Cancel", "Agree"]
);

if (userAgreed) {
  await uploadAudio();
} else {
  // Respect user decision - do not upload
}
```

#### Consent Dialog Content:
- **Vietnamese**: "Bản ghi âm của bạn sẽ được tải lên máy chủ của Meobeo để chuyển đổi thành văn bản và tạo ghi chú cuộc họp. Dữ liệu được xử lý hoàn toàn trên hạ tầng của Meobeo bằng các mô hình AI nội bộ và không được chia sẻ với bất kỳ bên thứ ba nào. Bạn có đồng ý tiếp tục không?"
- **Buttons**: "Hủy" (Cancel) / "Đồng ý" (Agree)

### 3. **Data Processing Transparency**

The consent dialog clearly explains:
- ✅ Audio is uploaded to Meobeo servers
- ✅ Purpose: transcription and meeting notes
- ✅ Processing done entirely on Meobeo infrastructure
- ✅ Uses internal AI models only
- ✅ NO third-party services involved
- ✅ User can decline without consequences

## 🏗️ Architecture

### Core Services

1. **`PermissionService`** - Apple-compliant permission handling
   ```dart
   // ONLY request after user interaction
   await Permission.microphone.request();
   ```

2. **`ConsentService`** - Upload consent management
   ```dart
   final hasConsent = await ConsentService().hasUserConsent();
   await ConsentService().grantConsent();
   ```

3. **`UploadService`** - Consent-aware upload
   ```dart
   // Shows consent dialog on first upload
   await uploadService.uploadRecording(recording, context: context);
   ```

### Permission Flow

```
User taps "Start Recording"
         ↓
Check current permission status
         ↓
┌─────────────────┬─────────────────┬─────────────────┐
│    GRANTED      │     DENIED      │ PERMANENTLY     │
│                 │                 │    DENIED       │
│ Start recording │ Request         │ Show "Open      │
│ immediately     │ permission      │ Settings"       │
│                 │ directly        │ button          │
└─────────────────┴─────────────────┴─────────────────┘
                          │
                          ↓
                  System permission dialog
                          │
                          ↓
                ┌─────────────────┬─────────────────┐
                │    GRANTED      │     DENIED      │
                │                 │                 │
                │ Start recording │ Show passive    │
                │                 │ denied UI       │
                │                 │ (NO re-asking)  │
                └─────────────────┴─────────────────┘
```

### Upload Consent Flow

```
Recording completed
         ↓
Check if user has given consent
         ↓
┌─────────────────┬─────────────────┐
│  HAS CONSENT    │   NO CONSENT    │
│                 │                 │
│ Upload          │ Show consent    │
│ immediately     │ dialog          │
└─────────────────┴─────────────────┘
                          │
                          ↓
                  User decides
                          │
                          ↓
                ┌─────────────────┬─────────────────┐
                │     AGREE       │     CANCEL      │
                │                 │                 │
                │ Store consent   │ Save locally    │
                │ & upload        │ only (no upload)│
                └─────────────────┴─────────────────┘
```

## 📱 User Experience

### Compliant Permission Flow
1. User opens app → Clean interface, no permission requests
2. User taps "Start Recording" → System permission dialog appears immediately
3. If granted → Recording starts
4. If denied → Passive UI: "Microphone access denied. You can enable it in Settings if needed."
5. If permanently denied → "Open Settings" button

### Upload Consent Flow
1. First recording completed → Consent dialog appears
2. User reads explanation about data processing
3. User chooses "Agree" or "Cancel"
4. If agreed → Upload proceeds, consent stored
5. If cancelled → Recording saved locally only
6. Future recordings → No dialog (consent remembered)

## 🔧 Implementation Files

### New Files Created:
- `lib/recording/services/consent_service.dart` - Manages upload consent
- `lib/recording/widgets/consent_dialog.dart` - Consent UI dialog
- `lib/recording/examples/compliant_recording_example.dart` - Demo implementation

### Updated Files:
- `lib/recording/services/permission_service.dart` - Enhanced compliance documentation
- `lib/recording/services/upload_service.dart` - Added consent checking
- `lib/recording/services/recording_foreground_service.dart` - Consent-aware uploads
- `lib/presentation/modules/dashboard/module/recording/src/ui/recording_screen.dart` - Removed pre-permission dialog

### Removed Violations:
- ❌ `PrePermissionScreen` - No longer used (violates Apple guidelines)
- ❌ Custom permission dialogs before system request
- ❌ Aggressive re-prompting after denial

## 🧪 Testing

### Test the Compliant Flow:
```dart
import 'package:meobeo/recording/examples/compliant_recording_example.dart';

// Navigate to test screen:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CompliantRecordingExample()),
);
```

### Test Scenarios:
1. **First time user** → Permission requested on button tap
2. **Permission granted** → Recording starts immediately
3. **Permission denied** → Passive UI with optional retry
4. **Permanently denied** → "Open Settings" button only
5. **First upload** → Consent dialog appears
6. **Consent granted** → Upload proceeds
7. **Consent denied** → Recording saved locally only
8. **Subsequent uploads** → No consent dialog (remembered)

## 📋 App Store Compliance Checklist

- ✅ No permission requests on app launch
- ✅ No custom dialogs before system permission request
- ✅ Permission requested only after user interaction
- ✅ No aggressive re-prompting after denial
- ✅ Passive UI for denied states
- ✅ "Open Settings" only for permanent denial
- ✅ Clear consent dialog before data upload
- ✅ Explicit explanation of data processing
- ✅ User can decline without consequences
- ✅ Consent stored and remembered
- ✅ Respectful user experience

This implementation should pass Apple's App Store review process and comply with privacy guidelines while providing a smooth user experience.