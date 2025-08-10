import 'package:flutter/material.dart';
import '/screens/task_screen.dart';
import '../services/auth_service.dart';
import './login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;

  // 🔹 Variables para mostrar/ocultar contraseña
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        await _authService.register(
          _nameController.text,
          _lastNameController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Registro exitoso!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TaskScreen()),
        );
      } on ServerException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withOpacity(0.9),
              primary.withOpacity(0.6),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.task_alt, size: 80, color: primary),
                      const SizedBox(height: 20),
                      Text(
                        "Registro de Usuario",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Nombres"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es obligatorio.';
                          }
                          if (value.length < 3) {
                            return 'El nombre debe tener al menos 3 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: "Apellidos",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El apellido es obligatorio.';
                          }
                          if (value.length < 3) {
                            return 'El apellido debe tener al menos 3 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El email es obligatorio.';
                          }
                          final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Por favor, ingresa un email válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // 🔹 Campo de contraseña con ojito
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es obligatoria.';
                          }
                          final passwordRegExp = RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&.*]).{8,15}$',
                          );
                          if (!passwordRegExp.hasMatch(value)) {
                            return 'La contraseña debe tener entre 8 y 15 caracteres, incluyendo mayúsculas, minúsculas, un número y un carácter especial (!@#\$%^&*).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // 🔹 Campo de confirmar contraseña con ojito
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: "Confirmar Contraseña",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirma tu contraseña.';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _register,
                              child: const Text("Registrarse"),
                            ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        child: const Text("¿Ya tienes cuenta? Inicia Sesión"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}