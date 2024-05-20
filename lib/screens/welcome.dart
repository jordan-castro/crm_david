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


