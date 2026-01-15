import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'themes/app_themes.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const GymMasterApp());
}

class GymMasterApp extends StatelessWidget {
  const GymMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final theme = AppThemes.getTheme(provider.themeMode);
          
          // Update system UI overlay style based on theme
          SystemChrome.setSystemUIOverlayStyle(
            provider.themeMode == AppThemeMode.cleanMinimal
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
          );

          return MaterialApp(
            title: 'GymMaster',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
