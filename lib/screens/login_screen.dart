import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// 2.3 implementar librería timer
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Declaramos las variables necesarias
  late TextEditingController _userPasswordController;
  bool _passwordVisible = false;
  // Cerebro de la lógica de las animaciones
  StateMachineController? controller;
  // SMI State Machine Input
  SMIBool? isCheking;
  SMIBool? isHandsUp;
  SMITrigger? trigFail;
  SMITrigger? trigSuccess;
  // 2.1 Variable de recorrido de la mirada
  SMINumber? numLook;

  // Focos email y password FocusNode paso 1.1
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  // 3.2 Crear timer para detener la animación al dejar de teclear email
  Timer? _typingDebouncer;
  // Listeners oyentes

  @override
  void initState() {
    super.initState();
    _userPasswordController = TextEditingController();
    _passwordVisible = false;
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        isHandsUp?.change(false); //manos abajo email
        // Mirada neutral al enfocar email
        numLook?.value = 50.0;
        isHandsUp?.change(false); //manos abajo email
      }
    });
    passwordFocus.addListener(() {
      isHandsUp?.change(passwordFocus.hasFocus); //manos arriba password
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consulta el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'asset/animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    // Verificar que inició bien
                    if (controller == null) return;
                    artboard.addController(controller!);
                    isCheking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                    // paso 2.3 enlazar la variable con la animación
                    numLook = controller!.findSMI('numLook');
                  }, // Qué es clamp?? en programación y en la vida
                  // clamp: abrazadera retiene el valor dentro de un rango
                ),
              ),
              const SizedBox(height: 10),
              // Campo de texto email
              TextField(
                // llamado a los oyentes
                focusNode: emailFocus,
                onChanged: (value) {
                  if (isHandsUp != null) {
                    // estoy escribiendo
                    isCheking!.change(true);
                    // ajuste de limite 0 a 100
                    // 80 es medida de calibración
                    final look =
                        (value.length / 80.0 * 100.0).clamp(0, 100).toDouble();
                    numLook?.value = look;
                    // Paso 3.3 Debounce: si vuelve a teclear, reinicia el timer
                    _typingDebouncer?.cancel(); // cancela un timer existente
                    _typingDebouncer = Timer(const Duration(seconds: 4), () {
                      if (!mounted) {
                        return; // si la pantalla se cierra
                      } 

                      // Mirada neutral al dejar de teclear email
                      isCheking?.change(false);
                    });
                  }

                  if (isCheking == null) return;
                  // Activa el modo chismoso

                  isCheking!.change(true);
                },
                textInputAction: TextInputAction.next,

                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Email',
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.mail),
                ),
              ),
              const SizedBox(height: 10),
              // Campo de texto password
              TextField(
                focusNode: passwordFocus,
                onChanged: (value) {
                  if (isCheking != null) {
                    // No tapar los ojos al escribir mail
                    //isHandsUp!.change(false);
                  }
                  if (isHandsUp == null) return;
                  // Activa el modo chismoso
                  isHandsUp!.change(true);
                },
                controller: _userPasswordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Password',
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Texto forgot password
              SizedBox(
                width: size.width,
                child: Text(
                  'Forgot password?',
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              // Botón login
              SizedBox(height: 10),
              // Botón estilo andriod, onPressed todos los botnones
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  //TO DO:
                },
                child: Text('Login', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No tienes cuenta?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Regístrate',
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
      ),
    );
  }

  @override
  void dispose() {
    _userPasswordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    _typingDebouncer?.cancel();
    super.dispose();
  }
}