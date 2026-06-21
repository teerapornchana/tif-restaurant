-- เปิดการใช้งาน UUID extension (เผื่อในระบบ Supabase ยังไม่ได้เปิด)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. สร้างตาราง tables (ข้อมูลโต๊ะ)
-- ==========================================
CREATE TABLE tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_number TEXT NOT NULL UNIQUE,
    zone TEXT NOT NULL,
    capacity INT NOT NULL,
    status TEXT NOT NULL DEFAULT 'available',
    pos_x FLOAT NOT NULL DEFAULT 0,
    pos_y FLOAT NOT NULL DEFAULT 0
);

-- ==========================================
-- 2. สร้างตาราง menu_items (ข้อมูลเมนูอาหาร)
-- ==========================================
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    category TEXT NOT NULL,
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true
);

-- ==========================================
-- 3. สร้างตาราง bookings (ข้อมูลการจองหลัก)
-- ==========================================
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    customer_line_id TEXT,
    allergies TEXT,
    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,
    pax INT NOT NULL,
    table_id UUID REFERENCES tables(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- 4. สร้างตาราง booking_orders (ข้อมูลการสั่งอาหารล่วงหน้า)
-- ==========================================
CREATE TABLE booking_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE RESTRICT,
    quantity INT NOT NULL DEFAULT 1,
    price_at_booking NUMERIC(10, 2) NOT NULL
);

-- ==========================================
-- การเพิ่มข้อมูลตัวอย่าง (Mock Data)
-- ==========================================

-- Insert Tables
INSERT INTO tables (id, table_number, zone, capacity, status, pos_x, pos_y) VALUES
('b3b3a6cd-c845-4235-8664-5a21ff7e5a62', 'T1', 'Indoor', 4, 'available', 120.5, 50.0),
('f13c61d5-bc49-411a-8219-fc2b604b901a', 'T2', 'Indoor', 2, 'available', 300.0, 50.0),
('6de34dbf-3147-497d-aa55-6b5df9dca5c7', 'T3', 'Indoor', 6, 'maintenance', 120.5, 150.0),
('a2d0ebcd-b2af-48a5-b17b-23253b3b4f66', 'OUT-1', 'Outdoor', 4, 'available', 450.0, 80.0),
('d406a4a6-787f-4b08-b118-24510ce25852', 'OUT-2', 'Outdoor', 8, 'available', 600.0, 80.0);

-- Insert Menu Items
INSERT INTO menu_items (id, name, price, category, image_url, is_active) VALUES
('7a14ecb3-dc42-4f96-9810-74cf8f830c23', 'Bread chilli', 60.00, 'ของทานเล่น', '/images/bread.jpg', true),
('e9b5f922-b5ab-4e92-af04-8b6fa2f1c841', 'แกงไข่มาซาล่า', 70.00, 'แกงกะหรี่', '/images/egg.jpg', true),
('2c28723c-f377-4a1e-8bc3-3b123d57b445', 'จาปาตี', 15.00, 'ของทานเล่น', '/images/roti.jpg', true),
('91efb054-d6a5-4eb5-bcfa-14d1dfaccd11', 'ไก่ทอดมาซาล่า', 70.00, 'แนะนำ', '/images/chicken.jpg', true),
('39bf7de1-b3b0-4f51-b8ef-fb2cb7bcaf74', 'ลาสซี่มะม่วง', 45.00, 'เครื่องดื่ม', '/images/lassi.jpg', false);

-- Insert Bookings
INSERT INTO bookings (id, customer_name, customer_phone, booking_date, booking_time, pax, table_id, status) VALUES
('9fbb2cf6-2e98-4c28-98e3-ea118de01089', 'สมชาย', '0812345678', '2026-06-25', '18:00:00', 4, 'b3b3a6cd-c845-4235-8664-5a21ff7e5a62', 'confirmed'),
('8ad6a25f-2877-47b2-bd78-9584d4458f27', 'สมหญิง', '0998765432', '2026-06-25', '19:30:00', 2, 'f13c61d5-bc49-411a-8219-fc2b604b901a', 'pending'),
('e8ebfb4a-2936-4148-bc6b-95bb389a9cd8', 'จอห์น', '0901112222', '2026-06-26', '12:00:00', 8, 'd406a4a6-787f-4b08-b118-24510ce25852', 'confirmed');

-- Insert Booking Orders
INSERT INTO booking_orders (booking_id, menu_item_id, quantity, price_at_booking) VALUES
('9fbb2cf6-2e98-4c28-98e3-ea118de01089', '7a14ecb3-dc42-4f96-9810-74cf8f830c23', 2, 60.00),
('9fbb2cf6-2e98-4c28-98e3-ea118de01089', '91efb054-d6a5-4eb5-bcfa-14d1dfaccd11', 1, 70.00),
('8ad6a25f-2877-47b2-bd78-9584d4458f27', 'e9b5f922-b5ab-4e92-af04-8b6fa2f1c841', 1, 70.00),
('e8ebfb4a-2936-4148-bc6b-95bb389a9cd8', '7a14ecb3-dc42-4f96-9810-74cf8f830c23', 4, 60.00),
('e8ebfb4a-2936-4148-bc6b-95bb389a9cd8', '2c28723c-f377-4a1e-8bc3-3b123d57b445', 8, 15.00);
