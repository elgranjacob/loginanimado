import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
   bool obscured = true;
  @override
  Widget build(BuildContext context) {
    //para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        //margen interior
          child: Padding(
            //
        padding: const EdgeInsets.symmetric(horizontal: 20,),
        child: Column(
          children: [
            SizedBox(
                width: size.width,
                height: 200,
                child:
                    RiveAnimation.asset('asset/animated_login_character.riv')),
            const SizedBox(height: 10),
            //campo de texto de Email
            TextField(
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
              //para que aparezca password en móviles
              obscureText: obscured,
              decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscured = !obscured;
                        
                        
                      }
                      );
                    },
                    icon: Icon(
                      
                      obscured ? Icons.visibility : Icons.visibility_off
                    )
                    ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
              
            )
          ],
        ),
      )),
    );
  }
}
