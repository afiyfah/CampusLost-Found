import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/report_card.dart';

/// Halaman Masuk dan Daftar dalam satu halaman (tinggal ditukar),
/// supaya tidak ada halaman yang tertinggal saat login berhasil.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showRegister = false;

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      title: showRegister ? 'Daftar Akun' : 'Masuk',
      child: showRegister
          ? _RegisterForm(
              onSwitch: () => setState(() => showRegister = false),
            )
          : _LoginForm(
              onSwitch: () => setState(() => showRegister = true),
            ),
    );
  }
}

// ---------------- Kerangka tampilan ----------------

class _AuthShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _AuthShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: campusBackground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(color: campusPurple),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'LOGO',
                          style: TextStyle(
                            color: campusPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Campus Lost & Found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Temukan barangmu, bantu temanmu',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFE8E5F2),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: campusInk,
                              ),
                            ),
                            const SizedBox(height: 18),
                            child,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: campusInk,
        ),
      ),
    );
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Widget _loadingIndicator() {
  return const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: Colors.white,
    ),
  );
}

// ---------------- Form Masuk ----------------

class _LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const _LoginForm({required this.onSwitch});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
      // Berhasil: AuthGate otomatis pindah ke dashboard.
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(context, authErrorMessage(e.code));
    } catch (_) {
      if (mounted) {
        _showError(context, 'Terjadi kesalahan. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(
      () => AuthService.signIn(
        email: _email.text,
        password: _password.text,
      ),
    );
  }

  Future<void> _guest() => _run(AuthService.signInAsGuest);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Label('Email'),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'nama@students.ac.id',
            ),
            validator: validateEmail,
          ),
          const SizedBox(height: 16),
          const _Label('Kata sandi'),
          TextFormField(
            controller: _password,
            obscureText: _hide,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _loading ? null : _login(),
            decoration: InputDecoration(
              hintText: 'Masukkan kata sandi',
              suffixIcon: IconButton(
                icon: Icon(
                  _hide
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _hide = !_hide),
              ),
            ),
            validator: validateRequiredPassword,
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? _loadingIndicator()
                : const Text(
                    'Masuk',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _loading ? null : widget.onSwitch,
            child: const Text('Belum punya akun? Daftar'),
          ),
          const Divider(height: 22),
          OutlinedButton(
            onPressed: _loading ? null : _guest,
            style: OutlinedButton.styleFrom(
              foregroundColor: campusPurple,
              side: const BorderSide(color: campusPurple),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text('Lanjutkan sebagai Tamu'),
          ),
        ],
      ),
    );
  }
}

// ---------------- Form Daftar ----------------

class _RegisterForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const _RegisterForm({required this.onSwitch});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      // Berhasil: AuthGate otomatis pindah ke dashboard.
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(context, authErrorMessage(e.code));
    } catch (_) {
      if (mounted) {
        _showError(context, 'Terjadi kesalahan. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Label('Nama lengkap'),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama lengkap',
            ),
            validator: validateName,
          ),
          const SizedBox(height: 14),
          const _Label('Email'),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'nama@students.ac.id',
            ),
            validator: validateEmail,
          ),
          const SizedBox(height: 14),
          const _Label('Kata sandi'),
          TextFormField(
            controller: _password,
            obscureText: _hide,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Buat kata sandi (min. 6 karakter)',
              suffixIcon: IconButton(
                icon: Icon(
                  _hide
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _hide = !_hide),
              ),
            ),
            validator: validateNewPassword,
          ),
          const SizedBox(height: 14),
          const _Label('Konfirmasi kata sandi'),
          TextFormField(
            controller: _confirm,
            obscureText: _hide,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _loading ? null : _register(),
            decoration: const InputDecoration(
              hintText: 'Ulangi kata sandi',
            ),
            validator: (v) =>
                validateConfirmPassword(v, _password.text),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _loading ? null : _register,
            child: _loading
                ? _loadingIndicator()
                : const Text(
                    'Daftar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _loading ? null : widget.onSwitch,
            child: const Text('Sudah punya akun? Masuk'),
          ),
        ],
      ),
    );
  }
}
