// ignore_for_file: non_constant_identifier_names

import 'package:crm_david/api.dart';
import 'package:crm_david/models/current_customer.dart';
import 'package:flutter/material.dart';

/// in DB is `brand`
class Manufacture {
  final int id;
  final String brand_name;

  Manufacture({required this.id, required this.brand_name});
}

/// In DB is `devices`
class Model {
  final int id;
  final String name;

  Model({required this.id, required this.name});
}

/// Technician. In DB is `technicians`
class Technician {
  final int id;
  final String tech_name;
  final String email;
  final String username;
  final String password;

  Technician({
    required this.id,
    required this.tech_name,
    required this.email,
    required this.username,
    required this.password,
  });
}

/// Accessory. In DB `settings.included_accessories`.
class Accessory {
  final String label;

  Accessory({required this.label});
}

/// Part. In DB `product_service`
class Part {
  /// .productId
  final int productId;

  /// .description
  final String description;

  /// .qty
  final int qty;

  /// .unitPrice
  final double unitPrice;

  Part({
    required this.productId,
    required this.description,
    required this.qty,
    required this.unitPrice,
  });
}

class RMA {
  final String id;

  /// This is only present in our createRMA rmas.
  DateTime? dateTime;

  RMA({required this.id});

  static Future<RMA?> createRMA(LoadData loadData) async {
    final mostRecentRMA = await loadData.getMostRecentRMA();
    if (mostRecentRMA == null) {
      return null;
    }

    final newId = int.parse(mostRecentRMA.id.split("-").last) + 1;
    final rightNow = DateTime.now();

    final r = RMA(
      id: "R-${rightNow.year}${rightNow.month}${rightNow.day}${rightNow.hour}${rightNow.minute}-$newId",
    );
    r.dateTime = rightNow;

    return r;
  }
}

class TicketData {
  final Manufacture manufacture;
  final Model model;
  final Technician technician;
  final String description;
  final String serialNumber;
  final List<String> accessories;

  TicketData({
    required this.manufacture,
    required this.model,
    required this.technician,
    required this.description,
    required this.serialNumber,
    required this.accessories,
  });
}

class LoadData with ChangeNotifier {
  List<Manufacture> manufacturers = [];
  List<Model> models = [];
  List<Technician> techs = [];
  List<Accessory> accesories = [];
  List<Part> parts = [];
  RMA currentRMA = RMA(id: "0");
  TicketData? currentTicket;
  int currentServiceId = -1;
  JSONArray settings = [];

  int manId = 0;
  int modelId = 0;
  int techId = 0;
  int partId = 0;
  List<int> selectedAccessories = [];

  List<String> get selectedAccessoriesAsListString {
    List<String> list = [];
    for (var sel in selectedAccessories) {
      list.add(accesories[sel].label);
    }
    return list;
  }

  Future<void> loadManufactures() async {
    var results = await getManufactures();
    if (results.isEmpty) {
      return;
    }

    manufacturers.clear();
    manufacturers = results;

    notifyListeners();
  }

  Future<void> loadSettings() async {
    final result = await getSettings();
    settings = result;
    notifyListeners();
  }

  Future<void> loadModels() async {
    final result = await getModels();
    if (result.isEmpty) {
      return;
    }

    models.clear();
    models = result;

    // var results = await conn!.execute("SELECT * FROM `devices`");
    // if (results.numOfRows == 0) {
    //   return;
    // }

    // models.clear();

    // for (var row in results.rows) {
    //   models.add(
    //     Model(
    //       id: int.parse(row.colAt(0)!),
    //       name: row.colAt(1)!,
    //     ),
    //   );
    // }

    notifyListeners();
  }

  Future<void> loadTechnicians() async {
    final result = await getTechs();
    if (result.isEmpty) {
      return;
    }

    techs.clear();
    techs = result;

    // if (!isConnected()) {
    //   return;
    // }

    // var results = await conn!.execute("SELECT * FROM `technicians`");
    // if (results.numOfRows == 0) {
    //   return;
    // }

    // techs.clear();

    // for (var row in results.rows) {
    //   techs.add(
    //     Technician(
    //       id: int.parse(row.colAt(0)!),
    //       tech_name: row.colAt(1)!,
    //       email: row.colAt(2)!,
    //       username: row.colAt(3)!,
    //       password: row.colAt(4)!,
    //     ),
    //   );
    // }

    notifyListeners();
  }

  Future<void> loadAccessories() async {
    final result = await getAccessories();
    accesories.clear();
    accesories = result;
    notifyListeners();
  }

  Future<void> loadParts() async {
    final result = await getParts();
    if (result.isEmpty) {
      return;
    }

    parts.clear();
    parts = result;

    notifyListeners();
  }

  Future<RMA?> getMostRecentRMA() async {
    // COMES FROM `increment_services`
    // if (!isConnected()) {
    // return null;
    // }

    // var results = await conn!.execute(
    //   "SELECT * FROM `increment_services` ORDER BY `id` DESC LIMIT 1",
    // );
    // if (results.numOfRows == 0) {
    //   return null;
    // }

    // return RMA(
    //   id: results.rows.first.colByName("rmaid")!,
    // );

    final result = await getMostRecentRMA_ServerCall();
    if (result == null) {
      return null;
    }

    return RMA(
      id: result,
    );
  }

  Future<bool> insertService({
    required CustomerData customer,
    required TicketData ticketData,
  }) async {
    // new RMA
    final rma = await RMA.createRMA(this);
    if (rma == null) {
      print("HERE");
      return false;
    }

    // Create service
    final serviceCreated = await setInsertService(
      customer: customer,
      ticketData: ticketData,
      currentRma: rma,
    );

    if (!serviceCreated) {
      print("HERE 2");
      return false;
    }

    // Get service Id
    final serviceId = await getLastServiceId();
    if (serviceId == -1) {
      print("HERE 3");

      return false;
    }

    // Save RMA
    final rmaSaved = await setSaveRMA(
      serviceId: serviceId,
      rma: rma,
    );

    if (!rmaSaved) {
      print("HERE 4");
      return false;
    }

    // Set currentRMA
    currentRMA = rma;
    currentTicket = ticketData;
    currentServiceId = serviceId;
    notifyListeners();
    return true;
  }

  Future<bool> addProductToService({
    required Part part,
  }) async {
    if (currentServiceId == -1) {
      return false;
    }

    final productInserted = await setAddProductToService(
      part: part,
      serviceId: currentServiceId,
    );

    return productInserted;
  }

  void update() {
    notifyListeners();
  }
}
