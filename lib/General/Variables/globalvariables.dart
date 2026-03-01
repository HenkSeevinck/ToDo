// ignore_for_file: prefer_const_constructors
library globalvariables;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/General/Providers/internal_app_providers.dart';

// Avoid importing `google_fonts` here so fonts aren't accessed at library
// initialization time (which can trigger AssetManifest lookups before
// `main()` config runs). Widgets should call the font function at runtime.

//------------------------------------------------------------------------
// Corporate Anchor Colors
// (Maintained for a clean, white-background UI with professional dark text)
Map<String, dynamic> anchorPair1 = {'primaryColor': const Color(0xFF1A2B44), 'secondaryColor': const Color(0xFFFFFFFF)};

//------------------------------------------------------------------------
// Corporate Utility Colors

// Pair 1: The "Success/Green" gradient from the top loop
Map<String, dynamic> utilityPair1 = {'color1': const Color(0xFF4CAF50), 'color2': const Color(0xFF8BC34A)};

// Pair 2: The "Primary/Blue" gradient from the bottom loop and speech bubble
Map<String, dynamic> utilityPair2 = {'color1': const Color(0xFF1E4D92), 'color2': const Color(0xFF42A5F5)};

// Pair 3: The "Action/Orange" accent from the center checkmark
Map<String, dynamic> utilityPair3 = {'color1': const Color(0xFFE65100), 'color2': const Color(0xFFFF9800)};

// Pair 4: The "Neutral/Slate" used in the logo text "AGENDAFLOW"
Map<String, dynamic> utilityPair4 = {'color1': const Color(0xFF263238), 'color2': const Color(0xFF546E7A)};

//------------------------------------------------------------------------
//Application Information
Map<String, dynamic> appInfo = {
  'name': 'AGENGAFLOW',
  'description': '''
TBA
''',
  'version': 0.0001,
  'applicationID': 9,
};

//------------------------------------------------------------------------
//Responsive Themes, test
class ResponsiveTheme {
  final BuildContext context;

  InternalStatusProvider get internalStatusProvider => Provider.of<InternalStatusProvider>(context, listen: false);
  String get platform => internalStatusProvider.platform;
  ResponsiveTheme(this.context);

  double get header1Size => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.width * 0.02 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? MediaQuery.of(context).size.width * 0.06 
      : MediaQuery.of(context).size.width * 0.02;

  double get header2Size => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.width * 0.01 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? MediaQuery.of(context).size.width * 0.04 
      : MediaQuery.of(context).size.width * 0.01;
  
  double get header3Size => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.width * 0.00875 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? MediaQuery.of(context).size.width * 0.03 
      : MediaQuery.of(context).size.width * 0.00875;
  
  double get bodySize => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.width * 0.00875 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? MediaQuery.of(context).size.width * 0.03 
      : MediaQuery.of(context).size.width * 0.00875;
  
  double get formInputFieldHeight => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.height * 0.0175 * 3 * 3 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? 50
      : MediaQuery.of(context).size.height * 0.0175 * 3;

  double get pageHeaderHeight => MediaQuery.of(context).size.height * 0.15;
  
  double get pageFooterHeight => MediaQuery.of(context).size.height * 0.075;

  Map<String, dynamic> get theme => {
    'anchorColors': anchorPair1, 
    'utilityColorPair1': utilityPair1, 
    'utilityColorPair2': utilityPair2, 
    'utilityColorPair3': utilityPair3, 
    'utilityColorPair4': utilityPair4, 
    'logo': 'images/Legacy-Endurance-Logo.png', 
    'font': ({TextStyle? textStyle}) => (textStyle ?? const TextStyle()).copyWith(fontFamily: 'Roboto'),
    'header1Size': header1Size, 
    'header2Size': header2Size, 
    'header3Size': header3Size,
    'formInputFieldHeight': formInputFieldHeight,
    'bodySize': bodySize, 
    'pageHeaderHeight': pageHeaderHeight, 
    'pageFooterHeight': pageFooterHeight,
    };
}
