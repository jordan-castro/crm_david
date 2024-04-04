// ignore_for_file: non_constant_identifier_names

import 'package:crm_david/models/current_customer.dart';
import 'package:crm_david/utils/server_db.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

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
  MySQLConnection? conn;
  List<Manufacture> manufacturers = [];
  List<Model> models = [];
  List<Technician> techs = [];
  List<Accessory> accesories = [];
  List<Part> parts = [];
  RMA currentRMA = RMA(id: "0");
  TicketData? currentTicket;

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

  Future<void> init() async {
    conn = await connectMySQL();
    await conn!.connect();
    notifyListeners();
  }

  bool isConnected() {
    return conn?.connected ?? false;
  }

  Future<void> loadManufactures() async {
    if (!isConnected()) {
      return;
    }

    var results = await conn!.execute("SELECT * FROM `brand`");
    if (results.numOfRows == 0) {
      return;
    }

    manufacturers.clear();

    for (var row in results.rows) {
      manufacturers.add(
        Manufacture(
          id: int.parse(row.colAt(0)!),
          brand_name: row.colAt(1)!,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> loadModels() async {
    if (!isConnected()) {
      return;
    }

    var results = await conn!.execute("SELECT * FROM `devices`");
    if (results.numOfRows == 0) {
      return;
    }

    models.clear();

    for (var row in results.rows) {
      models.add(
        Model(
          id: int.parse(row.colAt(0)!),
          name: row.colAt(1)!,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> loadTechnicians() async {
    if (!isConnected()) {
      return;
    }

    var results = await conn!.execute("SELECT * FROM `technicians`");
    if (results.numOfRows == 0) {
      return;
    }

    techs.clear();

    for (var row in results.rows) {
      techs.add(
        Technician(
          id: int.parse(row.colAt(0)!),
          tech_name: row.colAt(1)!,
          email: row.colAt(2)!,
          username: row.colAt(3)!,
          password: row.colAt(4)!,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> loadAccessories() async {
    if (!isConnected()) {
      return;
    }

    var results = await conn!.execute(
      "SELECT `value` FROM `settings` WHERE `name` = :name",
      {
        "name": "included_accessories",
      },
    );

    if (results.numOfRows != 1) {
      return;
    }

    accesories.clear();

    print(results.rows.first.numOfColumns);

    for (var val in results.rows.first.colAt(0)!.split(",")) {
      accesories.add(Accessory(label: val));
    }

    notifyListeners();
  }

  Future<void> loadParts() async {
    if (!isConnected()) {
      return;
    }

    var results = await conn!.execute("SELECT * FROM product_service");
    if (results.numOfRows == 0) {
      return;
    }

    parts.clear();

    for (var val in results.rows) {
      parts.add(
        Part(
          description: val.colByName("description")!,
          productId: int.parse(val.colByName("productId")!),
          qty: double.parse(val.colByName("qty")!).toInt(),
          unitPrice: double.parse(val.colByName("unitPrice")!),
        ),
      );
    }

    notifyListeners();
  }

  Future<RMA?> getMostRecentRMA() async {
    // COMES FROM `increment_services`
    if (!isConnected()) {
      return null;
    }

    var results = await conn!.execute(
      "SELECT * FROM `increment_services` ORDER BY `id` DESC LIMIT 1",
    );
    if (results.numOfRows == 0) {
      return null;
    }

    return RMA(
      id: results.rows.first.colByName("rmaid")!,
    );
  }

  Future<bool> insertService({
    required CustomerData customer,
    required TicketData ticketData,
  }) async {
    if (!isConnected()) {
      return false;
    }

    // new RMA
    final rma = await RMA.createRMA(this);
    if (rma == null) {
      return false;
    }

    // Create new service
    var res = await conn!.execute("""
      INSERT INTO `services` 
      (`clientid`, `rmaid`, `clientname`, `phone`, `opendate`, `description`, `serialnumber`, `technician`, `accessories`, `technicianid`, 
      `warrantyid`, `statusid`
      )
      VALUES
      (:clientid, :rmaid, :clientname, :phone, :opendate, :description, :serialnumber, :technician, :accessories, :technicianid, :warranty,
      :status
      );
    """, {
      "clientid": customer.id,
      "rmaid": rma.id,
      "clientname": customer.name,
      "phone": customer.number,
      "opendate": rma.dateTime.toString().split(".")[0],
      "description": ticketData.description,
      "serialnumber": ticketData.serialNumber,
      "technician": ticketData.technician.tech_name,
      "accessories": ticketData.accessories.join(","),
      "technicianid": ticketData.technician.id,
      "warranty": 1,
      "status": 1,
    });
    if (res.affectedRows.toInt() == 0) {
      print("ERROR adding service");
      return false;
    }

    // Get service id
    res = await conn!.execute(
      "SELECT * FROM services ORDER BY id DESC LIMIT 1",
    );
    if (res.numOfRows == 0) {
      print("ERROR could not getr service");
      return false;
    }

    // Save RMA
    res = await conn!.execute(
      "INSERT INTO `increment_services` (`service_id`, `rmaid`, `number`) VALUES (:service, :rma, :num);",
      {
        "service": res.rows.first.colAt(0),
        "rma": rma.id,
        "num": rma.id.split("-").last,
      },
    );
    if (res.affectedRows.toInt() == 0) {
      print("ERROR could not add increment_service");
      return false;
    }

    currentRMA = rma;
    currentTicket = ticketData;
    notifyListeners();

    return true;
  }

  void update() {
    notifyListeners();
  }
}
