import 'package:budget_pal/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'pages/login_sign_up_page.dart';

void main() {
  runApp(MyApp());
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
          scaffoldBackgroundColor: const Color(0xFFF9F9EE), // --background
          primaryColor: const Color(0xFF5D4037), // --primary
          // Color scheme
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF5D4037), // --primary
            onPrimary: const Color(0xFFFAF8F5), // --primary-foreground
            secondary: const Color(0xFFA1887F), // --secondary
            onSecondary: const Color(0xFF3E2723), // --secondary-foreground
            surface: const Color(0xFFFFFFFF), // --card
            onSurface: const Color(0xFF252525), // --foreground (approx)
            error: const Color(0xFFD4183D), // --destructive
            onError: const Color(0xFFFFFFFF), // --destructive-foreground
            outline: const Color(0xFF5D4037).withOpacity(0.2), // --border
          ),

          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF5D4037),
            foregroundColor: Color(0xFFFAF8F5),
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFFFAF8F5),
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
            ),
          ),

          // Card theme
          cardTheme: CardThemeData(
            color: const Color(0xFFFFFFFF),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ), // --radius: 0.625rem ≈ 10px
            ),
          ),

          // FloatingActionButton theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF5D4037),
            foregroundColor: Color(0xFFFAF8F5),
          ),

          // BottomNavigationBar theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFFF5F5F5), // --sidebar
            selectedItemColor: Color(0xFF5D4037), // --sidebar-primary
            unselectedItemColor: Color(0xFF6D4C41), // --muted-foreground
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),

          // ElevatedButton theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D4037),
              foregroundColor: const Color(0xFFFAF8F5),
              elevation: 2,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // TextButton theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5D4037),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF5F5F5), // --input-background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: const Color(0xFF5D4037).withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: const Color(0xFF5D4037).withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF8D6E63), // --ring
                width: 2,
              ),
            ),
          ),

          // Typography
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32.0, // ~2xl
              fontWeight: FontWeight.w500,
              color: Color(0xFF252525),
            ),
            displayMedium: TextStyle(
              fontSize: 24.0, // ~xl
              fontWeight: FontWeight.w500,
              color: Color(0xFF252525),
            ),
            displaySmall: TextStyle(
              fontSize: 20.0, // ~lg
              fontWeight: FontWeight.w500,
              color: Color(0xFF252525),
            ),
            bodyLarge: TextStyle(
              fontSize: 16.0, // base
              fontWeight: FontWeight.w400,
              color: Color(0xFF252525),
            ),
            bodyMedium: TextStyle(
              fontSize: 14.0, // ~sm
              fontWeight: FontWeight.w400,
              color: Color(0xFF252525),
            ),
            labelLarge: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF252525),
            ),
          ),

          // Divider theme
          dividerTheme: DividerThemeData(
            color: const Color(0xFF5D4037).withOpacity(0.2),
            thickness: 1,
          ),
        ),
      ),
    );
  }
}
