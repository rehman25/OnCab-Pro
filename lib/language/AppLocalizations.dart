import 'package:flutter/material.dart';
import 'package:taxi_driver/language/LanguageKo.dart';
import '../model/LanguageDataModel.dart';
import 'BaseLanguage.dart';
import 'LanguageAf.dart';
import 'LanguageAr.dart';
import 'LanguageBn.dart';
import 'LanguageDe.dart';
import 'LanguageEn.dart';
import 'LanguageEs.dart';
import 'LanguageFr.dart';
import 'LanguageHi.dart';
import 'LanguageHy.dart';
import 'LanguageId.dart';
import 'LanguageJa.dart';
import 'LanguageNl.dart';
import 'LanguagePa.dart';
import 'LanguagePt.dart';
import 'LanguageRu.dart';
import 'LanguageTa.dart';
import 'LanguageTr.dart';
import 'LanguageUr.dart';
import 'LanguageVi.dart';
import 'LanguageZh.dart';

class AppLocalizations extends LocalizationsDelegate<BaseLanguage> {
  const AppLocalizations();

  @override
  Future<BaseLanguage> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'hi':
        return LanguageHi();
      case 'ar':
        return LanguageAr();
      case 'es':
        return LanguageEs();
      case 'af':
        return LanguageAf();
      case 'fr':
        return LanguageFr();
      case 'de':
        return LanguageDe();
      case 'id':
        return LanguageId();
      case 'pt':
        return LanguagePt();
      case 'tr':
        return LanguageTr();
      case 'vi':
        return LanguageVi();
      case 'nl':
        return LanguageNl();
      case 'pa':
        return LanguagePa();
      case 'ur':
        return LanguageUr();
      case 'ta':
        return LanguageTa();
      case 'ru':
        return LanguageRu();
      case 'zh':
        return LanguageZh();
      case 'ko':
        return LanguageKo();
      case 'ja':
        return LanguageJa();
      case 'bn':
        return LanguageBn();
      case 'hy':
        return LanguageHy();
      default:
        return LanguageEn();
    }
  }

  @override
  bool isSupported(Locale locale) => LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
}
