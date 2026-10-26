import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

AppLocalizations postCardLocalizations(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  if (localizations != null) return localizations;
  return Directionality.of(context) == TextDirection.rtl
      ? AppLocalizationsAr()
      : AppLocalizationsEn();
}
