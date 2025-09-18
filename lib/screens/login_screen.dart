import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscured = true;
  //cerebro de las animaciones (state machine)
  StateMachineController? controller;
  //SMI: State Machine Input
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;

  @override
  Widget build(BuildContext context) {
    //para obtener/consultar el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          //margen interior
          child: Padding(
        //
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          children: [
            SizedBox(
                width: size.width,
                height: 200,
                child:
                    RiveAnimation.asset(
                      'asset/animated_login_character.riv',
                      stateMachines: ["Login Machine"],
                      //al iniciarse
                      onInit: (artboard){
                        controller = StateMachineController.fromArtboard(
                          artboard, 
                          "Login Machine",
                          );
                          //verificar que inicio bien
                          if (controller == null) return;
                          artboard.addController(controller!);
                          isChecking = controller!.findSMI("isChecking");
                          isHandsUp = controller!.findSMI("isHandsUp");
                          trigSuccess = controller!.findSMI("trigSuccess");
                          trigFail = controller!.findSMI("trigFail");
                      },
                    )),
            const SizedBox(height: 10),
            //campo de texto de Email
            TextField(
              onChanged: (value){
                if (isHandsUp != null){
                  //no tapar los ojos
                  isHandsUp!.change(false);
                }
                if (isChecking == null) return;
                //activa el modo chismoso
                isChecking!.change(true);
              },
              //para que aparezca @ en móviles
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: "E-Mail",
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value){
                if (isHandsUp != null){
                  //no tapar los ojos
                  isHandsUp!.change(true);
                }
                if (isChecking == null) return;
                //activa el modo chismoso
                isChecking!.change(false);
                 

              },
              //para que aparezca password en móviles
              obscureText: obscured,
              decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscured = !obscured;
                        });
                      },
                      icon: Icon(
                          obscured ? Icons.visibility : Icons.visibility_off)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: size.width,
              child: const Text(
                "Forgot password",
                textAlign: TextAlign.right,
                style: TextStyle(
                  decoration: TextDecoration.underline
                ),
              ),
            ),
            //boton de login
            SizedBox( 
              height: 10,
            ),
            MaterialButton(
              minWidth: size.width,
              height: 50,
              color: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              onPressed: (){
                //TODO
              },
              child: Text(
                "Login",
                style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Row(
                  children: [
                    const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.black,
                        //en negritas
                        fontWeight: FontWeight.bold,
                        //subrayado
                        decoration: TextDecoration.underline
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      )),
    );
  }
}
