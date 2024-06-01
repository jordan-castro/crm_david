<?php

// Connect to MySQL
$dbHost = "localhost";
$port = 3306;
$username = "root";
$password = "root";
$dbName = "crm_david";
$pdo = null;

try {
    $dsn = "mysql:host=$dbHost;port=$port;dbname=$dbName";
    $pdo = new PDO($dsn, $username, $password);

    // // Set the PDO error mode to exception
    // $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

} catch (PDOException $e) {
    error_log("Connection failed: " . $e->getMessage());
    http_response_code(505);
    die(0);
}

$action = "select";
if (array_key_exists("action", $_POST) or array_key_exists("action", $_GET)) {
    $action = $_POST['action'];
}
$query = $_POST['query'];

if ($query == null) {
    $query = $_GET['query'];
}

if (strstr($query, ";")) {
    // This means someone is trying to apply SQL injection.
    http_response_code(505);
    die(0);
}

error_log($action);
error_log($query);

if ($query == "SELECT * FROM customers") {
    $query = "SELECT * FROM customers WHERE `id` <> 1991";
}

if ($action == "select") {
    $stmt = $pdo->query($query);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo(json_encode($result));
} elseif ($action == "insert") {
    $pdo->exec($query);
    echo(1);
}