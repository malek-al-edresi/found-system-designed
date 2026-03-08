-- Create the LF_REPORTS table to store lost item reports
CREATE TABLE LF_REPORTS (
    REPORT_ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    STUDENT_ID VARCHAR2(50) NOT NULL,
    STUDENT_NAME VARCHAR2(200) NOT NULL,
    PHONE_NUMBER VARCHAR2(50),
    ITEM_TYPE VARCHAR2(100) NOT NULL,
    DESCRIPTION CLOB NOT NULL,
    LOCATION_LOST VARCHAR2(200),
    STATUS VARCHAR2(30),
    CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Create view for charting lost report counts by item type
CREATE OR REPLACE VIEW VIEW_CHART_LF_REPORTS AS
SELECT
    ITEM_TYPE,
    COUNT(*) AS REPORT_COUNT
FROM    
    LF_REPORTS
GROUP BY ITEM_TYPE;

-- Create table to store found items
CREATE TABLE LF_FOUND_ITEMS (
    ITEM_ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ITEM_TYPE VARCHAR2(100) NOT NULL,
    DESCRIPTION CLOB NOT NULL,
    STORAGE_LOCATION VARCHAR2(200),
    IMAGE_FILE BLOB,
    IMAGE_MIME_TYPE VARCHAR2(100),
    IMAGE_FILENAME VARCHAR2(200),
    STATUS VARCHAR2(30),
    CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Create view for charting found item counts by item type
CREATE OR REPLACE VIEW VIEW_CHART_LF_FOUND_ITEMS AS
SELECT 
    ITEM_TYPE,
    COUNT(*) AS FOUND_COUNT
FROM    
    LF_FOUND_ITEMS
GROUP BY ITEM_TYPE;

-- Create table to link lost reports with found items when matched
CREATE TABLE LF_MATCHES (
    MATCH_ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    REPORT_ID NUMBER NOT NULL,
    ITEM_ID NUMBER NOT NULL,
    MATCH_STATUS VARCHAR2(30),
    VERIFIED_BY VARCHAR2(100),
    VERIFIED_AT TIMESTAMP,
    CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP,
    
    CONSTRAINT FK_MATCH_REPORT
        FOREIGN KEY (REPORT_ID)
        REFERENCES LF_REPORTS(REPORT_ID),

    CONSTRAINT FK_MATCH_ITEM
        FOREIGN KEY (ITEM_ID)
        REFERENCES LF_FOUND_ITEMS(ITEM_ID)
);

-- Create view to show match details along with report and item information
CREATE OR REPLACE VIEW VIEW_MATCHES AS
SELECT M.MATCH_ID, M.REPORT_ID, M.ITEM_ID, M.MATCH_STATUS, M.VERIFIED_BY, M.VERIFIED_AT, M.CREATED_AT,
       R.STUDENT_ID, R.STUDENT_NAME, R.PHONE_NUMBER, R.ITEM_TYPE, R.DESCRIPTION AS REPORT_DESCRIPTION, R.LOCATION_LOST,
       I.DESCRIPTION AS ITEM_DESCRIPTION, I.STORAGE_LOCATION
FROM LF_MATCHES M
JOIN LF_REPORTS R ON M.REPORT_ID = R.REPORT_ID
JOIN LF_FOUND_ITEMS I ON M.ITEM_ID = I.ITEM_ID;

-- Create activity log table to track system events
CREATE TABLE LF_ACTIVITY_LOG (
    LOG_ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    USERNAME VARCHAR2(100),
    ACTION_TYPE VARCHAR2(200),
    EVENT_DATE TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Create users table for system authentication
CREATE TABLE USERS ( 
     USER_ID         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
     USER_NAME       VARCHAR2 (50)  NOT NULL , 
     PASSWORD_HASH   VARCHAR2 (255)  NOT NULL , 
     ACTIVE_USER     NUMBER, 
     ROLE_TYPE       VARCHAR2 (30),
     PHONE_NUMBER    VARCHAR2(50),
     EMAIL           VARCHAR2(50),
     LOGIN_COUNT     NUMBER DEFAULT 0
);

-- Create view for active users only
CREATE OR REPLACE VIEW VIEW_USERS AS
SELECT USER_ID, USER_NAME, ACTIVE_USER, ROLE_TYPE, PHONE_NUMBER, EMAIL
FROM USERS
WHERE ACTIVE_USER = 1;

-- Create temporary OTP table for admin authentication
CREATE TABLE ADMIN_OTP (
    USER_NAME VARCHAR2(100),
    OTP_CODE VARCHAR2(10),
    EXPIRES_AT TIMESTAMP
);

-------------------------------------
-- Insert sample data
-------------------------------------

-- Insert default users
INSERT INTO USERS (USER_NAME, PASSWORD_HASH, ACTIVE_USER, ROLE_TYPE, PHONE_NUMBER, EMAIL) VALUES 
('admin', '$2y$10$example_hashed_password_admin', 1, 'ADMIN', '+1234567890', 'admin@university.edu'),
('staff', '$2y$1ed_password_staff', 1, 'STAFF', '+1234567891', 'staff@university.edu'),
('student_services', '$2y$10$example_hashed_password_services', 1, 'STAFF', '+1234567892', 'student.services@university.edu');

-- Insert lost item reports
INSERT INTO LF_REPORTS (STUDENT_ID, STUDENT_NAME, PHONE_NUMBER, ITEM_TYPE, DESCRIPTION, LOCATION_LOST, STATUS) VALUES 
('STU001', 'Ahmed Mohamed', '+1234567890', 'Wallet', 'Black leather wallet containing ID cards and credit cards',', 'PENDING'),
('STU002', 'Fatima Ali', '+1234567891', 'Mobile Phone', 'Samsung Galaxy S22, black color with blue case', 'Cafeteria', 'PENDING'),
('STU003', 'Khalid Hassan', '+1234567892', 'Laptop', 'MacBook Pro 13-inch, space gray with university sticker', 'Computer Lab 3', 'RECEIVED'),
('STU00isha Omar', '+1234567893', 'Backpack', 'Red North Face backpack with books inside', 'Student Center', 'PENDING'),
('STU005', 'Omar Said', '+1234567894', 'Keys', 'Set of 5 keys with blue keychain', 'Parking Lot B', 'RECEIVED');

-- Insert found items
INSERT INTO LF_FOUND_ITEMS (ITEM_TYPE, DESCRIPTION, STORAGE_LOCATION, STATUS) VALUES 
('Wallet', 'Black leather wallet containing ID cards and credit cards', 'Lost & Found Office - Shelf A', 'AVAILABLE'),
('Mobile Phone', 'Samsung Galaxy S22, black color with blue case', 'Security Desk', 'AVAILABLE'),
('Laptop', 'MacBook Pro 13-inch, space gray with university sticker', 'Lost & Found Office - Shelf C', 'CLAIMED'),
('Backpack', 'Red North Face backpack with books inside', 'Lost & Found Office - Shelf B', 'AVAILABLE'),
('Keys', 'Set of 5 keys with blue keychain', 'Maintenance Office', 'CLAIMED'),
('Water Bottle', 'Blue stainless steel water bottle with university logo', 'Gymnasium', 'AVAILABLE'),
('Sunglasses', 'Ray-Ban aviator sunglasses in case', 'Outdoor Cafe', 'AVAILABLE');

-- Insert matches (when items are matched to reports)
INSERT INTO LF_MATCHES (REPORT_ID, ITEM_ID, MATCH_STATUS, VERIFIED_BY, VERIFIED_AT) VALUES 
(1, 1, 'VERIFIED', 'admin', SYSTIMESTAMP - INTERVAL '1' DAY),
(3, 3, 'VERIFIED', 'staff', SYSTIMESTAMP - INTERVAL '3' DAY),
(5, 5, 'VERIFIED', 'admin', SYSTIMESTAMP - INTERVAL '2' DAY);

COMMIT;