
USE Ecommerce;

SHOW DATABASES;

-- 1. USER TABLE
CREATE TABLE USER (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('customer','vendor','admin') NOT NULL,
    created_at DATETIME DEFAULT NOW()
);

-- 2. VENDOR TABLE
CREATE TABLE VENDOR (
    vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    shop_name VARCHAR(150) NOT NULL,
    shop_description TEXT,
    address VARCHAR(255),
    joined_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (user_id)
    REFERENCES USER(user_id)
    ON DELETE CASCADE
);

-- 3. CATEGORY TABLE
CREATE TABLE CATEGORY (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- 4. PRODUCT TABLE
CREATE TABLE PRODUCT (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_qty INT DEFAULT 0,
    image_url VARCHAR(300),
    created_at DATETIME DEFAULT NOW(),
    
    FOREIGN KEY (vendor_id)
    REFERENCES VENDOR(vendor_id)
    ON DELETE CASCADE,

    FOREIGN KEY (category_id)
    REFERENCES CATEGORY(category_id)
);

-- 5. ADDRESS TABLE
CREATE TABLE ADDRESS (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL DEFAULT 'Pakistan',
    address_type ENUM('billing','shipping'),

    FOREIGN KEY (user_id)
    REFERENCES USER(user_id)
    ON DELETE CASCADE
);

-- 6. CART TABLE
CREATE TABLE CART (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    added_at DATETIME DEFAULT NOW(),

    UNIQUE (user_id, product_id),

    FOREIGN KEY (user_id)
    REFERENCES USER(user_id)
    ON DELETE CASCADE,

    FOREIGN KEY (product_id)
    REFERENCES PRODUCT(product_id)
    ON DELETE CASCADE
);

-- 7. ORDER TABLE
CREATE TABLE `ORDER` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    billing_address_id INT NOT NULL,
    shipping_address_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,

    status ENUM(
        'pending',
        'processing',
        'shipped',
        'delivered',
        'cancelled'
    ) NOT NULL,

    ordered_at DATETIME DEFAULT NOW(),

    FOREIGN KEY (user_id)
    REFERENCES USER(user_id),

    FOREIGN KEY (billing_address_id)
    REFERENCES ADDRESS(address_id),

    FOREIGN KEY (shipping_address_id)
    REFERENCES ADDRESS(address_id)
);

-- 8. ORDER_ITEM TABLE
CREATE TABLE ORDER_ITEM (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (order_id)
    REFERENCES `ORDER`(order_id)
    ON DELETE CASCADE,

    FOREIGN KEY (product_id)
    REFERENCES PRODUCT(product_id)
);

-- 9. BILLING_METHOD TABLE
CREATE TABLE BILLING_METHOD (
    billing_method_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,

    method_type ENUM(
        'cash_on_delivery',
        'easypaisa',
        'jazzcash',
        'card'
    ) NOT NULL,

    account_title VARCHAR(150),
    account_number VARCHAR(50),
    card_last4 VARCHAR(4),
    card_brand VARCHAR(30),
    is_default BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (user_id)
    REFERENCES USER(user_id)
    ON DELETE CASCADE
);

-- 10. PAYMENT TABLE
CREATE TABLE PAYMENT (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    billing_method_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,

    status ENUM(
        'pending',
        'completed',
        'failed'
    ) NOT NULL,

    paid_at DATETIME,

    FOREIGN KEY (order_id)
    REFERENCES `ORDER`(order_id),

    FOREIGN KEY (billing_method_id)
    REFERENCES BILLING_METHOD(billing_method_id)
);

-- 11. SHIPMENT TABLE
CREATE TABLE SHIPMENT (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    shipping_address_id INT NOT NULL,
    courier_name VARCHAR(100),
    tracking_number VARCHAR(100),

    shipment_status ENUM(
        'pending',
        'dispatched',
        'in_transit',
        'delivered'
    ) NOT NULL DEFAULT 'pending',

    shipped_at DATETIME,
    estimated_delivery DATETIME,

    FOREIGN KEY (order_id)
    REFERENCES `ORDER`(order_id),

    FOREIGN KEY (shipping_address_id)
    REFERENCES ADDRESS(address_id)
);

-- 12. REVIEW TABLE
CREATE TABLE REVIEW (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,

    rating INT NOT NULL
    CHECK (rating BETWEEN 1 AND 5),

    comment TEXT,
    reviewed_at DATETIME DEFAULT NOW(),

    FOREIGN KEY (user_id)
    REFERENCES USER(user_id)
    ON DELETE CASCADE,

    FOREIGN KEY (product_id)
    REFERENCES PRODUCT(product_id)
    ON DELETE CASCADE
);

-- INDEXES

CREATE INDEX idx_vendor_user
ON VENDOR(user_id);

CREATE INDEX idx_product_vendor
ON PRODUCT(vendor_id);

CREATE INDEX idx_product_category
ON PRODUCT(category_id);

CREATE INDEX idx_product_price
ON PRODUCT(price);

CREATE INDEX idx_cart_user
ON CART(user_id);

CREATE INDEX idx_cart_product
ON CART(product_id);

CREATE INDEX idx_address_user
ON ADDRESS(user_id);

CREATE INDEX idx_order_user
ON `ORDER`(user_id);

CREATE INDEX idx_order_billing_addr
ON `ORDER`(billing_address_id);

CREATE INDEX idx_order_ship_addr
ON `ORDER`(shipping_address_id);

CREATE INDEX idx_order_status
ON `ORDER`(status);

CREATE INDEX idx_order_item_order
ON ORDER_ITEM(order_id);

CREATE INDEX idx_order_item_product
ON ORDER_ITEM(product_id);

CREATE INDEX idx_billing_user
ON BILLING_METHOD(user_id);

CREATE INDEX idx_payment_order
ON PAYMENT(order_id);

CREATE INDEX idx_payment_billing
ON PAYMENT(billing_method_id);

CREATE INDEX idx_payment_status
ON PAYMENT(status);

CREATE INDEX idx_shipment_order
ON SHIPMENT(order_id);

CREATE INDEX idx_shipment_addr
ON SHIPMENT(shipping_address_id);

CREATE INDEX idx_review_user
ON REVIEW(user_id);

CREATE INDEX idx_review_product
ON REVIEW(product_id);

UPDATE `order`
SET status = 'shipped'
WHERE order_id = 5;

UPDATE product
SET stock_qty = stock_qty - 2
WHERE product_id = 12;

DELETE FROM payment
WHERE order_id = 8
AND status = 'failed';

SELECT COUNT(*) AS user_rows FROM `USER`;

SELECT COUNT(*) AS vendor_rows FROM VENDOR;

SELECT COUNT(*) AS category_rows FROM CATEGORY;

SELECT COUNT(*) AS product_rows FROM PRODUCT;

SELECT COUNT(*) AS address_rows FROM ADDRESS;

SELECT COUNT(*) AS cart_rows FROM CART;

SELECT COUNT(*) AS order_rows FROM `ORDER`;

SELECT COUNT(*) AS order_item_rows FROM ORDER_ITEM;

SELECT COUNT(*) AS billing_method_rows FROM BILLING_METHOD;

SELECT COUNT(*) AS payment_rows FROM PAYMENT;

SELECT COUNT(*) AS shipment_rows FROM SHIPMENT;

SELECT COUNT(*) AS review_rows FROM REVIEW;

SELECT COUNT(*) AS null_emails FROM `USER` WHERE email IS NULL;

SELECT COUNT(*) AS null_prices FROM PRODUCT WHERE price IS NULL;

SELECT COUNT(*) AS null_amounts FROM PAYMENT WHERE amount IS NULL;