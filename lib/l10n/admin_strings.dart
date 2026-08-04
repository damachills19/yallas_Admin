import '../providers/locale_provider.dart';

/// Minimal, hand-rolled translation table for the Admin panel — scoped to
/// the login screen and the dashboard shell for now, extend as more
/// screens get translated. No package dependency (easy_localization etc.)
/// needed for this small a surface.
const Map<String, Map<AppLocale, String>> _strings = {
  'app_title': {AppLocale.en: 'Yalla Fit Admin', AppLocale.ar: 'إدارة يلا فِت'},
  'sign_in_subtitle': {AppLocale.en: 'Sign in with your admin account', AppLocale.ar: 'سجّلي الدخول بحساب المسؤول'},
  'email': {AppLocale.en: 'Email', AppLocale.ar: 'البريد الإلكتروني'},
  'password': {AppLocale.en: 'Password', AppLocale.ar: 'كلمة المرور'},
  'required': {AppLocale.en: 'Required', AppLocale.ar: 'مطلوب'},
  'access_denied': {
    AppLocale.en: 'This account does not have admin access.',
    AppLocale.ar: 'لا يملك هذا الحساب صلاحية الوصول كمسؤول.',
  },
  'sign_in': {AppLocale.en: 'Sign In', AppLocale.ar: 'تسجيل الدخول'},
  'logout': {AppLocale.en: 'Logout', AppLocale.ar: 'تسجيل الخروج'},
  'nav_dashboard': {AppLocale.en: 'Dashboard', AppLocale.ar: 'لوحة التحكم'},
  'nav_trainer_applications': {AppLocale.en: 'Trainer Applications', AppLocale.ar: 'طلبات المدربات'},
  'nav_orders': {AppLocale.en: 'Orders & Allocation', AppLocale.ar: 'الطلبات والتخصيص'},
  'nav_packages': {AppLocale.en: 'Packages', AppLocale.ar: 'الباقات'},
  'nav_programs': {AppLocale.en: 'Programs', AppLocale.ar: 'البرامج'},
  'nav_categories': {AppLocale.en: 'Categories', AppLocale.ar: 'الفئات'},
  'nav_coupons': {AppLocale.en: 'Coupons', AppLocale.ar: 'الكوبونات'},
  'nav_complaints': {AppLocale.en: 'Complaints', AppLocale.ar: 'الشكاوى'},
};

String t(AppLocale locale, String key) {
  return _strings[key]?[locale] ?? _strings[key]?[AppLocale.en] ?? key;
}
