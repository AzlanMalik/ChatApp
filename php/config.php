<?php
  require_once __DIR__ . '/../vendor/autoload.php';

  // Looing for .env at the root directory
  $dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/../');
  $dotenv->load();

  $hostname = $_ENV['MYSQL_HOST'];
  $username = $_ENV['MYSQL_USER'];
  $password = $_ENV['MYSQL_PASSWORD'];
  $dbname = $_ENV['MYSQL_DATABASE'];

  $conn = mysqli_connect($hostname, $username, $password, $dbname);
  if(!$conn){
    echo "Database connection error".mysqli_connect_error();
  }

?>
