import 'package:crm_david/api.dart';
import 'package:flutter/material.dart';

class CustomerData {
  /// This is the really important part. This allows for quick queries.
  final int? id;
  final String name;
  final String phone;
  final String mobile;
  final String email;

  CustomerData({
    this.id,
    required this.name,
    required this.phone,
    required this.mobile,
    required this.email,
  });

  CustomerData copyWithId(int id) {
    return CustomerData(
      name: name,
      phone: phone,
      email: email,
      mobile: mobile,
      id: id,
    );
  }

  String getNumber() {
    if (phone.isEmpty) {
      return mobile;
    }

    return phone;
  }
}

class CurrentCustomerModel with ChangeNotifier {
  CustomerData? customer;
  List<CustomerData> allCustomers = [];

  void setCustomerData(CustomerData customerData) {
    customer = customerData;
    notifyListeners();
  }

  Future<void> loadCustomers() async {
    final result = await getCustomers();
    allCustomers = result;
    notifyListeners();
  }

  /// Load the `customer` object from MySQL conn via it's id.
  Future<bool> loadFromID(int id) async {
    final result = await getFromId(id);
    if (result == null) {
      return false;
    }

    customer = result;

    // if (!isConnected()) {
    //   return false;
    // }

    // var res = await conn!.execute(
    //   "SELECT * FROM `customer` WHERE id = :id",
    //   {"id": id},
    // );

    // // We only need one
    // var row = res.rows.firstOrNull;

    // if (row == null) {
    //   return false;
    // }

    // customer = CustomerData(
    //   name: "${row.colByName("fname")!} ${row.colByName("lname")!}",
    //   number: row.colByName("phone")!,
    //   email: row.colByName("email")!,
    //   id: id,
    // );

    notifyListeners();

    return true;
  }

  /// Load the `customer` from CustomerData not including id.
  Future<bool> loadFromData(CustomerData data, {bool update = true}) async {
    final result = await getFromData(data);
    if (result == null) {
      return false;
    }
    customer = result;

    // if (!isConnected()) {
    //   print("Not connected");
    //   return false;
    // }

    // var res = await conn!.execute(
    //   "SELECT * FROM `customers` WHERE fname = :fname AND lname = :lname AND email = :email AND phone = :phone",
    //   {
    //     "fname": data.name.split(" ").first,
    //     "lname": data.name.split(" ").last,
    //     "email": data.email.toLowerCase().trim(),
    //     "phone": data.number,
    //   },
    // );

    // if (res.numOfRows == 0) {
    //   return false;
    // }
    // if (!update) {
    //   return true;
    // }

    // customer = data.copyWithId(
    //   int.parse(res.rows.first.colByName("id")!),
    // );

    notifyListeners();

    return true;
  }

  Future<bool> newCustomer(CustomerData data) async {
    return await setNewCustomer(data);
    // // Check if customer already exists
    // if (await loadFromData(data, update: false)) {
    //   // Customer already exists

    //   return false;
    // }

    // // Lets make a new one.
    // var res = await conn!.execute(
    //   "INSERT INTO `customers` (fname, lname, email, phone) VALUES (:fname, :lname, :email, :phone)",
    //   {
    //     "fname": data.name.split(" ").first,
    //     "lname": data.name.split(" ").last,
    //     "email": data.email.toLowerCase().trim(),
    //     "phone": data.number,
    //   },
    // );

    // return res.affectedRows.toInt() == 1;
  }

  void update() {
    notifyListeners();
  }
}
