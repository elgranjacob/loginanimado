import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// 3.1 Importar librería para Timer
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPassword = false; // Para controlar la visibilidad de la contraseña
  bool _isLoading = false; // Controla el estado de carga (spinner)

  // Cerebro de la lógica de las animaciones
  StateMachineController? controller;
  // SMI: State Machine Input
  SMIBool? isChecking; // Activa el modo "chismoso"
  SMIBool? isHandsUp; // Se tapa los ojos
  SMITrigger? trigSuccess; // Se emociona
  SMITrigger? trigFail; // Se pone sad
  // 2.1 Variable para recorrido de la mirada
  SMINumber? numLook;

  // 1) FocusNode
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  // 3.2 Timer para detener la mirada al dejar de teclear
  Timer? _typingDebounce;

  //4.1 Controllers
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  //4.2 Errores para pintar en la UI
  String? emailError;
  String? passError;

  // 👇 Añadimos un timer a nivel de clase (por fuera del build)
  Timer? _hideHandsTimer;

  // Checklist dinámico para email
  List<Map<String, dynamic>> emailRules = [
    {
      'title': 'No puede estar vacío',
      'check': false,
      'validator': (String email) => email.isNotEmpty
    },
    {
      'title': 'Debe tener formato válido',
      'check': false,
      'validator': (String email) =>
          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
    },
  ];

  //Checklist dinámico para password
  List<Map<String, dynamic>> passRules = [
    {
      'title': 'Mínimo 8 caracteres',
      'check': false,
      'validator': (String pass) => pass.length >= 8
    },
    {
      'title': 'Al menos una mayúscula',
      'check': false,
      'validator': (String pass) => RegExp(r'[A-Z]').hasMatch(pass)
    },
    {
      'title': 'Al menos una minúscula',
      'check': false,
      'validator': (String pass) => RegExp(r'[a-z]').hasMatch(pass)
    },
    {
      'title': 'Al menos un dígito',
      'check': false,
      'validator': (String pass) => RegExp(r'\d').hasMatch(pass)
    },
    {
      'title': 'Al menos un caracter especial',
      'check': false,
      'validator': (String pass) => RegExp(r'[^A-Za-z0-9]').hasMatch(pass)
    },
  ];

  //4.3 Validadores individuales
  bool isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  bool isValidPassword(String pass) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$')
        .hasMatch(pass);
  }

  // Validación dinámica del checklist email
  void validateEmail(String value) {
    String? firstError;
    for (var rule in emailRules) {
      rule['check'] = rule['validator'](value);
      if (!rule['check'] && firstError == null) {
        firstError = rule['title'] == 'Debe tener formato válido'
            ? 'Email inválido'
            : rule['title'];
      }
    }

    setState(() {
      emailError = firstError;
    });
  }

  // Validación dinámica del checklist password
  void validatePassword(String value) {
    String? firstError;
    for (var rule in passRules) {
      rule['check'] = rule['validator'](value);
      if (!rule['check'] && firstError == null) {
        firstError = rule['title'];
      }
    }

    setState(() {
      passError = firstError;
    });
  }

  // 🔹 Método acción al botón
  Future<void> _onLogin() async {
    // Evita múltiples clics
    if (_isLoading) return;

    // Quitar foco, bajar manos y detener checking
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    isChecking?.change(false);
    isHandsUp?.change(false);
    numLook?.value = 50.0; // mirada neutra

    // Mostrar el spinner
    setState(() => _isLoading = true);

    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    // Validar checklist
    validateEmail(email);
    validatePassword(pass);

    // Simula un envío
    await Future.delayed(const Duration(seconds: 1));

    // ✅ Disparar trigger en el primer tap (corregido)
    if (emailError == null && passError == null) {
      trigSuccess?.fire(); // Éxito
    } else {
      trigFail?.fire(); // Falla
    }

    // Ocultar spinner después del proceso
    setState(() => _isLoading = false);
  }

  // 2) Listeners (Oyentes/Chismoso)
  @override
  void initState() {
    super.initState();

    // Escucha los cambios de foco en email
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        // Manos abajo en email
        isHandsUp?.change(false);
        // 2.2 Mirada neutral al enfocar email
        numLook?.value = 50.0;
      }
    });

    // Escucha los cambios de foco en password
    passFocus.addListener(() {
      // Manos arriba en password
      isHandsUp?.change(passFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: size.width,
                      height: 200,
                      child: RiveAnimation.asset(
                        "asset/animated_login_character.riv",
                        stateMachines: ["Login Machine"],
                        onInit: (artboard) {
                          controller = StateMachineController.fromArtboard(
                            artboard,
                            "Login Machine",
                          );
                          if (controller == null) return;
                          artboard.addController(controller!);
                          isChecking = controller!.findSMI("isChecking");
                          isHandsUp = controller!.findSMI("isHandsUp");
                          trigSuccess = controller!.findSMI("trigSuccess");
                          trigFail = controller!.findSMI("trigFail");
                          numLook = controller!.findSMI("numLook");
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Campo de texto del email
                    TextField(
                      focusNode: emailFocus,
                      controller: emailCtrl,
                      onChanged: (value) {
                        validateEmail(value);

                        if (isChecking != null) {
                          isChecking!.change(true);

                          final look =
                              (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                          numLook?.value = look;

                          _typingDebounce?.cancel();
                          _typingDebounce =
                              Timer(const Duration(seconds: 2), () {
                            if (!mounted) return;
                            isChecking?.change(false);
                          });
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        errorText: emailError,
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.mail),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    // Checklist dinámico email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: emailRules.map((rule) {
                        return Row(
                          children: [
                            Icon(
                              rule['check']
                                  ? Icons.check_circle
                                  : Icons.cancel_outlined,
                              color: rule['check']
                                  ? Colors.green
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(rule['title']),
                          ],
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    // Campo de texto de password
                    TextField(
                      focusNode: passFocus,
                      controller: passCtrl,
                      obscureText: !_isPassword,
                      onChanged: (value) {
                        validatePassword(value);

                        isHandsUp?.change(true);

                        _hideHandsTimer?.cancel();
                        _hideHandsTimer = Timer(const Duration(seconds: 2), () {
                          isHandsUp?.change(false);
                        });
                      },
                      decoration: InputDecoration(
                        errorText: passError,
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(_isPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isPassword = !_isPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    // Checklist dinámico password
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: passRules.map((rule) {
                        return Row(
                          children: [
                            Icon(
                              rule['check']
                                  ? Icons.check_circle
                                  : Icons.cancel_outlined,
                              color: rule['check']
                                  ? Colors.green
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(rule['title']),
                          ],
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      width: size.width,
                      child: const Text(
                        "Forgot your password?",
                        textAlign: TextAlign.right,
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: 10),
                    MaterialButton(
                      minWidth: size.width,
                      height: 50,
                      color: Colors.purple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onPressed: _isLoading ? null : _onLogin,
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Loader Circular
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 4) Liberación de recursos / Limpieza de focus
  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    _typingDebounce?.cancel();
    _hideHandsTimer?.cancel();
    super.dispose();
  }
}
