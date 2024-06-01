import 'package:crm_david/models/app_data.dart';
import 'package:crm_david/models/current_customer.dart';
import 'package:crm_david/models/load_data.dart';
import 'package:crm_david/models/theme_model.dart';
import 'package:crm_david/screens/ask_to_print.dart';
import 'package:crm_david/screens/create_ticket.dart';
import 'package:crm_david/screens/settings.dart';
import 'package:crm_david/screens/new_customer.dart';
import 'package:crm_david/screens/print_screen.dart';
import 'package:crm_david/screens/repair.dart';
import 'package:crm_david/screens/returning_customer.dart';
import 'package:crm_david/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: const CRMDavidApp(),
    ),
  );
}

class CRMDavidApp extends StatelessWidget {
  const CRMDavidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => CurrentCustomerModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => LoadData(),
          ),
          ChangeNotifierProvider(
            create: (_) => AppData(),
          ),
        ],
        child: Consumer<ThemeModel>(builder: (context, model, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const WelcomeScreen(),
            routes: {
              WelcomeScreen.routeName: (context) => const WelcomeScreen(),
              NewCustomerScreen.routeName: (context) =>
                  const NewCustomerScreen(),
              ReturningCustomerScreen.routeName: (context) =>
                  const ReturningCustomerScreen(),
              CreateTicketScreen.routeName: (context) =>
                  const CreateTicketScreen(),
              AskToPringScreen.routeName: (context) => const AskToPringScreen(),
              RepairPartsScreen.routeName: (context) =>
                  const RepairPartsScreen(),
              PrintScreen.routeName: (context) => const PrintScreen(),
              DatabaseConfigScreen.routeName: (context) =>
                  const DatabaseConfigScreen(),
            },
            theme: model.getTheme(),
          );
        }),
      ),
    );
  }
}
