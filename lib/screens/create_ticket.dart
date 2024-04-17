// ignore_for_file: non_constant_identifier_names

import 'package:crm_david/models/current_customer.dart';
import 'package:crm_david/models/load_data.dart';
import 'package:crm_david/screens/new_customer.dart';
import 'package:crm_david/screens/print_screen.dart';
import 'package:crm_david/screens/repair.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';

class CreateTicketScreen extends StatefulWidget {
  static const routeName = "/createTicket";

  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final TextStyle labelStyle = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );
  final TextEditingController serialNumber = TextEditingController();
  final TextEditingController faultDescription = TextEditingController();
  final TextEditingController passcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Ticket"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manufacturer",
                style: labelStyle,
              ),
              Consumer<LoadData>(
                builder: (context, loadData, child) {
                  if (loadData.manufacturers.isEmpty) {
                    loadData.loadManufactures();
                    return child!;
                  }

                  return SearchableDropdown(
                    items: [
                      for (var man in loadData.manufacturers)
                        SearchableDropdownMenuItem(
                          value: loadData.manufacturers.indexOf(man),
                          label: man.brand_name,
                          child: Text(man.brand_name),
                        ),
                    ],
                    onChanged: (val) {
                      loadData.manId = val!;
                      loadData.update();
                    },
                    value: loadData.manId,
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
                "Model",
                style: labelStyle,
              ),
              Consumer<LoadData>(
                builder: (context, loadData, child) {
                  if (loadData.models.isEmpty) {
                    loadData.loadModels();
                    return child!;
                  }

                  return SearchableDropdown(
                    items: [
                      for (var man in loadData.models)
                        SearchableDropdownMenuItem(
                          label: man.name,
                          child: Text(man.name),
                          value: loadData.models.indexOf(man),
                        ),
                    ],
                    onChanged: (value) {
                      loadData.modelId = value!;
                      loadData.update();
                    },
                    value: loadData.modelId,
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
              CustomTextField(
                controller: passcodeController,
                label: "Passcode",
                hint: "Passcode",
                onSubmit: () {},
                padding: const EdgeInsets.all(0),
              ),
              CustomTextField(
                controller: serialNumber,
                hint: "Serial Number",
                label: "Serial Number",
                onSubmit: () {},
                padding: const EdgeInsets.all(0),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: faultDescription,
                decoration: const InputDecoration(
                  hintText: "Fault Description",
                  label: Text("Fault Description"),
                ),
                maxLines: 5,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Technician",
                style: labelStyle,
              ),
              Consumer<LoadData>(
                builder: (context, loadData, child) {
                  if (loadData.techs.isEmpty) {
                    loadData.loadTechnicians();
                    return child!;
                  }

                  return SearchableDropdown(
                    items: [
                      for (var tech in loadData.techs)
                        SearchableDropdownMenuItem(
                          value: loadData.techs.indexOf(tech),
                          label: tech.tech_name,
                          child: Text(tech.tech_name),
                        ),
                    ],
                    value: loadData.techId,
                    onChanged: (val) {
                      loadData.techId = val!;
                      loadData.update();
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
                "Included Accessories",
                style: labelStyle,
              ),
              Consumer<LoadData>(
                builder: (context, loadData, child) {
                  if (loadData.accesories.isEmpty) {
                    loadData.loadAccessories();
                    return child!;
                  }

                  return Column(
                    children: [
                      for (var accessory in loadData.accesories)
                        CheckboxListTile(
                          value: loadData.selectedAccessories.contains(
                            loadData.accesories.indexOf(accessory),
                          ),
                          onChanged: (value) {
                            // WHAT THE FUCK?? WHY WOULD VALUE BE NULLL? FLUTTTERR!!!!
                            if (value == null) {
                              return;
                            }

                            int index = loadData.accesories.indexOf(
                              accessory,
                            );
                            if (value) {
                              if (!loadData.selectedAccessories
                                  .contains(index)) {
                                loadData.selectedAccessories.add(index);
                              }
                            } else {
                              loadData.selectedAccessories.remove(index);
                            }

                            loadData.update();
                          },
                          title: Text(accessory.label),
                        ),
                    ],
                  );
                },
                child: const CircularProgressIndicator(),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final ccmodel = Provider.of<CurrentCustomerModel>(
                      context,
                      listen: false,
                    );
                    final loadData = Provider.of<LoadData>(
                      context,
                      listen: false,
                    );
                    // Save RMA
                    var save =
                        await Provider.of<LoadData>(context, listen: false)
                            .insertService(
                      customer: ccmodel.customer!,
                      ticketData: TicketData(
                        manufacture: loadData.manufacturers[loadData.manId],
                        model: loadData.models[loadData.modelId],
                        technician: loadData.techs[loadData.techId],
                        description: faultDescription.text,
                        serialNumber: serialNumber.text,
                        accessories: loadData.selectedAccessoriesAsListString,
                        passcode: passcodeController.text,
                      ),
                    );

                    if (!save) {
                      // Negative
                      showToast(
                        "ERROR creating service.",
                        position: ToastPosition.bottom,
                      );
                      return;
                    }

                    // SHOW ALERT DIALOG
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Add item repairs?"),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  Navigator.popAndPushNamed(
                                    context,
                                    RepairPartsScreen.routeName,
                                  );
                                },
                                icon: const Text("Yes"),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.popAndPushNamed(
                                    context,
                                    PrintScreen.routeName,
                                  );
                                },
                                icon: const Text("No"),
                              ),
                            ],
                          );
                        });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => const Color.fromARGB(255, 240, 217, 243),
                    ),
                  ),
                  child: const Text("Submit"),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
