import 'dart:typed_data';

import 'package:crm_david/models/app_data.dart';
import 'package:crm_david/models/current_customer.dart';
import 'package:crm_david/models/load_data.dart';
import 'package:crm_david/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrintScreen extends StatefulWidget {
  static const routeName = "/print";

  const PrintScreen({super.key});

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  @override
  Widget build(BuildContext context) {
    final loadDataModel = Provider.of<LoadData>(
      context,
      listen: false,
    );
    final currentCustomerModel = Provider.of<CurrentCustomerModel>(
      context,
      listen: false,
    );
    final appData = Provider.of<AppData>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Print"),
      ),
      body: PdfPreview(
        build: (format) => generatePdf(loadDataModel, currentCustomerModel),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: false,
        canDebug: false,
        dpi: 400.0,
        previewPageMargin: const EdgeInsets.symmetric(horizontal: 20.0),
        initialPageFormat: PdfPageFormat.roll80,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              bool connected = false;
              // Detect if bluetooth is connected
              final bool result = await PrintBluetoothThermal.bluetoothEnabled;
              if (!result) {
                showToast(
                  "Bluetooth not connected",
                  position: ToastPosition.bottom,
                );
                return;
              }

              // Check connection via printer
              final List<BluetoothInfo> devices =
                  await PrintBluetoothThermal.pairedBluetooths;
              for (var device in devices) {
                if (device.macAdress == appData.macAddress) {
                  // Connect to this device
                  connected = await PrintBluetoothThermal.connect(
                    macPrinterAddress: device.macAdress,
                  );
                  break;
                }
              }

              // Check connection status
              if (!connected ||
                  !(await PrintBluetoothThermal.connectionStatus)) {
                showToast(
                  "Could not connect to any printer by MAC address: ${appData.macAddress}",
                  position: ToastPosition.bottom,
                  duration: const Duration(seconds: 30),
                );
                return;
              }

              // We are ready to print:
            },
          )
        ],
        onPrinted: (context) {
          showToast("Reciept Printed", position: ToastPosition.bottom);
          Navigator.popAndPushNamed(
            context,
            WelcomeScreen.routeName,
          );
        },
      ),
    );
  }

  Future<Uint8List> generatePdf(
    LoadData loadDataModel,
    CurrentCustomerModel currentCustomerModel,
  ) async {
    final doc = pw.Document();
    final logoImage = await imageFromAssetBundle("assets/logo.png");
    final footerImage = await imageFromAssetBundle("assets/footer.png");

    // A style for text
    const textStyle = pw.TextStyle(
      fontSize: 15.0,
    );
    const smallFont = pw.TextStyle(
      fontSize: 6.0,
    );

    doc.addPage(
      pw.Page(
        clip: true,
        margin: const pw.EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 50.0,
          bottom: 10.0,
        ),
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              // mainAxisAlignment: MainAxisAlignment.
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(logoImage),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  currentCustomerModel.customer!.name,
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  "ID: ${loadDataModel.currentRMA.id}",
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  currentCustomerModel.customer!.getNumber(),
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  "S/N: ${loadDataModel.currentTicket?.serialNumber ?? 'SN: 0'}",
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  loadDataModel.currentRMA.dateTime.toString().split(":")[0],
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  loadDataModel.currentManufacture.brand_name,
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  "Devide: ${loadDataModel.currentModel.name}",
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  "Fault: ${loadDataModel.currentTicket?.description ?? "No current description"}",
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  "\$${loadDataModel.partsSelected.map((part) => part.unitPrice).reduce((a, b) => a + b)}",
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  "Parts needed: ",
                  style: textStyle,
                ),
                pw.SizedBox(
                  height: 10.0,
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: loadDataModel.partsSelected
                      .map((part) => buildPart(part))
                      .toList(),
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  "All devices, items & equipment left after 90 days with no contact will be considered abandoned. The device may be sold, disassembled or recycled to recover cost of parts or labor",
                  style: smallFont,
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(
                  height: 25.0,
                ),
                pw.Text(
                  "The price quoted is an estimate based on intial diagnostic and experience with the repair / device. The quote is subject to change based on scope of work after in-depth analysis & diagnostic. The client shall be informed of changes immediately",
                  style: smallFont,
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(
                  height: 10.0,
                ),
                pw.Image(footerImage),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget buildPart(Part part) {
    return pw.Text(
      part.description,
      style: const pw.TextStyle(fontSize: 10.0),
    );
  }

  /// Write to a bluetooth printer
  Future<void> printBluetooth(
    LoadData loadDataModel,
    CurrentCustomerModel currentCustomerModel,
  ) async {
    String enter = "\n";
    await PrintBluetoothThermal.writeBytes(enter.codeUnits);
    
  }
}
