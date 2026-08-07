import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../shell/app_shell.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameCtrl.text.trim());
      }
      // Navigate to main app on success
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${e.code}: ${e.message ?? 'Error'}'),
              duration: const Duration(seconds: 5)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), duration: const Duration(seconds: 5)),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  String _t(String en, String km) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'km' ? km : en;
  }

  @override
  Widget build(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  gradient: UrPlantTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: UrPlantTheme.primaryMedium.withValues(alpha: 0.3),
                      blurRadius: 20, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              Text('UrPlant',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: UrPlantTheme.primaryMedium, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                _t('Discover the world around you', 'រកឃើញពិភពលោកជុំវិញអ្នក'),
                style: TextStyle(fontSize: 14, color: UrPlantTheme.textTertiary, letterSpacing: 0.3),
              ),
              const SizedBox(height: 40),
              if (!_isLogin) ...[
                TextField(
                  controller: _nameCtrl, textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: _t('Display Name', 'ឈ្មោះបង្ហាញ'),
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: _t('Email', 'អ៊ីមែល'),
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passCtrl, obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: _loading ? null : (_) => _submit(),
                decoration: InputDecoration(
                  hintText: _t('Password', 'ពាក្យសម្ងាត់'),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isLogin ? _t('Log In', 'ចូល') : _t('Create Account', 'បង្កើតគណនី')),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin
                    ? _t("Don't have an account? Sign up", 'មិនទាន់មានគណនី? ចុះឈ្មោះ')
                    : _t('Already have an account? Log in', 'មានគណនីរួចហើយ? ចូល')),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}