import 'package:crm_david/utils/server_db.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

class CustomerData {
  /// This is the really important part. This allows for quick queries.
  final int? id;
  final String name;
  final String number;
  final String email;

  CustomerData({
    this.id,
    required this.name,
    required this.number,
    required this.email,
  });

  CustomerData copyWithId(int id) {
    return CustomerData(
      name: name,
      number: number,
      email: email,
      id: id,
    );
  }
}

class CurrentCustomerModel with ChangeNotifier {
  CustomerData? customer;
  MySQLConnection? conn;

  Future<void> init() async {
    conn = await connectMySQL();
    await conn!.connect();

    notifyListeners();
  }

  bool isConnected() {
    return conn?.connected ?? false;
  }

  void setCustomerData(CustomerData customerData) {
    customer = customerData;
    notifyListeners();
  }

  /// Load the `customer` object from MySQL conn via it's id.
  Future<bool> loadFromID(int id) async {
    if (!isConnected()) {
      return false;
    }

    var res = await conn!.execute(
      "SELECT * FROM `customer` WHERE id = :id",
      {"id": id},
    );

    // We only need one
    var row = res.rows.firstOrNull;

    if (row == null) {
      return false;
    }

    customer = CustomerData(
      name: "${row.colByName("fname")!} ${row.colByName("lname")!}",
      number: row.colByName("phone")!,
      email: row.colByName("email")!,
      id: id,
    );

    notifyListeners();

    return true;
  }

  /// Load the `customer` from CustomerData not including id.
  Future<bool> loadFromData(CustomerData data, {bool update = true}) async {
    if (!isConnected()) {
      print("Not connected");
      return false;
    }

    var res = await conn!.execute(
      "SELECT * FROM `customers` WHERE fname = :fname AND lname = :lname AND email = :email AND phone = :phone",
      {
        "fname": data.name.split(" ").first,
        "lname": data.name.split(" ").last,
        "email": data.email.toLowerCase().trim(),
        "phone": data.number,
      },
    );

    if (res.numOfRows == 0) {
      return false;
    }
    if (!update) {
      return true;
    }

    customer = data.copyWithId(
      int.parse(res.rows.first.colByName("id")!),
    );

    notifyListeners();

    return true;
  }

  Future<bool> newCustomer(CustomerData data) async {
    // Check if customer already exists
    if (await loadFromData(data, update: false)) {
      // Customer already exists

      return false;
    }

    // Lets make a new one.
    var res = await conn!.execute(
      "INSERT INTO `customers` (fname, lname, email, phone) VALUES (:fname, :lname, :email, :phone)",
      {
        "fname": data.name.split(" ").first,
        "lname": data.name.split(" ").last,
        "email": data.email.toLowerCase().trim(),
        "phone": data.number,
      },
    );

    return res.affectedRows.toInt() == 1;
  }
}
