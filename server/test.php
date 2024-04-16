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

    // Set the PDO error mode to exception
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
    die(0);
}

$action = "select";
if (array_key_exists("action", $_POST)) {
    $action = $_POST['action'];
}
$query = $_POST['query'];

if ($action == "select") {
    $stmt = $pdo->query($query);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo(json_encode($result));
    exit(1);
} elseif ($action == "insert") {
    $pdo->exec($query);
    echo(1);
}
