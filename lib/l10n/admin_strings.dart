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

  // Dashboard
  'stat_pending_applications': {AppLocale.en: 'Pending Applications', AppLocale.ar: 'الطلبات قيد الانتظار'},
  'stat_open_complaints': {AppLocale.en: 'Open Complaints', AppLocale.ar: 'الشكاوى المفتوحة'},
  'stat_total_packages': {AppLocale.en: 'Total Packages', AppLocale.ar: 'إجمالي الباقات'},
  'stat_total_programs': {AppLocale.en: 'Total Programs', AppLocale.ar: 'إجمالي البرامج'},
  'chart_user_growth': {AppLocale.en: 'User Growth (last 6 months)', AppLocale.ar: 'نمو المستخدمين (آخر 6 أشهر)'},
  'chart_applications_by_status': {AppLocale.en: 'Trainer Applications by Status', AppLocale.ar: 'طلبات المدربات حسب الحالة'},
  'legend_users': {AppLocale.en: 'Users', AppLocale.ar: 'المستخدمون'},
  'legend_trainers': {AppLocale.en: 'Trainers', AppLocale.ar: 'المدربات'},
  'legend_pending': {AppLocale.en: 'Pending', AppLocale.ar: 'قيد الانتظار'},
  'legend_approved': {AppLocale.en: 'Approved', AppLocale.ar: 'مقبول'},
  'legend_rejected': {AppLocale.en: 'Rejected', AppLocale.ar: 'مرفوض'},
  'no_signups_yet': {AppLocale.en: 'No signups yet', AppLocale.ar: 'لا يوجد تسجيلات بعد'},
  'no_applications_yet': {AppLocale.en: 'No trainer applications yet', AppLocale.ar: 'لا توجد طلبات مدربات بعد'},

  // Common actions
  'cancel': {AppLocale.en: 'Cancel', AppLocale.ar: 'إلغاء'},
  'confirm': {AppLocale.en: 'Confirm', AppLocale.ar: 'تأكيد'},
  'close': {AppLocale.en: 'Close', AppLocale.ar: 'إغلاق'},
  'save': {AppLocale.en: 'Save', AppLocale.ar: 'حفظ'},
  'required_field': {AppLocale.en: 'Required', AppLocale.ar: 'مطلوب'},
  'approve': {AppLocale.en: 'Approve', AppLocale.ar: 'قبول'},
  'reject': {AppLocale.en: 'Reject', AppLocale.ar: 'رفض'},

  // Trainer applications
  'filter_pending': {AppLocale.en: 'Pending', AppLocale.ar: 'قيد الانتظار'},
  'filter_approved': {AppLocale.en: 'Approved', AppLocale.ar: 'مقبول'},
  'filter_rejected': {AppLocale.en: 'Rejected', AppLocale.ar: 'مرفوض'},
  'no_applications_found': {AppLocale.en: 'No applications found', AppLocale.ar: 'لا توجد طلبات'},
  'reject_application_title': {AppLocale.en: 'Reject application?', AppLocale.ar: 'رفض الطلب؟'},
  'reject_application_body': {
    AppLocale.en: 'This will mark the trainer application as rejected.',
    AppLocale.ar: 'سيؤدي هذا إلى تصنيف طلب المدربة كمرفوض.',
  },
  'document_link': {AppLocale.en: 'Document link', AppLocale.ar: 'رابط المستند'},
  'id_front': {AppLocale.en: 'ID Front', AppLocale.ar: 'الهوية (الوجه الأمامي)'},
  'id_back': {AppLocale.en: 'ID Back', AppLocale.ar: 'الهوية (الوجه الخلفي)'},
  'certificate_n': {AppLocale.en: 'Certificate', AppLocale.ar: 'شهادة'},
  'years_experience': {AppLocale.en: 'years experience', AppLocale.ar: 'سنوات خبرة'},
  'status_pending': {AppLocale.en: 'Pending', AppLocale.ar: 'قيد الانتظار'},
  'status_approved': {AppLocale.en: 'Approved', AppLocale.ar: 'مقبول'},
  'status_rejected': {AppLocale.en: 'Rejected', AppLocale.ar: 'مرفوض'},

  // Orders
  'view_unassigned': {AppLocale.en: 'Unassigned', AppLocale.ar: 'غير مُخصص'},
  'view_all_paid': {AppLocale.en: 'All Paid Orders', AppLocale.ar: 'جميع الطلبات المدفوعة'},
  'view_cash_orders': {AppLocale.en: 'Cash Orders (unpaid)', AppLocale.ar: 'الطلبات النقدية (غير مدفوعة)'},
  'view_bank_transfers': {AppLocale.en: 'Bank Transfers (pending)', AppLocale.ar: 'التحويلات البنكية (قيد المراجعة)'},
  'no_pending_bank_transfers': {AppLocale.en: 'No pending bank transfers', AppLocale.ar: 'لا توجد تحويلات بنكية قيد المراجعة'},
  'no_unpaid_cash_orders': {AppLocale.en: 'No unpaid cash orders', AppLocale.ar: 'لا توجد طلبات نقدية غير مدفوعة'},
  'no_paid_orders_found': {AppLocale.en: 'No paid orders found', AppLocale.ar: 'لا توجد طلبات مدفوعة'},
  'transfer_slip_link': {AppLocale.en: 'Transfer slip link', AppLocale.ar: 'رابط إيصال التحويل'},
  'view_transfer_slip': {AppLocale.en: 'View Transfer Slip', AppLocale.ar: 'عرض إيصال التحويل'},
  'mark_as_paid': {AppLocale.en: 'Mark as Paid', AppLocale.ar: 'تعليم كمدفوع'},
  'assigned_to': {AppLocale.en: 'Assigned to', AppLocale.ar: 'مُخصص لـ'},
  'no_trainers_linked': {
    AppLocale.en: 'No trainers with a linked account yet',
    AppLocale.ar: 'لا توجد مدربات لديهن حساب مرتبط بعد',
  },
  'select_trainer': {AppLocale.en: 'Select trainer', AppLocale.ar: 'اختر مدربة'},
  'clients_suffix': {AppLocale.en: 'clients', AppLocale.ar: 'عميلة'},
  'assign': {AppLocale.en: 'Assign', AppLocale.ar: 'تخصيص'},

  // Packages
  'add_package': {AppLocale.en: 'Add Package', AppLocale.ar: 'إضافة باقة'},
  'edit_package': {AppLocale.en: 'Edit Package', AppLocale.ar: 'تعديل الباقة'},
  'no_packages_yet': {AppLocale.en: 'No packages yet', AppLocale.ar: 'لا توجد باقات بعد'},
  'delete_package_title': {AppLocale.en: 'Delete this package?', AppLocale.ar: 'حذف هذه الباقة؟'},
  'sessions_suffix': {AppLocale.en: 'sessions', AppLocale.ar: 'جلسات'},
  'field_name': {AppLocale.en: 'Name', AppLocale.ar: 'الاسم'},
  'field_description': {AppLocale.en: 'Description', AppLocale.ar: 'الوصف'},
  'field_price': {AppLocale.en: 'Price', AppLocale.ar: 'السعر'},
  'field_original_price': {AppLocale.en: 'Original Price (optional)', AppLocale.ar: 'السعر الأصلي (اختياري)'},
  'field_sessions_count': {AppLocale.en: 'Sessions Count', AppLocale.ar: 'عدد الجلسات'},
  'field_category': {AppLocale.en: 'Category', AppLocale.ar: 'الفئة'},
  'field_customizable': {AppLocale.en: 'Customizable', AppLocale.ar: 'قابلة للتخصيص'},
  'field_included_item': {AppLocale.en: 'Included item', AppLocale.ar: 'عنصر مشمول'},

  // Programs
  'add_program': {AppLocale.en: 'Add Program', AppLocale.ar: 'إضافة برنامج'},
  'edit_program': {AppLocale.en: 'Edit Program', AppLocale.ar: 'تعديل البرنامج'},
  'no_programs_yet': {AppLocale.en: 'No programs yet', AppLocale.ar: 'لا توجد برامج بعد'},
  'delete_program_title': {AppLocale.en: 'Delete this program?', AppLocale.ar: 'حذف هذا البرنامج؟'},
  'field_subtitle': {AppLocale.en: 'Subtitle', AppLocale.ar: 'العنوان الفرعي'},
  'field_price_from': {AppLocale.en: 'Price From', AppLocale.ar: 'يبدأ السعر من'},
  'field_duration_weeks': {AppLocale.en: 'Duration (weeks)', AppLocale.ar: 'المدة (أسابيع)'},
  'field_level': {AppLocale.en: 'Level', AppLocale.ar: 'المستوى'},
  'level_beginner': {AppLocale.en: 'Beginner', AppLocale.ar: 'مبتدئ'},
  'level_intermediate': {AppLocale.en: 'Intermediate', AppLocale.ar: 'متوسط'},
  'level_advanced': {AppLocale.en: 'Advanced', AppLocale.ar: 'متقدم'},

  // Categories
  'add_category': {AppLocale.en: 'Add Category', AppLocale.ar: 'إضافة فئة'},
  'edit_category': {AppLocale.en: 'Edit Category', AppLocale.ar: 'تعديل الفئة'},
  'no_categories_yet': {AppLocale.en: 'No categories yet', AppLocale.ar: 'لا توجد فئات بعد'},
  'delete_category_title': {AppLocale.en: 'Delete this category?', AppLocale.ar: 'حذف هذه الفئة؟'},
  'field_icon_seed': {AppLocale.en: 'Icon Seed', AppLocale.ar: 'رمز الأيقونة'},

  // Coupons
  'add_coupon': {AppLocale.en: 'Add Coupon', AppLocale.ar: 'إضافة كوبون'},
  'no_coupons_yet': {AppLocale.en: 'No coupons yet', AppLocale.ar: 'لا توجد كوبونات بعد'},
  'delete_coupon_title': {AppLocale.en: 'Delete this coupon?', AppLocale.ar: 'حذف هذا الكوبون؟'},
  'field_code': {AppLocale.en: 'Code', AppLocale.ar: 'الرمز'},
  'field_discount_percent': {AppLocale.en: 'Discount %', AppLocale.ar: 'نسبة الخصم %'},
  'field_active': {AppLocale.en: 'Active', AppLocale.ar: 'مفعّل'},

  // Complaints
  'filter_all': {AppLocale.en: 'All', AppLocale.ar: 'الكل'},
  'filter_open': {AppLocale.en: 'Open', AppLocale.ar: 'مفتوحة'},
  'filter_in_progress': {AppLocale.en: 'In Progress', AppLocale.ar: 'قيد المعالجة'},
  'filter_resolved': {AppLocale.en: 'Resolved', AppLocale.ar: 'تم الحل'},
  'filter_closed': {AppLocale.en: 'Closed', AppLocale.ar: 'مغلقة'},
  'no_complaints_found': {AppLocale.en: 'No complaints found', AppLocale.ar: 'لا توجد شكاوى'},
  'no_subject': {AppLocale.en: '(no subject)', AppLocale.ar: '(بدون موضوع)'},
  'admin_response': {AppLocale.en: 'Admin response', AppLocale.ar: 'رد الإدارة'},
  'send_response': {AppLocale.en: 'Send Response', AppLocale.ar: 'إرسال الرد'},
  'complaint_status_open': {AppLocale.en: 'Open', AppLocale.ar: 'مفتوحة'},
  'complaint_status_in_progress': {AppLocale.en: 'In Progress', AppLocale.ar: 'قيد المعالجة'},
  'complaint_status_resolved': {AppLocale.en: 'Resolved', AppLocale.ar: 'تم الحل'},
  'complaint_status_closed': {AppLocale.en: 'Closed', AppLocale.ar: 'مغلقة'},

  // Notification bell
  'pending_actions': {AppLocale.en: 'Pending Actions', AppLocale.ar: 'الإجراءات المعلّقة'},
  'pending_actions_tooltip': {AppLocale.en: 'Pending actions', AppLocale.ar: 'الإجراءات المعلّقة'},
  'trainer_applications_pending': {
    AppLocale.en: 'trainer application(s) pending',
    AppLocale.ar: 'طلب/طلبات مدربات قيد الانتظار',
  },
  'bank_transfers_pending_review': {
    AppLocale.en: 'bank transfer(s) pending review',
    AppLocale.ar: 'تحويل/تحويلات بنكية قيد المراجعة',
  },
  'nothing_pending': {AppLocale.en: 'Nothing pending. All caught up!', AppLocale.ar: 'لا يوجد شيء معلّق. كل شيء محدّث!'},
};

String t(AppLocale locale, String key) {
  return _strings[key]?[locale] ?? _strings[key]?[AppLocale.en] ?? key;
}
