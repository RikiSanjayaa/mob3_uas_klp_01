import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_01/UI/reset_password.dart';
import 'package:mob3_uas_klp_01/components/custom_elevated_btn.dart';
import 'package:mob3_uas_klp_01/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '/backend/auth_backend.dart';
import '/components/custom_outline_btn.dart';
import '/components/custom_textform.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _isAuthenticating = false;
  String _enteredEmail = '';
  String _enteredPassword = '';
  String _enteredUsername = '';
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final credentials = await loadCredentials();
    if (credentials['email'] != '' && credentials['password'] != '') {
      setState(() {
        _emailController.text = credentials['email']!;
        _passwordController.text = credentials['password']!;
        _rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.deepPurple,
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey.shade50,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/Star.png',
              height: 500,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    child: Image.asset(
                      'assets/images/letter-p.png',
                      width: 50,
                    ),
                  ),
                  const Text(
                    "Sign in to your Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Enter your email and password to log in",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomOutlineBtn(
                                onPressed: () {
                                  signInWithGoogle(
                                    context: context,
                                    scaffoldMessenger:
                                        ScaffoldMessenger.of(context),
                                    setAuthenticating: (value) {
                                      if (mounted) {
                                        setState(() {
                                          _isAuthenticating = value;
                                        });
                                      }
                                    },
                                    updateUserProvider: () {
                                      userProvider.setUser();
                                    },
                                  );
                                },
                                leadingImageAssetsPath:
                                    'assets/images/google.png',
                                text: const Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    _isLogin
                                        ? "Or login with"
                                        : "Or Signup with",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 20),
                              CustomTextFormField(
                                controller: _emailController,
                                labelText: 'Email address',
                                keyboardType: TextInputType.emailAddress,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredEmail = value!;
                                },
                              ),
                              if (!_isLogin) const SizedBox(height: 10),
                              if (!_isLogin)
                                CustomTextFormField(
                                  controller: _usernameController,
                                  labelText: "Username",
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        value.length < 4) {
                                      return 'Username must at least be 4 characters long.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _enteredUsername = value!;
                                  },
                                ),
                              const SizedBox(height: 10),
                              CustomTextFormField(
                                controller: _passwordController,
                                labelText: "Password",
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.length < 6) {
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredPassword = value!;
                                },
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value!;
                                          });
                                        },
                                      ),
                                      const Text('Remember Me'),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const ResetPasswordScreen();
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_isAuthenticating)
                                const CircularProgressIndicator(),
                              if (!_isAuthenticating)
                                CustomElevatedBtn(
                                  onPressed: () {
                                    // validate form
                                    final isValid =
                                        _form.currentState!.validate();
                                    if (!isValid) {
                                      return;
                                    }
                                    _form.currentState!.save();
                                    // call login or register
                                    loginOrRegister(
                                        context: context,
                                        scaffoldMessenger:
                                            ScaffoldMessenger.of(context),
                                        isLogin: _isLogin,
                                        enteredEmail: _enteredEmail,
                                        enteredPassword: _enteredPassword,
                                        enteredUsername: _enteredUsername,
                                        rememberMe: _rememberMe,
                                        setAuthenticating: (value) {
                                          if (context.mounted) {
                                            setState(() {
                                              _isAuthenticating = value;
                                            });
                                          }
                                        },
                                        setIsLogin: (value) {
                                          if (context.mounted) {
                                            setState(() {
                                              _isLogin = value;
                                            });
                                          }
                                        },
                                        updateUserProvider: () {
                                          userProvider.setUser();
                                        });
                                  },
                                  child: Text(
                                    _isLogin ? 'Login' : 'Sign Up',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              if (!_isAuthenticating)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isLogin
                                          ? "Don't have an account?"
                                          : "Already have an account?",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isLogin = !_isLogin;
                                        });
                                      },
                                      child: Text(
                                        _isLogin ? 'Sign Up' : 'Login',
                                        style: const TextStyle(
                                          color: Colors.deepPurple,
                                        ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
