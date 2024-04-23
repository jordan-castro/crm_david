// ignore_for_file: use_build_context_synchronously

import 'package:crm_david/models/load_data.dart';
import 'package:crm_david/screens/new_customer.dart';
import 'package:crm_david/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';

class RepairPartsScreen extends StatefulWidget {
  static const routeName = "/repairParts";
  const RepairPartsScreen({super.key});

  @override
  State<RepairPartsScreen> createState() => _RepairPartsScreenState();
}

class _RepairPartsScreenState extends State<RepairPartsScreen> {
  final TextEditingController qty = TextEditingController();
  final TextEditingController price = TextEditingController(text: "0.00");
  final TextStyle labelStyle = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );
  bool hasPart = false;
  int quantity = 0;

  final SearchableDropdownController partNumber =
      SearchableDropdownController();
  final SearchableDropdownController description =
      SearchableDropdownController();

  bool isPriceModified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Repair"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              "Search by Part Number",
              style: labelStyle,
            ),
            Consumer<LoadData>(
              builder: (context, loadData, child) {
                if (loadData.parts.isEmpty) {
                  loadData.loadParts();
                  return child!;
                }
                return SearchableDropdown(
                  controller: partNumber,
                  items: [
                    for (var part in loadData.parts)
                      SearchableDropdownMenuItem(
                        label: "${part.productId}",
                        child: Text(
                          "${part.productId}",
                        ),
                        value: loadData.parts.indexOf(part),
                      )
                  ],
                  value: loadData.partId,
                  onChanged: (val) {
                    loadData.partId = val!;
                    loadData.update();
                    setState(() {
                      description.selectedItem.value =
                          description.items![loadData.partId];
                      price.text =
                          loadData.parts[val].unitPrice.toStringAsFixed(2);
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
              "Search by Part Description",
              style: labelStyle,
            ),
            Consumer<LoadData>(
              builder: (context, loadData, child) {
                if (loadData.parts.isEmpty) {
                  loadData.loadParts();
                  return child!;
                }

                return SearchableDropdown(
                  controller: description,
                  items: [
                    for (var part in loadData.parts)
                      SearchableDropdownMenuItem(
                        value: loadData.parts.indexOf(part),
                        label: part.description,
                        child: Text(part.description),
                      ),
                  ],
                  value: loadData.partId,
                  onChanged: (val) {
                    loadData.partId = val!;
                    loadData.update();
                    setState(() {
                      partNumber.selectedItem.value =
                          partNumber.items![loadData.partId];
                      price.text =
                          loadData.parts[val].unitPrice.toStringAsFixed(2);
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
              "Price",
              style: labelStyle,
            ),
            Consumer<LoadData>(
              builder: (context, loadData, child) {
                if (loadData.parts.isEmpty) {
                  return child!;
                }

                // Load initial price
                if (!isPriceModified) {
                  price.text =
                      "\$${(loadData.parts[loadData.partId].unitPrice * quantity).toStringAsFixed(2)}";
                }

                return CustomTextField(
                  controller: price,
                  label: "Price",
                  hint: "Price",
                  onSubmit: () {},
                  onChange: (val) {
                    if (!isPriceModified) {
                      setState(() => isPriceModified = true);
                    }
                  },
                  isNumber: true,
                  padding: const EdgeInsets.all(0),
                );
              },
              child: const CircularProgressIndicator(),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Quantity",
              style: labelStyle,
            ),
            CustomTextField(
              controller: qty,
              label: "Qty",
              hint: "Quantity",
              onSubmit: () {},
              isNumber: true,
              onChange: (value) {

                setState(() {
                  quantity = int.parse(value);
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // ADD TO DB
                  final loadData =
                      Provider.of<LoadData>(context, listen: false);
                  final part = loadData.parts[loadData.partId];
                  final res = await loadData.addProductToService(
                    part: Part(
                      description: part.description,
                      productId: part.productId,
                      qty: int.parse(qty.text),
                      unitPrice: double.parse(price.text.replaceAll("\$", "")),
                    ),
                  );

                  if (!res) {
                    showToast(
                      "Did not work",
                      position: ToastPosition.bottom,
                    );
                  }

                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Part added succesffuly."),
                          content:
                              const Text("Would you like to add a new part?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  WelcomeScreen.routeName,
                                );
                              },
                              child: const Text("No"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  RepairPartsScreen.routeName,
                                );
                              },
                              child: const Text("Yes"),
                            )
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
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
