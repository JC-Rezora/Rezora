import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);

    try {
      final supabase = Supabase.instance.client;

      final email = _emailCtrl.text.trim();
      final pass = _passCtrl.text.trim();
      final fullName = _nameCtrl.text.trim();

      final res = await supabase.auth.signUp(
        email: email,
        password: pass,
      );

      final user = res.user;

      if (user == null) {
        throw Exception('Не удалось создать пользователя (user == null).');
      }

      // Если у тебя уже стоит триггер handle_new_user, то запись в profiles уже создаётся автоматически.
      // Тогда мы просто ОБНОВЛЯЕМ профиль (upsert), чтобы добавить full_name.
      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': email,
        'full_name': fullName.isEmpty ? null : fullName,
        'role': 'user', // поменяешь потом, если нужно
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аккаунт создан!')),
      );

      Navigator.pop(context); // возвращаемся на страницу логина
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать аккаунт')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Имя (необязательно)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Введите email';
                    if (!s.contains('@')) return 'Некорректный email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.length < 6) return 'Минимум 6 символов';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Создать аккаунт'),
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