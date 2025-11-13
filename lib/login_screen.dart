import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/custom_otp_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // For password reset
  final _otpController = TextEditingController();
  String? _errorMessage = '';
  bool _showOtpScreen = false;
  bool _showPasswordResetScreen = false; // For password reset flow
  String _emailForOtp = '';
  final CustomOtpService _otpService = CustomOtpService();

  Future<void> _login() async {
    try {
      setState(() {
        _errorMessage = '';
      });

      // For existing users, try traditional login first
      final supabaseClient = Supabase.instance.client;
      await supabaseClient.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // If successful, the AuthWrapper will handle navigation
    } on AuthException catch (e) {
      // If traditional login fails, check if it's because the user doesn't have a profile yet
      // This might indicate a first-time login scenario
      try {
        // Try to get the user session to see if the account exists
        final authResponse = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Check if the user has a profile
        final profileResult = await Supabase.instance.client
            .from('profiles')
            .select('id')
            .eq('id', authResponse.user!.id)
            .maybeSingle();

        if (profileResult == null) {
          // User exists in auth but has no profile - likely first-time login
          // For security, sign them out and use OTP for first-time verification
          await Supabase.instance.client.auth.signOut();
          
          // Generate OTP for first-time verification
          await _otpService.generateOtp(_emailController.text, 'first_login');
          
          _emailForOtp = _emailController.text;
          setState(() {
            _showOtpScreen = true;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please verify your account with the OTP sent to your email')),
            );
          }
        } else {
          // User has a profile but login failed for another reason
          setState(() {
            _errorMessage = e.message;
          });
        }
      } catch (error) {
        // If account doesn't exist at all, redirect to registration
        setState(() {
          _errorMessage = 'Account does not exist. Please register first.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _verifyOtp() async {
    try {
      setState(() {
        _errorMessage = '';
      });

      // Verify the OTP using custom function
      final isValid = await _otpService.verifyOtp(_emailForOtp, _otpController.text, 'first_login');

      if (isValid) {
        // Now try to log in again with credentials (or handle session appropriately)
        // Since OTP is verified, user should be properly authenticated
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _resendOtp() async {
    try {
      await _otpService.generateOtp(_emailForOtp, _showPasswordResetScreen ? 'password_reset' : 'first_login');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP has been resent to your email')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to resend OTP: $e';
        });
      }
    }
  }

  // Password reset with OTP flow
  Future<void> _forgotPassword() async {
    try {
      setState(() {
        _errorMessage = '';
      });

      // Generate OTP for password reset
      await _otpService.generateOtp(_emailController.text, 'password_reset');

      _emailForOtp = _emailController.text;
      setState(() {
        _showOtpScreen = true;
        _showPasswordResetScreen = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset OTP has been sent to your email')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  // Verify OTP for password reset and update password
  Future<void> _verifyOtpForPasswordReset() async {
    try {
      setState(() {
        _errorMessage = '';
      });

      // Verify the OTP using custom function
      final isValid = await _otpService.verifyOtp(_emailForOtp, _otpController.text, 'password_reset');

      if (isValid) {
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _errorMessage = 'Passwords do not match';
          });
          return;
        }

        // Update the user's password
        final supabaseClient = Supabase.instance.client;
        await supabaseClient.auth.updateUser(UserAttributes(password: _passwordController.text));

        if (!mounted) return;
        
        // Reset the UI state to show login screen
        setState(() {
          _showOtpScreen = false;
          _showPasswordResetScreen = false;
          _otpController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password has been reset successfully! Please log in with your new password.')),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  // Handle first-time login using OTP
  Future<void> _loginWithOtpOnly() async {
    try {
      setState(() {
        _errorMessage = '';
      });

      // Check if user exists in Supabase Auth
      final supabaseClient = Supabase.instance.client;
      try {
        // Try to sign in to see if the user exists
        final response = await supabaseClient.auth.signInWithPassword(
          email: _emailController.text,
          password: 'temp', // We'll use a temporary check
        );
        // If we get here, the user exists, so they shouldn't use this flow
        setState(() {
          _errorMessage = 'Account exists. Please use your password to log in.';
        });
        return;
      } catch (error) {
        // User doesn't exist in auth, so they can use the OTP flow for registration
        // Generate OTP for new user verification
        await _otpService.generateOtp(_emailController.text, 'login');

        _emailForOtp = _emailController.text;
        setState(() {
          _showOtpScreen = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP has been sent to your email')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showOtpScreen) {
      if (_showPasswordResetScreen) {
        // Password reset OTP verification screen
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reset Password'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter the OTP sent to your email',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  _emailForOtp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                    hintText: 'Enter 6-digit code',
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    hintText: 'Confirm new password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null && _errorMessage!.isNotEmpty)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyOtpForPasswordReset,
                  child: const Text('Reset Password'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text('Resend OTP'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showOtpScreen = false;
                      _showPasswordResetScreen = false;
                      _otpController.clear();
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        );
      } else {
        // Standard OTP verification screen (for first-time login)
        return Scaffold(
          appBar: AppBar(
            title: const Text('Verify OTP'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter the OTP sent to your email',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  _emailForOtp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                    hintText: 'Enter 6-digit code',
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null && _errorMessage!.isNotEmpty)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  child: const Text('Verify OTP'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text('Resend OTP'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showOtpScreen = false;
                    });
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null && _errorMessage!.isNotEmpty)
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _loginWithOtpOnly,
              child: const Text('First-time user? Login with OTP'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                if (_emailController.text.isEmpty) {
                  setState(() {
                    _errorMessage = 'Please enter your email first';
                  });
                  return;
                }
                _forgotPassword();
              },
              child: const Text('Forgot Password?'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () async {
                try {
                  setState(() {
                    _errorMessage = '';
                  });
                  
                  // Try to sign in with demo credentials
                  final response = await Supabase.instance.client.auth.signInWithPassword(
                    email: 'demo@storeffice.com',
                    password: 'DemoPassword123!',
                  );
                  
                  if (response.user != null) {
                    // Navigate to home screen after successful demo login
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  }
                } catch (e) {
                  // If direct login fails, try to create the demo user first
                  try {
                    // Attempt to create the demo user account
                    await _otpService.createUserAccount('demo@storeffice.com', 'DemoPassword123!');
                    
                    // Then sign in
                    final response = await Supabase.instance.client.auth.signInWithPassword(
                      email: 'demo@storeffice.com',
                      password: 'DemoPassword123!',
                    );
                    
                    if (response.user != null) {
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    }
                  } catch (setupError) {
                    setState(() {
                      _errorMessage = 'Demo account setup issue: $setupError';
                    });
                  }
                }
              },
              child: const Text('Continue as Demo User'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/register');
              },
              child: const Text('New user? Register'),
            ),
          ],
        ),
      ),
    );
  }
}