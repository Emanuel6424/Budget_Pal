import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'pages/login_sign_up.dart';

void main() {
  runApp(MyApp());
}

/// Single source of truth for the app's light-brown palette.
/// Change a value here to re-skin the whole app.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF9F9EE); // --background
  static const Color surface = Color(0xFFFFFFFF); // --card
  static const Color primary = Color(0xFF5D4037); // --primary
  static const Color onPrimary = Color(0xFFFAF8F5); // --primary-foreground
  static const Color secondary = Color(0xFFA1887F); // --secondary
  static const Color onSecondary = Color(0xFF3E2723); // --secondary-foreground
  static const Color ring = Color(0xFF8D6E63); // --ring (focus outline)
  static const Color border = Color(0x335D4037); // primary @ 20% opacity
  static const Color inputBackground = Color(0xFFF5F5F5); // --input-background
  static const Color sidebarBackground = Color(0xFFF5F5F5); // --sidebar

  static const Color textPrimary = Color(0xFF252525); // --foreground
  static const Color textSecondary = Color(0xFF6D4C41); // --muted-foreground
  static const Color textMuted = Color(0xFF9B8275);

  static const Color success = Color(0xFF2E7D32);
  static const Color successBackground = Color(0xFFE3EFE4);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningBackground = Color(0xFFF4ECDD);
  static const Color danger = Color(0xFFC0392B); // --destructive
  static const Color dangerBackground = Color(0xFFF3E5E1);

  // Soft, palette-matched tints used for account-type and category badges.
  static const Map<String, Color> accountTypeTints = {
    "Checking": Color(0xFFEFE6D8),
    "Savings": Color(0xFFE3EFE4),
    "Retirement": Color(0xFFE6E1DC),
    "Credit Card": Color(0xFFF4ECDD),
  };
  static const Color categoryTint = Color(0xFFEFEBE6);

  // Gradient used behind hero/summary cards (balance, stat tiles).
  static const Color heroGradientStart = Color(0xFF6D4C41);
  static const Color heroGradientEnd = Color(0xFF4E342E);
}

/// Shared corner radii so rounding stays consistent across cards,
/// dialogs, inputs, and pill-shaped controls.
class AppRadius {
  AppRadius._();

  static const double input = 10.0;
  static const double card = 16.0;
  static const double dialog = 16.0;
  static const double pill = 30.0;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: "BudgetPal",
        debugShowCheckedModeBanner: false,
        // home: LoginSignUpPage(),
        home: LoginSignUpPage(),
        theme: ThemeData(
          // Base colors
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          // Color scheme
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            secondary: AppColors.secondary,
            onSecondary: AppColors.onSecondary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            error: AppColors.danger,
            onError: AppColors.onPrimary,
            outline: AppColors.border,
          ),

          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 26.0,
            ),
          ),

          // Card theme
          cardTheme: CardThemeData(
            color: AppColors.surface,
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),

          // Dialog theme (keeps AlertDialog and Dialog shapes consistent)
          dialogTheme: DialogThemeData(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.dialog),
            ),
          ),

          // FloatingActionButton theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),

          // BottomNavigationBar theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.sidebarBackground,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),

          // ElevatedButton theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 2,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
            ),
          ),

          // TextButton theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.ring, width: 2),
            ),
          ),

          // Typography — every reusable text style used across the app
          // lives here. Update a size/weight/color once and it applies
          // everywhere that style is referenced.
          textTheme: const TextTheme(
            // Page titles, e.g. "Accounts", "Transactions", "Budgets"
            headlineMedium: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            displayLarge: TextStyle(
              fontSize: 32.0, // ~2xl
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            displayMedium: TextStyle(
              fontSize: 24.0, // ~xl
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            displaySmall: TextStyle(
              fontSize: 20.0, // ~lg
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            // Card titles & section headers, e.g. account name, "Recent
            // Transactions"
            titleMedium: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            // Prominent amounts, e.g. account balances
            titleLarge: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            bodyLarge: TextStyle(
              fontSize: 16.0, // base
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            bodyMedium: TextStyle(
              fontSize: 14.0, // ~sm
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            // Secondary/caption text, e.g. dates, muted helper copy
            bodySmall: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            labelLarge: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            // Field labels, e.g. "Account Name"
            labelMedium: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            // Uppercase eyebrow labels, e.g. "MERCHANT", "CATEGORY"
            labelSmall: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),

          // Divider theme
          dividerTheme: const DividerThemeData(
            color: AppColors.border,
            thickness: 1,
          ),
        ),
      ),
    );
  }
}
