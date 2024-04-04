import 'package:crm_david/models/current_customer.dart';
import 'package:crm_david/models/load_data.dart';
import 'package:crm_david/screens/create_ticket.dart';
import 'package:crm_david/utils/server_db.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

class NewCustomerScreen extends StatefulWidget {
  static const routeName = "/returning";

  const NewCustomerScreen({super.key});

  @override
  State<NewCustomerScreen> createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends State<NewCustomerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Returning Customer"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextField(
            controller: nameController,
            label: "What is your name?",
            hint: "Name",
            onSubmit: () {},
            icon: Icons.person,
          ),
          CustomTextField(
            controller: numberController,
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
              showToast(
                "Searching MySQL DB...",
                position: ToastPosition.bottom,
              );

              var result = await Provider.of<CurrentCustomerModel>(
                context,
                listen: false,
              ).loadFromData(
                CustomerData(
                  name: nameController.text,
                  number: numberController.text,
                  email: emailController.text,
                ),
              );

              print(result);

              // We gotem, lets change screen
              if (result) {
                // Load data
                await Provider.of<LoadData>(context, listen: false).init();
                Provider.of<LoadData>(
                  context,
                  listen: false,
                ).loadManufactures();
                Provider.of<LoadData>(
                  context,
                  listen: false,
                ).loadModels();
                Provider.of<LoadData>(
                  context,
                  listen: false,
                ).loadTechnicians();

                Navigator.pushNamed(
                  context,
                  CreateTicketScreen.routeName,
                );
              }
            },
            child: Text("Search"),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onSubmit;
  final bool? isNumber;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final Function(String)? onChange;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onSubmit,
    this.isNumber = false,
    this.icon,
    this.padding,
    this.onChange,
  });

  @override
  State<CustomTextField> createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding != null
          ? widget.padding!
          : const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
      child: TextField(
        controller: widget.controller,
        onChanged: (value) {
          if (widget.isNumber ?? false) {
            if (int.tryParse(value) != null) {
              widget.controller.text = value;
              widget.onChange?.call(value);
              return;
            }
          } else if (widget.isNumber == false) {
            widget.onChange?.call(value);
          }
        },
        decoration: InputDecoration(
          label: Text(widget.label),
          hintText: widget.hint,
          icon: widget.icon != null ? Icon(widget.icon) : null,
        ),
        keyboardType: (widget.isNumber ?? false) ? TextInputType.number : null,
      ),
    );
  }
}
