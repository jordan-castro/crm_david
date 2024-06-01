import 'dart:convert';

import 'package:crm_david/models/current_customer.dart';
import 'package:crm_david/models/load_data.dart';
import 'package:crm_david/utils/parser.dart';
import 'package:http/http.dart' as http;

final apiUrl = Uri.parse("http://localhost:8080/test.php");
// final apiUrl = Uri.parse("https://wirelessplanet310.com/rma/testing.php");

// GETTERS

Future<JSONArray> getSettings() async {
  final response = await http.post(
    apiUrl,
    body: {"query": "SELECT * FROM settings"},
  );

  if (response.body == "0") {
    return [];
  }

  final jsonResponse = jsonDecode(response.body);

  JSONArray settings = [];

  for (var row in jsonResponse) {
    settings.add(
      {
        "name": row['name'],
        "value": row['value'],
      },
    );
  }

  return settings;
}

Future<List<CustomerData>> getCustomers() async {
  final response = await http.post(
    apiUrl,
    body: {"query": "SELECT * FROM customers"},
  );

  if (response.body == "0") {
    return [];
  }

  final jsonResponse = jsonDecode(response.body);

  List<CustomerData> cs = [];

  for (var row in jsonResponse) {
    cs.add(
      CustomerData(
        name: "${row['fname']} ${row['lname']}",
        phone: row['phone'],
        mobile: row['mobile1'] ?? "",
        email: row['email'],
        id: parseIntoInt(row['id']),
      ),
    );
  }

  return cs;
}

Future<List<Manufacture>> getManufactures() async {
  final result = await http.post(
    apiUrl,
    body: {
      "query": "SELECT * FROM brand",
    },
  );

  if (result.body == "0") {
    return [];
  }

  final jsonResponse = jsonDecode(result.body);

  List<Manufacture> mans = [];
  for (var row in jsonResponse) {
    mans.add(
      Manufacture(
        id: parseIntoInt(row['id']),
        brand_name: row['brand_name'],
      ),
    );
  }

  return mans;
}

Future<List<Model>> getModels() async {
  final response = await http.post(
    apiUrl,
    body: {
      "query": "SELECT * FROM devices",
    },
  );

  if (response.body == "0") {
    return [];
  }

  final jsonResponse = jsonDecode(response.body);

  List<Model> models = [];
  for (var row in jsonResponse) {
    models.add(
      Model(
        id: parseIntoInt(row['id']),
        name: row['name'],
      ),
    );
  }

  return models;
}

Future<List<Part>> getParts() async {
  final response = await http.post(
    apiUrl,
    body: {"query": "SELECT * FROM product_service"},
  );
  if (response.body == "0") {
    return [];
  }

  final jsonResponse = jsonDecode(response.body);
  List<Part> parts = [];

  for (var row in jsonResponse) {
    parts.add(
      Part(
        description: row['description'],
        productId: parseIntoInt(row['productId']),
        qty: parseIntoDouble(row['qty']).toInt(),
        unitPrice: parseIntoDouble(row['unitPrice']),
      ),
    );
  }

  return parts;
}

Future<List<Technician>> getTechs() async {
  final response = await http.post(
    apiUrl,
    body: {"query": "SELECT * FROM technicians"},
  );

  if (response.body == "0") {
    return [];
  }

  final jsonResponse = jsonDecode(response.body);

  List<Technician> techs = [];

  for (var row in jsonResponse) {
    print(row);
    techs.add(
      Technician(
        id: parseIntoInt(row['id']),
        tech_name: row['TechName'],
        email: row['Email'],
        username: row['username'],
        password: row['password'],
      ),
    );
  }

  return techs;
}

typedef JSON = Map<String, dynamic>;
typedef JSONArray = List<JSON>;

Future<List<Accessory>> getAccessories() async {
  final response = await http.post(
    apiUrl,
    body: {
      "query":
          "SELECT `value` FROM `settings` WHERE `name` = 'included_accessories'"
    },
  );

  if (response.body == "0") {
    return [];
  }

  final jsonResponse = jsonDecode(response.body)[0];
  List<Accessory> accs = [];

  for (var row in jsonResponse['value'].split(",")) {
    accs.add(
      Accessory(
        label: row,
      ),
    );
  }

  return accs;
}

Future<String?> getMostRecentRMA_ServerCall() async {
  final response = await http.post(
    apiUrl,
    body: {
      "query": "SELECT * FROM `increment_services` ORDER BY `id` DESC LIMIT 1"
    },
  );

  if (response.body == "0") {
    return null;
  }

  return jsonDecode(response.body)[0]['rmaid'];
}

Future<CustomerData?> getFromId(int id) async {
  final response = await http.post(
    apiUrl,
    body: {
      "query": "SELECT * FROM `customer` WHERE id = $id",
    },
  );

  if (response.body == "0") {
    return null;
  }

  final jsonResponse = jsonDecode(response.body)[0];

  return CustomerData(
    name: jsonResponse['name'],
    phone: jsonResponse['phone'],
    mobile: jsonResponse['mobile'],
    email: jsonResponse['email'],
  );
}

