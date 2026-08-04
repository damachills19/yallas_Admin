import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocale { en, ar }

final adminLocaleProvider = StateProvider<AppLocale>((ref) => AppLocale.en);
