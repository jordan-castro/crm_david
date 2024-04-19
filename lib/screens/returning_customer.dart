import 'package:crm_david/models/current_customer.dart';
import 'package:crm_david/screens/create_ticket.dart';
import 'package:crm_david/screens/new_customer.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

class ReturningCustomerScreen extends StatefulWidget {
  static const routeName = "/newC";

  const ReturningCustomerScreen({super.key});

  @override
  State<ReturningCustomerScreen> createState() =>
      _ReturningCustomerScreenState();
}

class _ReturningCustomerScreenState extends State<ReturningCustomerScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Customer"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextField(
            controller: firstNameController,
            label: "What is your first name?",
            hint: "First name",
            onSubmit: () {},
            icon: Icons.person,
          ),
          CustomTextField(
            controller: lastNameController,
            label: "What is your last name?",
            hint: "Last name",
            onSubmit: () {},
            icon: Icons.person,
          ),
          CustomTextField(
            controller: mobileNumberController,
            label: "What is your phone number?",
            hint: "Phone Number",
            onSubmit: () {},
            isNumber: true,
            icon: Icons.phone,
          ),
          CustomTextField(
            controller: emailController,
            label: "What is your email?",
            hint: "Email",
            onSubmit: () {},
            icon: Icons.email,
          ),
          const SizedBox(
            height: 10,
          ),
          FilledButton(
            onPressed: () async {
              final ccModel = Provider.of<CurrentCustomerModel>(
                context,
                listen: false,
              );
              final customerData = CustomerData(
                name: "${firstNameController.text} ${lastNameController.text}",
                phone: mobileNumberController.text,
                mobile: mobileNumberController.text,
                email: emailController.text,
              );

              // Check if customer already exists
              if (await ccModel.loadFromData(customerData)) {
                showToast(
                  "Customer already exists",
                  position: ToastPosition.bottom,
                );

                Navigator.pushReplacementNamed(
                  context,
                  CreateTicketScreen.routeName,
                );
                return;
              }

              // Add to DB
              var result = await ccModel.newCustomer(customerData);

              // Meaning we got a result
              if (result) {
                await ccModel.loadCustomers();
                if (ccModel.allCustomers.isNotEmpty) {
                  ccModel.customer = ccModel.allCustomers.last;
                  Navigator.pushReplacementNamed(
                    context,
                    CreateTicketScreen.routeName,
                  );
                } else {
                  showToast(
                    "Failed to create new customer.",
                    position: ToastPosition.bottom,
                  );
                }
              }
              // showToast(
              //   "Result is $result",
              //   position: ToastPosition.bottom,
              // );
            },
            child: const Text("Insert"),
          ),
        ],
      ),
    );
  }
}
