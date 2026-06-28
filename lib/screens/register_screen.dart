import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Empty Email
    if (email.isEmpty) {
      showErrorDialog(
        title: "Email Required",
        message: "Please enter your email address.",
      );
      return;
    }

    // Email Format
    if (!email.contains("@") || !email.contains(".")) {
      showErrorDialog(
        title: "Invalid Email",
        message: "Please enter a valid email address.",
      );
      return;
    }

    // Empty Password
    if (password.isEmpty) {
      showErrorDialog(
        title: "Password Required",
        message: "Please enter your password.",
      );
      return;
    }

    // Password Length
    if (password.length < 6) {
      showErrorDialog(
        title: "Weak Password",
        message: "Password must contain at least 6 characters.",
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.register(email, password);

      if (!mounted) return;

      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      switch (e.code) {
        case "email-already-in-use":
          showErrorDialog(
            title: "Email Already Registered",
            message:
                "This email has already been registered.\nPlease login instead.",
          );
          break;

        case "weak-password":
          showErrorDialog(
            title: "Weak Password",
            message:
                "Please use a stronger password with at least 6 characters.",
          );
          break;

        case "invalid-email":
          showErrorDialog(
            title: "Invalid Email",
            message: "Please enter a valid email address.",
          );
          break;

        default:
          showErrorDialog(
            title: "Registration Failed",
            message: e.message ?? "Something went wrong.",
          );
      }
    } catch (_) {
      if (!mounted) return;

      showErrorDialog(
        title: "Oops!",
        message: "Something went wrong.\nPlease try again.",
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  // ==========================
  // ERROR DIALOG
  // ==========================

  void showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xffFFE5E5),
                child: Icon(Icons.close_rounded, color: Colors.red, size: 42),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3A8DFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // SUCCESS DIALOG
  // ==========================

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xffE8F8EA),
                child: Icon(Icons.check_circle, color: Colors.green, size: 45),
              ),

              const SizedBox(height: 20),

              const Text(
                "Registration Successful!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                "Your account has been created successfully.\nYou can now login.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3A8DFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to Login
                  },
                  child: const Text(
                    "Go to Login",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Create Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Card(
            elevation: 8,
            shadowColor: Colors.black12,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),

            child: Padding(
              padding: const EdgeInsets.all(25),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Center(
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 70,
                      color: Color(0xff3A8DFF),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      "Register to start managing your tasks.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,

                    decoration: InputDecoration(
                      hintText: "Enter your email",

                      prefixIcon: const Icon(Icons.email_outlined),

                      filled: true,
                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,

                    decoration: InputDecoration(
                      hintText: "Enter your password",

                      prefixIcon: const Icon(Icons.lock_outline),

                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),

                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),

                      filled: true,
                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3A8DFF),
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text("Already have an account?"),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        child: const Text(
                          "Login",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
