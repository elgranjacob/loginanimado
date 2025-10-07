import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPassword = false; // Para controlar la visibilidad de la contraseña

  // Cerebro de la lógica de las animaciones
  StateMachineController? controller;
  // SMI: State Machine Input
  SMIBool? isChecking; // Activa el modo "chismoso"
  SMIBool? isHandsUp; // Se tapa los ojos
  SMIBool? trigSuccess; // Se emociona
  SMIBool? trigFail; // Se pone sad

  // 1) FocusNode
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  // 2) Listeners (Oyentes/Chismoso)

  @override
  void initState() {
    super.initState();
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        // Manos abajos en email
        isHandsUp?.change(false);
      }
    });
    passFocus.addListener(() {
      // Manos arriba en password
      isHandsUp?.change(passFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consulta el tamaño de la pantalla del dispositivo
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      // Evita nudge o cámaras frontales para móviles
      body: SafeArea(
        child: Padding(
          // Eje x/horizontal/derecha izquierda
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  "asset/animated_login_character.riv",
                  // Controla las animaciones, es decir, los que estan definidos
                  stateMachines: ["Login Machine"],
                  // Al iniciarse, permite usar despues las animaciones, es como un controlador
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    // Verificar que inició bien
                    if (controller == null) return;
                    artboard.addController(controller!);
                    isChecking = controller!.findSMI("isChecking");
                    isHandsUp = controller!.findSMI("isHandsUp");
                    trigSuccess = controller!.findSMI("trigSuccess");
                    trigFail = controller!.findSMI("trigFail");
                  },
                ),
              ),
              // Espacio entre el oso y el texto emaill
              const SizedBox(height: 10),
              // Campo de texto del email
              TextField(
                // Para llamar a los oyentes, asignar el focusNode al Textfield
                focusNode: emailFocus,
                onChanged: (value) {
                  if (isHandsUp != null) {
                    // No tapar los ojos al escribir email
                    // isHandsUp!.change(false);
                  }
                  if (isChecking == null) return;
                  // Activa el modo chismoso
                  isChecking!.change(true);
                },
                // Para que aparezca @ en móviles
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    // Esquinas redondeadas
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Campo de texto de password
              const SizedBox(height: 10),
              TextField(
                focusNode: passFocus,
                onChanged: (value) {
                  if (isChecking != null) {
                    // No activar el modo chismoso al escribir el password
                    // isChecking!.change(false);
                  }
                  if (isHandsUp == null) return;
                  // Activa el modo chismoso
                  isHandsUp!.change(true);
                },
                // Para ocultar la contraseña
                obscureText: !_isPassword, // Oculta la contraseña
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    // Esquinas redondeadas
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPassword
                          ? Icons.visibility_off // Ojo abierto
                          : Icons.visibility, // Ojo cerrado
                    ),
                    onPressed: () {
                      setState(() {
                        _isPassword = !_isPassword;
                      });
                    },
                  ),
                ),
              ),
              // Texto "Olvide Contraseña"
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: const Text(
                  "Forgot your password?",
                  // Alinear a la derecha
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              // Botón de login
              const SizedBox(height: 10),
              // Botón estilo Android
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onPressed: () {},
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                  ),
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
                            // En negritas
                            fontWeight: FontWeight.bold,
                            // Subrayado
                            decoration: TextDecoration.underline,
                          ),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 4) Liberación de recursos / Limpieza de focus
  @override
  void dispose() {
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }
}