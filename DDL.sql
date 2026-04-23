CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS public.mock_data (
    id INT,
    customer_first_name VARCHAR(100),
    customer_last_name VARCHAR(100),
    customer_age INT,
    customer_email VARCHAR(255),
    customer_country VARCHAR(100),
    customer_postal_code VARCHAR(50),
    customer_pet_type VARCHAR(50),
    customer_pet_name VARCHAR(100),
    customer_pet_breed VARCHAR(100),
    seller_first_name VARCHAR(100),
    seller_last_name VARCHAR(100),
    seller_email VARCHAR(255),
    seller_country VARCHAR(100),
    seller_postal_code VARCHAR(50),
    product_name VARCHAR(255),
    product_category VARCHAR(100),
    product_price NUMERIC(10,2),
    product_quantity INT,
    sale_date DATE,
    sale_customer_id INT,
    sale_seller_id INT,
    sale_product_id INT,
    sale_quantity INT,
    sale_total_price NUMERIC(10,2),
    store_name VARCHAR(255),
    store_location VARCHAR(100),
    store_city VARCHAR(100),
    store_state VARCHAR(50),
    store_country VARCHAR(100),
    store_phone VARCHAR(50),
    store_email VARCHAR(255),
    pet_category VARCHAR(100),
    product_weight NUMERIC(10,2),
    product_color VARCHAR(50),
    product_size VARCHAR(50),
    product_brand VARCHAR(100),
    product_material VARCHAR(100),
    product_description TEXT,
    product_rating NUMERIC(3,1),
    product_reviews INT,
    product_release_date DATE,
    product_expiry_date DATE,
    supplier_name VARCHAR(255),
    supplier_contact VARCHAR(255),
    supplier_email VARCHAR(255),
    supplier_phone VARCHAR(50),
    supplier_address VARCHAR(255),
    supplier_city VARCHAR(100),
    supplier_country VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS analytics.dim_category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE,
    pet_category VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS analytics.dim_brand (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS analytics.dim_color (
    color_id SERIAL PRIMARY KEY,
    color_name VARCHAR(50) UNIQUE
);

CREATE TABLE IF NOT EXISTS analytics.dim_size (
    size_id SERIAL PRIMARY KEY,
    size_name VARCHAR(50) UNIQUE
);

CREATE TABLE IF NOT EXISTS analytics.dim_material (
    material_id SERIAL PRIMARY KEY,
    material_name VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS analytics.dim_product (
    product_id SERIAL PRIMARY KEY,
    source_product_id INT UNIQUE,
    product_name VARCHAR(255),
    product_price NUMERIC(10,2),
    product_weight NUMERIC(10,2),
    product_rating NUMERIC(3,1),
    product_reviews INT,
    product_release_date DATE,
    product_expiry_date DATE,
    category_id INT REFERENCES analytics.dim_category(category_id),
    brand_id INT REFERENCES analytics.dim_brand(brand_id),
    color_id INT REFERENCES analytics.dim_color(color_id),
    size_id INT REFERENCES analytics.dim_size(size_id),
    material_id INT REFERENCES analytics.dim_material(material_id)
);

CREATE TABLE IF NOT EXISTS analytics.dim_country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS analytics.dim_pet_type (
    pet_type_id SERIAL PRIMARY KEY,
    pet_type_name VARCHAR(50) UNIQUE
);

CREATE TABLE IF NOT EXISTS analytics.dim_customer (
    customer_id SERIAL PRIMARY KEY,
    source_customer_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(200),
    age INT,
    email VARCHAR(255) UNIQUE,
    postal_code VARCHAR(50),
    pet_name VARCHAR(100),
    pet_breed VARCHAR(100),
    country_id INT REFERENCES analytics.dim_country(country_id),
    pet_type_id INT REFERENCES analytics.dim_pet_type(pet_type_id)
);

CREATE TABLE IF NOT EXISTS analytics.dim_seller (
    seller_id SERIAL PRIMARY KEY,
    source_seller_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(200),
    email VARCHAR(255) UNIQUE,
    postal_code VARCHAR(50),
    country_id INT REFERENCES analytics.dim_country(country_id)
);

CREATE TABLE IF NOT EXISTS analytics.dim_city (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100),
    state VARCHAR(50),
    country_id INT REFERENCES analytics.dim_country(country_id),
    UNIQUE(city_name, state, country_id)
);

CREATE TABLE IF NOT EXISTS analytics.dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255) UNIQUE,
    store_location VARCHAR(100),
    store_phone VARCHAR(50),
    store_email VARCHAR(255),
    city_id INT REFERENCES analytics.dim_city(city_id)
);

CREATE TABLE IF NOT EXISTS analytics.dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255) UNIQUE,
    supplier_contact VARCHAR(255),
    supplier_email VARCHAR(255),
    supplier_phone VARCHAR(50),
    supplier_address VARCHAR(255),
    city_id INT REFERENCES analytics.dim_city(city_id),
    country_id INT REFERENCES analytics.dim_country(country_id)
);

CREATE TABLE IF NOT EXISTS analytics.dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT,
    day_of_week INT,
    weekday_name VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS analytics.fact_sales (
    sale_id SERIAL PRIMARY KEY,
    date_id INT REFERENCES analytics.dim_date(date_id),
    product_id INT REFERENCES analytics.dim_product(product_id),
    customer_id INT REFERENCES analytics.dim_customer(customer_id),
    seller_id INT REFERENCES analytics.dim_seller(seller_id),
    store_id INT REFERENCES analytics.dim_store(store_id),
    supplier_id INT REFERENCES analytics.dim_supplier(supplier_id),
    quantity INT,
    total_amount NUMERIC(10,2)
);
