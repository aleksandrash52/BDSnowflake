INSERT INTO analytics.dim_category (category_name, pet_category)
SELECT DISTINCT product_category, pet_category
FROM public.mock_data
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO analytics.dim_brand (brand_name)
SELECT DISTINCT product_brand
FROM public.mock_data
WHERE product_brand IS NOT NULL
ON CONFLICT (brand_name) DO NOTHING;

INSERT INTO analytics.dim_color (color_name)
SELECT DISTINCT product_color
FROM public.mock_data
WHERE product_color IS NOT NULL
ON CONFLICT (color_name) DO NOTHING;

INSERT INTO analytics.dim_size (size_name)
SELECT DISTINCT product_size
FROM public.mock_data
WHERE product_size IS NOT NULL
ON CONFLICT (size_name) DO NOTHING;

INSERT INTO analytics.dim_material (material_name)
SELECT DISTINCT product_material
FROM public.mock_data
WHERE product_material IS NOT NULL
ON CONFLICT (material_name) DO NOTHING;

INSERT INTO analytics.dim_product (
    source_product_id, product_name, product_price, product_weight,
    product_rating, product_reviews, product_release_date, product_expiry_date,
    category_id, brand_id, color_id, size_id, material_id
)
SELECT DISTINCT
    sale_product_id,
    product_name,
    product_price,
    product_weight,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date,
    cat.category_id,
    b.brand_id,
    col.color_id,
    s.size_id,
    m.material_id
FROM public.mock_data md
LEFT JOIN analytics.dim_category cat ON md.product_category = cat.category_name
LEFT JOIN analytics.dim_brand b ON md.product_brand = b.brand_name
LEFT JOIN analytics.dim_color col ON md.product_color = col.color_name
LEFT JOIN analytics.dim_size s ON md.product_size = s.size_name
LEFT JOIN analytics.dim_material m ON md.product_material = m.material_name
ON CONFLICT (source_product_id) DO NOTHING;

INSERT INTO analytics.dim_country (country_name)
SELECT DISTINCT customer_country FROM public.mock_data
UNION
SELECT DISTINCT seller_country FROM public.mock_data
UNION
SELECT DISTINCT store_country FROM public.mock_data
UNION
SELECT DISTINCT supplier_country FROM public.mock_data
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO analytics.dim_pet_type (pet_type_name)
SELECT DISTINCT customer_pet_type
FROM public.mock_data
WHERE customer_pet_type IS NOT NULL
ON CONFLICT (pet_type_name) DO NOTHING;

INSERT INTO analytics.dim_customer (
    source_customer_id, first_name, last_name, full_name,
    age, email, postal_code, pet_name, pet_breed,
    country_id, pet_type_id
)
SELECT DISTINCT
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    CONCAT(customer_first_name, ' ', customer_last_name),
    customer_age,
    customer_email,
    customer_postal_code,
    customer_pet_name,
    customer_pet_breed,
    c.country_id,
    pt.pet_type_id
FROM public.mock_data md
LEFT JOIN analytics.dim_country c ON md.customer_country = c.country_name
LEFT JOIN analytics.dim_pet_type pt ON md.customer_pet_type = pt.pet_type_name
ON CONFLICT (email) DO NOTHING;

INSERT INTO analytics.dim_seller (
    source_seller_id, first_name, last_name, full_name,
    email, postal_code, country_id
)
SELECT DISTINCT
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    CONCAT(seller_first_name, ' ', seller_last_name),
    seller_email,
    seller_postal_code,
    c.country_id
FROM public.mock_data md
LEFT JOIN analytics.dim_country c ON md.seller_country = c.country_name
ON CONFLICT (email) DO NOTHING;

INSERT INTO analytics.dim_city (city_name, state, country_id)
SELECT DISTINCT
    store_city,
    store_state,
    c.country_id
FROM public.mock_data md
LEFT JOIN analytics.dim_country c ON md.store_country = c.country_name
WHERE store_city IS NOT NULL
ON CONFLICT (city_name, state, country_id) DO NOTHING;

INSERT INTO analytics.dim_store (
    store_name, store_location, store_phone, store_email, city_id
)
SELECT DISTINCT
    store_name,
    store_location,
    store_phone,
    store_email,
    ct.city_id
FROM public.mock_data md
LEFT JOIN analytics.dim_city ct ON md.store_city = ct.city_name AND md.store_state = ct.state
ON CONFLICT (store_name) DO NOTHING;

INSERT INTO analytics.dim_supplier (
    supplier_name, supplier_contact, supplier_email, supplier_phone,
    supplier_address, city_id, country_id
)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    ct.city_id,
    c.country_id
FROM public.mock_data md
LEFT JOIN analytics.dim_city ct ON md.supplier_city = ct.city_name
LEFT JOIN analytics.dim_country c ON md.supplier_country = c.country_name
ON CONFLICT (supplier_name) DO NOTHING;


INSERT INTO analytics.dim_date (full_date, year, quarter, month, month_name, day, day_of_week, weekday_name)
SELECT DISTINCT
    sale_date,
    EXTRACT(YEAR FROM sale_date)::INT,
    EXTRACT(QUARTER FROM sale_date)::INT,
    EXTRACT(MONTH FROM sale_date)::INT,
    TO_CHAR(sale_date, 'Month'),
    EXTRACT(DAY FROM sale_date)::INT,
    EXTRACT(DOW FROM sale_date)::INT,
    TO_CHAR(sale_date, 'Day')
FROM public.mock_data
ON CONFLICT (full_date) DO NOTHING;


INSERT INTO analytics.fact_sales (
    date_id, product_id, customer_id, seller_id, store_id, supplier_id,
    quantity, total_amount
)
SELECT
    d.date_id,
    p.product_id,
    c.customer_id,
    s.seller_id,
    st.store_id,
    sup.supplier_id,
    md.sale_quantity,
    md.sale_total_price
FROM public.mock_data md
JOIN analytics.dim_date d ON md.sale_date = d.full_date
JOIN analytics.dim_product p ON md.sale_product_id = p.source_product_id
JOIN analytics.dim_customer c ON md.customer_email = c.email
JOIN analytics.dim_seller s ON md.seller_email = s.email
JOIN analytics.dim_store st ON md.store_name = st.store_name
JOIN analytics.dim_supplier sup ON md.supplier_name = sup.supplier_name;