Future<CustomerData?> getFromData(CustomerData data) async {
  final response = await http.post(
    apiUrl,
    body: {
      "query": """
            SELECT * FROM `customers` 
            WHERE fname = '${data.name.split(" ").first}' 
            AND lname = '${data.name.split(" ").last}'
            AND email = '${data.email}' 
            AND phone = '${data.phone}'
      """,
    },
  );

  if (response.body == "[]") {
    return null;
  }

  final jsonResponse = jsonDecode(response.body)[0];

  print(jsonResponse);

  return CustomerData(
    name: "${jsonResponse['fname']} ${jsonResponse['lname']}",
    phone: jsonResponse['phone'],
    mobile: jsonResponse['mobile1'],
    email: jsonResponse['email'],
    id: parseIntoInt(jsonResponse['id']),
  );
}

Future<int> getLastServiceId() async {
  //   res = await conn!.execute(
  //     "SELECT * FROM services ORDER BY id DESC LIMIT 1",
  //   );
  //   if (res.numOfRows == 0) {
  //     print("ERROR could not getr service");
  //     return false;
  //   }
  final response = await http.post(
    apiUrl,
    body: {
      "query": "SELECT * FROM services ORDER BY id DESC LIMIT 1",
    },
  );

  if (response.body == "0") {
    return -1;
  }

  return parseIntoInt(jsonDecode(response.body)[0]['id']);
}

// Setters
Future<bool> setNewCustomer(CustomerData data) async {
  final response = await http.post(
    apiUrl,
    body: {
      "action": "insert",
      "query": """
            INSERT INTO `customers` 
            (
              fname, 
              lname, 
              email, 
              phone,
              mobile1,
              registerDate,
              position,
              vatnumber,
              vatId,
              currency,
              notes,
              deleted,
              emailoptin,
              website,
              payment_method,
              due_date,
              shipping_address,
              shipping_address2,
              shipping_city,
              shipping_country,
              vat_identification
            ) 
            VALUES (
              '${data.name.split(" ").first}', 
              '${data.name.split(" ").last}', 
              '${data.email}', 
              '${data.phone}',
              '${data.mobile}',
              '${DateTime.now().toString().split(" ").first}',
              '',
              '',
              1,
              2,
              '',
              0,
              0,
              '',
              7,
              2,
              '',
              '',
              '',
              '',
              ''
            )
      """,
    },
  );

  print(response.body);

  return response.statusCode == 200;
}

Future<bool> setInsertService({
  required CustomerData customer,
  required TicketData ticketData,
  required RMA currentRma,
}) async {
  final response = await http.post(
    apiUrl,
    body: {
      "action": "insert",
      "query": """
              INSERT INTO `services`
              (
                `clientid`, 
                `rmaid`, 
                `clientname`, 
                `phone`, 
                `opendate`, 
                `description`, 
                `serialnumber`, 
                `technician`, 
                `accessories`, 
                `technicianid`, 
                `warrantyid`, 
                `statusid`, 
                `priority`,
                `custom1`,
                `machinetype`,
                `supplier`,
                `estimatedate`,
                `rma_status`
       )
       VALUES (
        ${customer.id}, 
        '${currentRma.id}', 
        '${customer.name}', 
        '${customer.getNumber()}', 
        '${currentRma.dateTime.toString().split(".")[0]}', 
        '${ticketData.description}', 
        '${ticketData.serialNumber}', 
        '${ticketData.technician.tech_name}', 
        '${ticketData.accessories.join(",")}', 
        ${ticketData.technician.id}, 
        1,
        1,
        'Standard',
        '${ticketData.passcode}',
        '${ticketData.model.name}',
        '${ticketData.manufacture.brand_name}',
        '${currentRma.dateTime.toString().split(".")[0]}',
        'Awaiting Diagnostic'
        )

""",
    },
  );

  if (response.body == "0") {
    return false;
  } else {
    return true;
  }
}

Future<bool> setSaveRMA({required int serviceId, required RMA rma}) async {
  final response = await http.post(
    apiUrl,
    body: {
      "action": "insert",
      "query":
          "INSERT INTO `increment_services` (`service_id`, `rmaid`, `number`) VALUES ($serviceId, '${rma.id}', ${rma.id.split("-").last})",
    },
  );

  return response.statusCode == 200;
}

Future<bool> setAddProductToService({
  required Part part,
  required int serviceId,
}) async {
  final response = await http.post(
    apiUrl,
    body: {
      "action": "insert",
      "query": """
              INSERT INTO product_service (`productId`, `serviceId`, `description`, `qty`, `unitPrice`) 
              VALUES (
                ${part.productId},
                $serviceId,
                '${part.description}',
                ${part.qty},
                ${part.unitPrice}
              )
      """,
    },
  );

  return response.body == "1";
}
