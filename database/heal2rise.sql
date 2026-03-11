-- Heal2Rise Book Database Schema
-- Social Welfare Management System
-- Created for: CS619 Fall 2025

CREATE DATABASE IF NOT EXISTS heal2rise_book CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE heal2rise_book;

-- Users Table (Individuals seeking help)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    age INT,
    gender ENUM('male', 'female', 'other'),
    address TEXT,
    city VARCHAR(50),
    country VARCHAR(50) DEFAULT 'Pakistan',
    issue_category ENUM('depression', 'hopelessness', 'family_issues', 'marital_issues', 'other') NOT NULL,
    issue_description TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    profile_image VARCHAR(255),
    status ENUM('pending', 'active', 'under_counseling', 'in_rehabilitation', 'recovered', 'closed') DEFAULT 'pending',
    assigned_ngo_id INT DEFAULT NULL,
    assigned_team_member_id INT DEFAULT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    privacy_agreement BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_assigned_ngo (assigned_ngo_id)
);

-- NGOs Table
CREATE TABLE ngos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    organization_name VARCHAR(150) NOT NULL,
    registration_number VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    website VARCHAR(100),
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) DEFAULT 'Pakistan',
    description TEXT,
    services_offered TEXT,
    logo VARCHAR(255),
    status ENUM('pending', 'approved', 'rejected', 'suspended') DEFAULT 'pending',
    admin_notes TEXT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_date TIMESTAMP NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    INDEX idx_email (email),
    INDEX idx_status (status)
);

-- Admin Table
CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role ENUM('super_admin', 'admin', 'moderator') DEFAULT 'admin',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Team Members (NGO Staff/Counselors)
CREATE TABLE team_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ngo_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    designation ENUM('counselor', 'psychiatrist', 'social_worker', 'coordinator', 'volunteer') NOT NULL,
    specialization VARCHAR(100),
    qualifications TEXT,
    experience_years INT,
    profile_image VARCHAR(255),
    status ENUM('active', 'inactive', 'on_leave') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ngo_id) REFERENCES ngos(id) ON DELETE CASCADE,
    INDEX idx_ngo_id (ngo_id),
    INDEX idx_designation (designation)
);

-- User-NGO Connections
CREATE TABLE user_ngo_connections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    ngo_id INT NOT NULL,
    team_member_id INT,
    connection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'accepted', 'rejected', 'completed') DEFAULT 'pending',
    priority_level ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    admin_notes TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (ngo_id) REFERENCES ngos(id) ON DELETE CASCADE,
    FOREIGN KEY (team_member_id) REFERENCES team_members(id) ON DELETE SET NULL,
    UNIQUE KEY unique_user_ngo (user_id, ngo_id)
);

-- Counseling Sessions
CREATE TABLE counseling_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    ngo_id INT NOT NULL,
    team_member_id INT NOT NULL,
    session_type ENUM('video', 'audio', 'chat', 'in_person') DEFAULT 'video',
    meeting_link VARCHAR(255),
    meeting_platform ENUM('zoom', 'google_meet', 'teams', 'other') DEFAULT 'zoom',
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    duration_minutes INT DEFAULT 60,
    status ENUM('scheduled', 'in_progress', 'completed', 'cancelled', 'no_show') DEFAULT 'scheduled',
    notes TEXT,
    feedback_rating INT,
    feedback_comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (ngo_id) REFERENCES ngos(id) ON DELETE CASCADE,
    FOREIGN KEY (team_member_id) REFERENCES team_members(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_scheduled_date (scheduled_date),
    INDEX idx_status (status)
);

-- Progress Tracking
CREATE TABLE progress_tracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    team_member_id INT NOT NULL,
    assessment_date DATE NOT NULL,
    mental_health_score INT CHECK (mental_health_score BETWEEN 1 AND 10),
    confidence_level INT CHECK (confidence_level BETWEEN 1 AND 10),
    skill_development TEXT,
    goals_achieved TEXT,
    challenges_faced TEXT,
    next_steps TEXT,
    overall_progress ENUM('poor', 'fair', 'good', 'excellent') DEFAULT 'fair',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (team_member_id) REFERENCES team_members(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_assessment_date (assessment_date)
);

-- Skills & Training
CREATE TABLE skills_training (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ngo_id INT NOT NULL,
    skill_name VARCHAR(100) NOT NULL,
    description TEXT,
    category ENUM('vocational', 'life_skills', 'communication', 'technical', 'creative', 'other'),
    duration_weeks INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ngo_id) REFERENCES ngos(id) ON DELETE CASCADE
);

