import 'package:flutter/material.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import '../../main.dart';
import '../model/LanguageDataModel.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/app_common.dart';

class LanguageScreen extends StatefulWidget {
  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.language, style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Wrap(
          runSpacing: 12,
          spacing: 12,
          children: List.generate(localeLanguageList.length, (index) {
            LanguageDataModel data = localeLanguageList[index];
            return inkWellWidget(
              onTap: () async {
                await sharedPref.setString(SELECTED_LANGUAGE_CODE, data.languageCode!);
                selectedLanguageDataModel = data;
                appStore.setLanguage(data.languageCode!, context: context);
                setState(() {});
                LiveStream().emit(CHANGE_LANGUAGE);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: dividerColor),
                    color: (sharedPref.getString(SELECTED_LANGUAGE_CODE) ?? defaultLanguage) == data.languageCode ? primaryColor.withOpacity(0.6) : Colors.transparent,
                    borderRadius: radius(defaultRadius)),
                width: (MediaQuery.of(context).size.width - 44) / 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(borderRadius: radius(8), child: Image.asset(data.flag.validate(), width: 32, height: 32)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data.name.validate()}',
                              style: boldTextStyle(color: (sharedPref.getString(SELECTED_LANGUAGE_CODE) ?? defaultLanguage) == data.languageCode ? Colors.white : textPrimaryColorGlobal)),
                          Text('${data.subTitle.validate()}',
                              style: secondaryTextStyle(color: (sharedPref.getString(SELECTED_LANGUAGE_CODE) ?? defaultLanguage) == data.languageCode ? Colors.white : textSecondaryColorGlobal)),
                        ],
                      ),
                    ),
                    if ((sharedPref.getString(SELECTED_LANGUAGE_CODE) ?? defaultLanguage) == data.languageCode) Icon(Icons.check_circle, color: Colors.white),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
