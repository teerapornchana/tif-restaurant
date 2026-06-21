require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');

// The script will use the DATABASE_URL from your .env file
const connectionString = process.env.DATABASE_URL;

async function run() {
    if (!connectionString) {
        console.error('====================================================');
        console.error('❌ Error: ไม่พบการตั้งค่า DATABASE_URL');
        console.error('กรุณาสร้างไฟล์ .env ในโฟลเดอร์นี้ แล้วใส่ข้อความดังนี้:');
        console.error('DATABASE_URL=postgres://[user]:[password]@[host]:[port]/[db]');
        console.error('โดยเอา URL มาจากหน้า Supabase -> Settings -> Database -> Connection string');
        console.error('====================================================');
        process.exit(1);
    }

    const client = new Client({
        connectionString,
        ssl: { rejectUnauthorized: false } // Required for Supabase
    });

    try {
        console.log('🔄 กำลังเชื่อมต่อกับฐานข้อมูล Supabase...');
        await client.connect();
        console.log('✅ เชื่อมต่อสำเร็จ!');

        const sql = fs.readFileSync('init_supabase.sql', 'utf8');
        console.log('⏳ กำลังรันสคริปต์ SQL เพื่อสร้างตารางและข้อมูลตัวอย่าง...');
        
        await client.query(sql);
        console.log('🎉 รันคำสั่ง SQL เสร็จสิ้น! ตารางและข้อมูลพร้อมใช้งานแล้วครับ');
    } catch (err) {
        console.error('❌ เกิดข้อผิดพลาดในฐานข้อมูล:', err.message);
    } finally {
        await client.end();
    }
}

run();