-- User Skills Enrollment
CREATE TABLE user_skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    skill_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_date DATE,
    progress_percent INT DEFAULT 0,
    status ENUM('enrolled', 'in_progress', 'completed', 'dropped') DEFAULT 'enrolled',
    certificate_issued BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills_training(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_skill (user_id, skill_id)
);

-- Rehabilitation Records
CREATE TABLE rehabilitation_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    ngo_id INT NOT NULL,
    admission_date DATE NOT NULL,
    expected_duration_days INT,
    actual_discharge_date DATE,
    accommodation_type ENUM('residential', 'day_care', 'outpatient') DEFAULT 'residential',
    treatment_plan TEXT,
    daily_activities TEXT,
    medications TEXT,
    progress_notes TEXT,
    status ENUM('admitted', 'in_treatment', 'ready_for_discharge', 'discharged') DEFAULT 'admitted',
    discharge_summary TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (ngo_id) REFERENCES ngos(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);

-- Donations
CREATE TABLE donations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    donor_name VARCHAR(100),
    donor_email VARCHAR(100),
    donor_phone VARCHAR(20),
    ngo_id INT,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'PKR',
    payment_method ENUM('credit_card', 'debit_card', 'bank_transfer', 'easypaisa', 'jazzcash', 'paypal') NOT NULL,
    transaction_id VARCHAR(100),
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    message TEXT,
    is_anonymous BOOLEAN DEFAULT FALSE,
    donation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ngo_id) REFERENCES ngos(id) ON DELETE SET NULL,
    INDEX idx_payment_status (payment_status)
);

-- Notifications
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    ngo_id INT,
    team_member_id INT,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'success', 'warning', 'error', 'reminder') DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (ngo_id) REFERENCES ngos(id) ON DELETE CASCADE,
    FOREIGN KEY (team_member_id) REFERENCES team_members(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read)
);

-- Messages/Chat
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    sender_type ENUM('user', 'ngo', 'team_member', 'admin') NOT NULL,
    receiver_id INT NOT NULL,
    receiver_type ENUM('user', 'ngo', 'team_member', 'admin') NOT NULL,
    message TEXT NOT NULL,
    attachment VARCHAR(255),
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sender (sender_id, sender_type),
    INDEX idx_receiver (receiver_id, receiver_type),
    INDEX idx_is_read (is_read)
);

-- Activity Logs
CREATE TABLE activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    user_type ENUM('user', 'ngo', 'team_member', 'admin') NOT NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- Case Closure Records
CREATE TABLE case_closures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    ngo_id INT NOT NULL,
    team_member_id INT NOT NULL,
    closure_date DATE NOT NULL,
    closure_reason TEXT NOT NULL,
    outcome_summary TEXT,
    user_satisfaction INT CHECK (user_satisfaction BETWEEN 1 AND 5),
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_date DATE,
    is_successful BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (ngo_id) REFERENCES ngos(id) ON DELETE CASCADE,
    FOREIGN KEY (team_member_id) REFERENCES team_members(id) ON DELETE CASCADE
);

-- Insert Default Admin
INSERT INTO admins (username, email, password_hash, full_name, role) VALUES 
('admin', 'admin@heal2rise.org', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System Administrator', 'super_admin');
-- Default password: password

-- Insert Sample NGOs
INSERT INTO ngos (organization_name, registration_number, email, password_hash, phone, address, city, description, services_offered, status) VALUES
('Hope Foundation', 'REG-001-PAK', 'contact@hopefoundation.org', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+92-21-1234567', '123 Main Street', 'Karachi', 'Dedicated to mental health support and rehabilitation', 'Counseling, Rehabilitation, Skill Development', 'approved'),
('Care & Cure NGO', 'REG-002-PAK', 'info@carecure.org', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+92-21-7654321', '456 Care Avenue', 'Karachi', 'Providing support for individuals facing family and marital issues', 'Family Counseling, Mediation, Legal Aid', 'approved');

-- Insert Sample Skills
INSERT INTO skills_training (ngo_id, skill_name, description, category, duration_weeks) VALUES
(1, 'Basic Computer Skills', 'Learn fundamental computer operations and MS Office', 'technical', 4),
(1, 'Communication Skills', 'Develop effective communication and interpersonal skills', 'life_skills', 6),
(2, 'Sewing & Stitching', 'Learn sewing techniques for income generation', 'vocational', 8),
(2, 'Stress Management', 'Techniques to manage stress and anxiety', 'life_skills', 4);
