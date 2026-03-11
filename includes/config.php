<?php
/**
 * Heal2Rise  - Configuration File
 * Database and application configuration
 */

// Database Configuration
define('DB_HOST', 'localhost');
define('DB_USERNAME', 'root');
define('DB_PASSWORD', '');
define('DB_NAME', 'heal2rise_');

// Application Configuration
define('APP_NAME', 'Heal2Rise ');
define('APP_URL', 'http://localhost/heal2rise-');
define('APP_VERSION', '1.0.0');

// Email Configuration
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_USERNAME', 'your-email@gmail.com');
define('SMTP_PASSWORD', 'your-app-password');
define('ADMIN_EMAIL', 'bc220207915mwa@vu.edu.pk');

// Payment Gateway Configuration (Demo Mode)
define('PAYMENT_MODE', 'sandbox');
define('EASYPAISA_MERCHANT_ID', 'your-easypaisa-merchant-id');
define('JAZZCASH_MERCHANT_ID', 'your-jazzcash-merchant-id');
define('PAYPAL_CLIENT_ID', 'your-paypal-client-id');

// Zoom API Configuration
define('ZOOM_API_KEY', 'your-zoom-api-key');
define('ZOOM_API_SECRET', 'your-zoom-api-secret');
define('ZOOM_ACCOUNT_ID', 'your-zoom-account-id');

// Firebase Configuration
define('FIREBASE_SERVER_KEY', 'your-firebase-server-key');
define('FIREBASE_SENDER_ID', 'your-firebase-sender-id');

// Session Configuration
session_start();

// Time Zone
date_default_timezone_set('Asia/Karachi');

// Error Reporting (Disable in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database Connection Class
class Database {
    private $host = DB_HOST;
    private $db_name = DB_NAME;
    private $username = DB_USERNAME;
    private $password = DB_PASSWORD;
    public $conn;

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            echo "Connection Error: " . $e->getMessage();
        }
        return $this->conn;
    }
}

// Helper Functions
function sanitizeInput($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
    return $data;
}

function generateToken($length = 32) {
    return bin2hex(random_bytes($length / 2));
}

function sendEmail($to, $subject, $message) {
    $headers = "From: " . APP_NAME . " <" . ADMIN_EMAIL . ">\r\n";
    $headers .= "Reply-To: " . ADMIN_EMAIL . "\r\n";
    $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
    
    return mail($to, $subject, $message, $headers);
}

function sendJSONResponse($success, $message, $data = null) {
    header('Content-Type: application/json');
    $response = [
        'success' => $success,
        'message' => $message
    ];
    if ($data !== null) {
        $response['data'] = $data;
    }
    echo json_encode($response);
    exit;
}

function requireAuth() {
    if (!isset($_SESSION['user_id']) && !isset($_SESSION['ngo_id']) && !isset($_SESSION['admin_id'])) {
        sendJSONResponse(false, 'Authentication required');
    }
}

function logActivity($userId, $userType, $action, $description = '') {
    $database = new Database();
    $db = $database->getConnection();
    
    $query = "INSERT INTO activity_logs (user_id, user_type, action, description, ip_address, user_agent) 
              VALUES (:user_id, :user_type, :action, :description, :ip_address, :user_agent)";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':user_id', $userId);
    $stmt->bindParam(':user_type', $userType);
    $stmt->bindParam(':action', $action);
    $stmt->bindParam(':description', $description);
    $stmt->bindParam(':ip_address', $_SERVER['REMOTE_ADDR']);
    $stmt->bindParam(':user_agent', $_SERVER['HTTP_USER_AGENT']);
    $stmt->execute();
}

function createNotification($userId, $ngoId, $teamMemberId, $title, $message, $type = 'info') {
    $database = new Database();
    $db = $database->getConnection();
    
    $query = "INSERT INTO notifications (user_id, ngo_id, team_member_id, title, message, type) 
              VALUES (:user_id, :ngo_id, :team_member_id, :title, :message, :type)";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':user_id', $userId);
    $stmt->bindParam(':ngo_id', $ngoId);
    $stmt->bindParam(':team_member_id', $teamMemberId);
    $stmt->bindParam(':title', $title);
    $stmt->bindParam(':message', $message);
    $stmt->bindParam(':type', $type);
    $stmt->execute();
}
?>
