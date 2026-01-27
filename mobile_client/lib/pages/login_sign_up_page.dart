import 'package:flutter/material.dart';
import '../widgets/login_widget.dart';
import '../widgets/signup_widget.dart';
import '../widgets/login_signup_toggle_widget.dart';
import '../util/https_methods.dart';
import 'home_page.dart';
import 'main_page.dart';

class LoginSignUpPage extends StatefulWidget {
  const LoginSignUpPage({super.key});

  @override
  State<LoginSignUpPage> createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  bool isLogin = true;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo and Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Budget Pal",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Login/Signup Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Header
                        Text(
                          "Welcome",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Manage your finances with ease",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Login/Sign Up Toggle
                        LoginSignUpToggle(
                          isLogin: isLogin,
                          onToggle: (bool loginSelected) {
                            setState(() {
                              isLogin = loginSelected;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login
                        if (isLogin == true)
                          LoginWidget(
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),

                        if (isLogin == false)
                          SignUpWidget(
                            firstNameController: _firstNameController,
                            lastNameController: _lastNameController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),

                        // Sign Up

                        // Login/Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              bool success = isLogin
                                  ? await HttpsMethods().loginUser(
                                      _emailController.text,
                                      _passwordController.text,
                                      context,
                                    )
                                  : await HttpsMethods().signUpUser(
                                      _firstNameController.text,
                                      _lastNameController.text,
                                      _emailController.text,
                                      _passwordController.text,
                                      context,
                                    );
                              if (success) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainPage(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Login failed. Please try again.',
                                    ),
                                  ),
                                );
                              }
                              // Add your authentication logic here
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              isLogin ? "Login" : "Sign Up",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
