import 'package:crm_david/models/current_customer.dart';
import 'package:crm_david/models/load_data.dart';
import 'package:crm_david/screens/create_ticket.dart';
import 'package:crm_david/widgets/searchable_dropdown/controller.dart';
import 'package:crm_david/widgets/searchable_dropdown/widget.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart'
    as searchable_drop_down;

class NewCustomerScreen extends StatefulWidget {
  static const routeName = "/returning";

  const NewCustomerScreen({super.key});

  @override
  State<NewCustomerScreen> createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends State<NewCustomerScreen> {
  int customerIndex = 0;
  final TextStyle labelStyle = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );

  final nameController = SearchableDropdownController();
  final emailController = SearchableDropdownController();
  final phoneNumberController = SearchableDropdownController(
    textInputType: TextInputType.number,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Returning Customer"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              "Search by Name",
              style: labelStyle,
            ),
            Consumer<CurrentCustomerModel>(
              builder: (context, customerModel, child) {
                if (customerModel.allCustomers.isEmpty) {
                  customerModel.loadCustomers();
                  return child!;
                }

                return SearchableDropdown(
                  value: customerIndex,
                  controller: nameController,
                  items: [
                    for (var customer in customerModel.allCustomers)
                      searchable_drop_down.SearchableDropdownMenuItem(
                        label: customer.name,
                        child: Text(customer.name),
                        value: customerModel.allCustomers.indexOf(customer),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      customerIndex = value!;
                      emailController.selectedItem.value =
                          emailController.items![value];
                      phoneNumberController.selectedItem.value =
                          phoneNumberController.items![value];
                    });
                  },
                  backgroundDecoration: (child) => Card(
                    margin: EdgeInsets.zero,
                    color: Colors.blueGrey[100],
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: child,
                    ),
                  ),
                );
              },
              child: const CircularProgressIndicator(),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Search by email",
              style: labelStyle,
            ),
            const SizedBox(
              height: 10,
            ),
            Consumer<CurrentCustomerModel>(
              builder: (context, customerModel, child) {
                if (customerModel.allCustomers.isEmpty) {
                  customerModel.loadCustomers();
                  return child!;
                }

                return SearchableDropdown(
                  value: customerIndex,
                  controller: emailController,
                  items: [
                    for (var customer in customerModel.allCustomers)
                      searchable_drop_down.SearchableDropdownMenuItem(
                        label: customer.email,
                        child: Text(customer.email),
                        value: customerModel.allCustomers.indexOf(customer),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      customerIndex = value!;
                      nameController.selectedItem.value =
                          nameController.items![value];
                      phoneNumberController.selectedItem.value =
                          phoneNumberController.items![value];
                    });
                  },
                  backgroundDecoration: (child) => Card(
                    margin: EdgeInsets.zero,
                    color: Colors.blueGrey[100],
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: child,
                    ),
                  ),
                );
              },
              child: const CircularProgressIndicator(),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Search by Phone Number",
              style: labelStyle,
            ),
            const SizedBox(
              height: 10,
            ),
            Consumer<CurrentCustomerModel>(
              builder: (context, customerModel, child) {
                if (customerModel.allCustomers.isEmpty) {
                  customerModel.loadCustomers();
                  return child!;
                }

                return SearchableDropdown(
                  value: customerIndex,
                  controller: phoneNumberController,
                  items: [
                    for (var customer in customerModel.allCustomers)
                      searchable_drop_down.SearchableDropdownMenuItem(
                        label: customer.getNumber(),
                        child: Text(customer.getNumber()),
                        value: customerModel.allCustomers.indexOf(customer),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      customerIndex = value!;
                      nameController.selectedItem.value =
                          nameController.items![value];
                      emailController.selectedItem.value =
                          emailController.items![value];
                    });
                  },
                  backgroundDecoration: (child) => Card(
                    margin: EdgeInsets.zero,
                    color: Colors.blueGrey[100],
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: child,
                    ),
                  ),
                );
              },
              child: const CircularProgressIndicator(),
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

                final ccModel =
                    Provider.of<CurrentCustomerModel>(context, listen: false);

                final customer = ccModel.allCustomers[customerIndex];
                // We gotem, lets change screen
                ccModel.setCustomerData(customer);
                // Load data
                // await Provider.of<LoadData>(context, listen: false).init();
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
              },
              child: Text("Search"),
            ),
          ],
        ),
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
