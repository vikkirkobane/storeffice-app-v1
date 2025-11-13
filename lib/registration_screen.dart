import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/custom_otp_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  String? _errorMessage = '';
  String _selectedRole = 'Customer'; // Default role
  bool _showOtpScreen = false;
  String _email = '';
  final CustomOtpService _otpService = CustomOtpService();

  Future<void> _register() async {
    try {
      setState(() {
        _errorMessage = '';
      });
      
      // First, create the user account
      final response = await _otpService.createUserAccount(
        _emailController.text,
        _passwordController.text,
      );

      if (response.user != null) {
        // Store temporary details
        _email = _emailController.text;
        
        // Generate OTP via custom function
        await _otpService.generateOtp(_email, 'signup');
        
        // Move to OTP verification screen
        setState(() {
          _showOtpScreen = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP has been sent to your email')),
          );
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
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
      final isValid = await _otpService.verifyOtp(_email, _otpController.text, 'signup');

      if (isValid) {
        // Complete profile creation after successful OTP verification
        // The user is already created, so we just need to update their profile
        final client = Supabase.instance.client;
        final user = client.auth.currentUser;
        if (user != null) {
          await _otpService.createProfileAfterVerification(
            user.id,
            _email,
            _selectedRole,
          );
        } else {
          // If no current user, try to sign in the user after OTP verification
          try {
            await client.auth.signInWithPassword(
              email: _email,
              password: _passwordController.text,
            );
          } catch (e) {
            // If sign in fails, they might have already been automatically authenticated
            // Check if session exists
          }
        }

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
      await _otpService.generateOtp(_email, 'signup');
      
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

  @override
  Widget build(BuildContext context) {
    if (_showOtpScreen) {
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
                _email,
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
                child: const Text('Back to Registration'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: <String>['Owner', 'Merchant', 'Customer']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null && _errorMessage!.isNotEmpty)
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
