// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class LangKey {
  LangKey();

  static LangKey? _current;

  static LangKey get current {
    assert(
      _current != null,
      'No instance of LangKey was loaded. Try to initialize the LangKey delegate before accessing LangKey.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<LangKey> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = LangKey();
      LangKey._current = instance;

      return instance;
    });
  }

  static LangKey of(BuildContext context) {
    final instance = LangKey.maybeOf(context);
    assert(
      instance != null,
      'No instance of LangKey present in the widget tree. Did you add LangKey.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static LangKey? maybeOf(BuildContext context) {
    return Localizations.of<LangKey>(context, LangKey);
  }

  /// `Lỗi`
  String get error {
    return Intl.message('Lỗi', name: 'error', desc: '', args: []);
  }

  /// `Hết phiên sử dụng!`
  String get token_expired {
    return Intl.message(
      'Hết phiên sử dụng!',
      name: 'token_expired',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi máy chủ!`
  String get server_error {
    return Intl.message(
      'Lỗi máy chủ!',
      name: 'server_error',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi dữ liệu!`
  String get data_error {
    return Intl.message('Lỗi dữ liệu!', name: 'data_error', desc: '', args: []);
  }

  /// `Máy chủ không phản hồi. Vui lòng thử lại sau!`
  String get timeout_error {
    return Intl.message(
      'Máy chủ không phản hồi. Vui lòng thử lại sau!',
      name: 'timeout_error',
      desc: '',
      args: [],
    );
  }

  /// `Kiểm tra kết nối mạng!`
  String get connection_error {
    return Intl.message(
      'Kiểm tra kết nối mạng!',
      name: 'connection_error',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Vị trí`
  String get location {
    return Intl.message('Vị trí', name: 'location', desc: '', args: []);
  }

  /// `Bộ nhớ`
  String get storage {
    return Intl.message('Bộ nhớ', name: 'storage', desc: '', args: []);
  }

  /// `Thu âm`
  String get microphone {
    return Intl.message('Thu âm', name: 'microphone', desc: '', args: []);
  }

  /// `Thông báo`
  String get notification {
    return Intl.message('Thông báo', name: 'notification', desc: '', args: []);
  }

  /// `Cho phép quyền truy cập`
  String get request_permissions {
    return Intl.message(
      'Cho phép quyền truy cập',
      name: 'request_permissions',
      desc: '',
      args: [],
    );
  }

  /// `Chọn Cài đặt vào Thông tin ứng dụng, chọn vào Quyền (Permissions), bật truy cập và vào lại màn hình này để sử dụng quyền`
  String get message_permission {
    return Intl.message(
      'Chọn Cài đặt vào Thông tin ứng dụng, chọn vào Quyền (Permissions), bật truy cập và vào lại màn hình này để sử dụng quyền',
      name: 'message_permission',
      desc: '',
      args: [],
    );
  }

  /// `Quyền truy cập hiện tại đang giới hạn.\nBạn có muốn truy cập đầy đủ không?`
  String get message_permission_limited {
    return Intl.message(
      'Quyền truy cập hiện tại đang giới hạn.\nBạn có muốn truy cập đầy đủ không?',
      name: 'message_permission_limited',
      desc: '',
      args: [],
    );
  }

  /// `Vẫn truy cập`
  String get still_access {
    return Intl.message(
      'Vẫn truy cập',
      name: 'still_access',
      desc: '',
      args: [],
    );
  }

  /// `Tôi đã hiểu`
  String get i_get_it {
    return Intl.message('Tôi đã hiểu', name: 'i_get_it', desc: '', args: []);
  }

  /// `Chụp ảnh`
  String get capture {
    return Intl.message('Chụp ảnh', name: 'capture', desc: '', args: []);
  }

  /// `Chọn từ thư viện`
  String get select_from_gallery {
    return Intl.message(
      'Chọn từ thư viện',
      name: 'select_from_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Cho phép`
  String get allow {
    return Intl.message('Cho phép', name: 'allow', desc: '', args: []);
  }

  /// `Chưa có dữ liệu`
  String get data_empty {
    return Intl.message(
      'Chưa có dữ liệu',
      name: 'data_empty',
      desc: '',
      args: [],
    );
  }

  /// `Xác nhận`
  String get confirm {
    return Intl.message('Xác nhận', name: 'confirm', desc: '', args: []);
  }

  /// `Đóng`
  String get close {
    return Intl.message('Đóng', name: 'close', desc: '', args: []);
  }

  /// `Đăng nhập`
  String get login {
    return Intl.message('Đăng nhập', name: 'login', desc: '', args: []);
  }

  /// `Nhập thông tin tài khoản để tiếp tục`
  String get login_header {
    return Intl.message(
      'Nhập thông tin tài khoản để tiếp tục',
      name: 'login_header',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Mật khẩu`
  String get password {
    return Intl.message('Mật khẩu', name: 'password', desc: '', args: []);
  }

  /// `Quên mật khẩu`
  String get forget_password {
    return Intl.message(
      'Quên mật khẩu',
      name: 'forget_password',
      desc: '',
      args: [],
    );
  }

  /// `Nhập số điện thoại để cài lại mật khẩu`
  String get forget_password_header {
    return Intl.message(
      'Nhập số điện thoại để cài lại mật khẩu',
      name: 'forget_password_header',
      desc: '',
      args: [],
    );
  }

  /// `Tạo mật khẩu`
  String get create_password {
    return Intl.message(
      'Tạo mật khẩu',
      name: 'create_password',
      desc: '',
      args: [],
    );
  }

  /// `Nhập mật khẩu mới để cài lại`
  String get create_password_header {
    return Intl.message(
      'Nhập mật khẩu mới để cài lại',
      name: 'create_password_header',
      desc: '',
      args: [],
    );
  }

  /// `Đăng ký`
  String get sign_up {
    return Intl.message('Đăng ký', name: 'sign_up', desc: '', args: []);
  }

  /// `Tạo một tài khoản mới`
  String get sign_up_header {
    return Intl.message(
      'Tạo một tài khoản mới',
      name: 'sign_up_header',
      desc: '',
      args: [],
    );
  }

  /// `Nhập mã 4 chữ số chúng tôi đã gửi cho bạn`
  String get otp_header {
    return Intl.message(
      'Nhập mã 4 chữ số chúng tôi đã gửi cho bạn',
      name: 'otp_header',
      desc: '',
      args: [],
    );
  }

  /// `Số điện thoại`
  String get phone_number {
    return Intl.message(
      'Số điện thoại',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Việt Nam`
  String get viet_nam {
    return Intl.message('Việt Nam', name: 'viet_nam', desc: '', args: []);
  }

  /// `Mỹ`
  String get usa {
    return Intl.message('Mỹ', name: 'usa', desc: '', args: []);
  }

  /// `Hoặc`
  String get or {
    return Intl.message('Hoặc', name: 'or', desc: '', args: []);
  }

  /// `Tiếp tục`
  String get continue_string {
    return Intl.message(
      'Tiếp tục',
      name: 'continue_string',
      desc: '',
      args: [],
    );
  }

  /// `Gửi lại`
  String get send_again {
    return Intl.message('Gửi lại', name: 'send_again', desc: '', args: []);
  }

  /// `Mật khẩu mới`
  String get new_password {
    return Intl.message(
      'Mật khẩu mới',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `Nhập lại mật khẩu mới`
  String get re_enter_new_password {
    return Intl.message(
      'Nhập lại mật khẩu mới',
      name: 're_enter_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Nhập lại mật khẩu`
  String get re_enter_password {
    return Intl.message(
      'Nhập lại mật khẩu',
      name: 're_enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Tối thiểu 8 ký tự`
  String get validation_password_length {
    return Intl.message(
      'Tối thiểu 8 ký tự',
      name: 'validation_password_length',
      desc: '',
      args: [],
    );
  }

  /// `Có ít nhất 1 chữ thường`
  String get validation_password_lowercase {
    return Intl.message(
      'Có ít nhất 1 chữ thường',
      name: 'validation_password_lowercase',
      desc: '',
      args: [],
    );
  }

  /// `Có ít nhất 1 chữ hoa`
  String get validation_password_uppercase {
    return Intl.message(
      'Có ít nhất 1 chữ hoa',
      name: 'validation_password_uppercase',
      desc: '',
      args: [],
    );
  }

  /// `Có ít nhất 1 ký tự số`
  String get validation_password_number {
    return Intl.message(
      'Có ít nhất 1 ký tự số',
      name: 'validation_password_number',
      desc: '',
      args: [],
    );
  }

  /// `Có ít nhất 1 ký tự đặc biệt`
  String get validation_password_special {
    return Intl.message(
      'Có ít nhất 1 ký tự đặc biệt',
      name: 'validation_password_special',
      desc: '',
      args: [],
    );
  }

  /// `Trang chủ`
  String get home {
    return Intl.message('Trang chủ', name: 'home', desc: '', args: []);
  }

  /// `Labels`
  String get labels {
    return Intl.message('Labels', name: 'labels', desc: '', args: []);
  }

  /// `Tài khoản`
  String get account {
    return Intl.message('Tài khoản', name: 'account', desc: '', args: []);
  }

  /// `Tên của bạn`
  String get your_name {
    return Intl.message('Tên của bạn', name: 'your_name', desc: '', args: []);
  }

  /// `Chức năng`
  String get options {
    return Intl.message('Chức năng', name: 'options', desc: '', args: []);
  }

  /// `Thông tin tài khoản`
  String get account_information {
    return Intl.message(
      'Thông tin tài khoản',
      name: 'account_information',
      desc: '',
      args: [],
    );
  }

  /// `Đăng xuất`
  String get log_out {
    return Intl.message('Đăng xuất', name: 'log_out', desc: '', args: []);
  }

  /// `Chú ý`
  String get attention {
    return Intl.message('Chú ý', name: 'attention', desc: '', args: []);
  }

  /// `Xác nhận đăng xuất khỏi tài khoản này?`
  String get log_out_confirm {
    return Intl.message(
      'Xác nhận đăng xuất khỏi tài khoản này?',
      name: 'log_out_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Địa chỉ`
  String get address {
    return Intl.message('Địa chỉ', name: 'address', desc: '', args: []);
  }

  /// `Thành phố`
  String get city {
    return Intl.message('Thành phố', name: 'city', desc: '', args: []);
  }

  /// `Tiểu bang`
  String get state {
    return Intl.message('Tiểu bang', name: 'state', desc: '', args: []);
  }

  /// `Zipcode`
  String get zipcode {
    return Intl.message('Zipcode', name: 'zipcode', desc: '', args: []);
  }

  /// `Quốc gia`
  String get nation {
    return Intl.message('Quốc gia', name: 'nation', desc: '', args: []);
  }

  /// `Ngày sinh`
  String get birthday {
    return Intl.message('Ngày sinh', name: 'birthday', desc: '', args: []);
  }

  /// `Giới tính`
  String get gender {
    return Intl.message('Giới tính', name: 'gender', desc: '', args: []);
  }

  /// `Nam`
  String get male {
    return Intl.message('Nam', name: 'male', desc: '', args: []);
  }

  /// `Nữ`
  String get female {
    return Intl.message('Nữ', name: 'female', desc: '', args: []);
  }

  /// `Ghi chú`
  String get note {
    return Intl.message('Ghi chú', name: 'note', desc: '', args: []);
  }

  /// `Cập nhật`
  String get update {
    return Intl.message('Cập nhật', name: 'update', desc: '', args: []);
  }

  /// `Đổi mật khẩu`
  String get change_password {
    return Intl.message(
      'Đổi mật khẩu',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Hỗ trợ`
  String get support {
    return Intl.message('Hỗ trợ', name: 'support', desc: '', args: []);
  }

  /// `Nhập tin nhắn`
  String get enter_message {
    return Intl.message(
      'Nhập tin nhắn',
      name: 'enter_message',
      desc: '',
      args: [],
    );
  }

  /// `Liên hệ`
  String get contact {
    return Intl.message('Liên hệ', name: 'contact', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<LangKey> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<LangKey> load(Locale locale) => LangKey.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
