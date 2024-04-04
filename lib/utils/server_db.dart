import 'package:mysql_client/mysql_client.dart';

// /// Database connection to the CRM server.
// final pool = MySQLConnectionPool(
//   host: "localhost",
//   port: 3306,
//   userName: "root",
//   password: "root",
//   maxConnections: 4,
// );

/// Connect to a MySQL database.
Future<MySQLConnection> connectMySQL() async {
  return await MySQLConnection.createConnection(
    host: "localhost",
    port: 3306,
    userName: "root",
    password: "root",
    databaseName: "crm_david",
  );
}