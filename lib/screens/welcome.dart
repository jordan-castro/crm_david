import 'package:crm_david/screens/settings.dart';
import 'package:crm_david/screens/new_customer.dart';
import 'package:crm_david/screens/returning_customer.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = "/welcomeScreen";

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome!"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, ReturningCustomerScreen.routeName);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => const Color.fromARGB(255, 240, 217, 243)),
              ),
              child: const SizedBox(
                width: 250.0,
                child: Text(
                  "New Customer",
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, NewCustomerScreen.routeName);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => const Color.fromARGB(255, 240, 217, 243)),
              ),
              child: const SizedBox(
                width: 250,
                child: Text(
                  "Returning Customer",
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, DatabaseConfigScreen.routeName);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => const Color.fromARGB(255, 240, 217, 243)),
              ),
              child: const SizedBox(
                width: 250,
                child: Text(
                  "Settings",
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


