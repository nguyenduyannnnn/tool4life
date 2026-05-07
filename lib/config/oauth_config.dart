class OAuthConfig {
  // Google OAuth Configuration
  // Bạn cần lấy từ Google Cloud Console: https://console.cloud.google.com/
  static const String googleClientId = '104601458005-1qctct2gpe4m1n99n9ekguvih4j7t4td.apps.googleusercontent.com';
  
  // Azure AD Configuration  
  // Bạn cần lấy từ Azure Portal: https://portal.azure.com/
  static const String azureTenantId = 'f01e930a-b52e-42b1-b70f-a8882b5d043b'; // hoặc 'common' cho multi-tenant
  static const String azureClientId = 'fa3b2fbf-8119-414c-afbc-040505301618';
  static const String azureRedirectUri = 'msauth.annd11.mobile.changmeeting://auth'; // Custom scheme
  
  // Scopes
  static const List<String> googleScopes = [
    'email',
    'profile',
  ];
  
  static const String azureScopes = 'openid profile email User.Read';
}

/*
HƯỚNG DẪN SETUP:

1. GOOGLE SIGN-IN:
   - Truy cập: https://console.cloud.google.com/
   - Tạo project mới hoặc chọn project hiện có
   - Bật Google+ API và Google Sign-In API
   - Tạo OAuth 2.0 Client ID:
     * Application type: Android/iOS
     * Package name: com.meobeo.app (từ android/app/build.gradle)
     * SHA-1 certificate fingerprint (lấy từ debug keystore)
   - Copy Client ID và thay thế googleClientId ở trên

2. AZURE AD SIGN-IN:
   - Truy cập: https://portal.azure.com/
   - Vào Azure Active Directory > App registrations
   - Tạo "New registration":
     * Name: Meobeo Mobile App
     * Supported account types: Accounts in any organizational directory and personal Microsoft accounts
     * Redirect URI: Public client/native (mobile & desktop) - msauth.annd11.mobile.changmeeting://auth
   - Copy Application (client) ID và Directory (tenant) ID
   - Thay thế azureClientId và azureTenantId ở trên

3. ANDROID CONFIGURATION:
   - Thêm vào android/app/build.gradle trong defaultConfig:
     manifestPlaceholders = [
       'appAuthRedirectScheme': 'annd11.mobile.meobeo'
     ]
   
   - Thêm vào android/app/src/main/AndroidManifest.xml trong <application>:
     <activity
       android:name="com.linusu.flutter_web_auth_2.CallbackActivity"
       android:exported="true">
       <intent-filter android:autoVerify="true">
         <action android:name="android.intent.action.VIEW" />
         <category android:name="android.intent.category.DEFAULT" />
         <category android:name="android.intent.category.BROWSABLE" />
         <data android:scheme="annd11.mobile.meobeo" />
       </intent-filter>
     </activity>

4. iOS CONFIGURATION:
   - Thêm vào ios/Runner/Info.plist:
     <key>CFBundleURLTypes</key>
     <array>
       <dict>
         <key>CFBundleURLName</key>
         <string>annd11.mobile.meobeo</string>
         <key>CFBundleURLSchemes</key>
         <array>
           <string>annd11.mobile.meobeo</string>
         </array>
       </dict>
     </array>

5. CHẠY LỆNH:
   flutter pub get
   flutter clean
   flutter build android/ios
*/