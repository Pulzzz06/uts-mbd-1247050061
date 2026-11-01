-- ============================================================================
-- BAGIAN 1: PEMBUATAN 3 USER BARU & PEMBERIAN HAK AKSES (SOAL 4)
-- ============================================================================
RESET ROLE;

CREATE USER backend_dev WITH PASSWORD 'backend_pass';
CREATE USER bi_dev WITH PASSWORD 'bi_pass';
CREATE USER data_engineer WITH PASSWORD 'de_pass';

GRANT CONNECT ON DATABASE salam_db TO backend_dev, bi_dev, data_engineer;

-- 4a. Role backend_dev: CRUD semua table
GRANT USAGE ON SCHEMA SALAM TO backend_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA SALAM TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA SALAM TO backend_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA SALAM
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;

-- 4b. Role bi_dev: Hanya READ / SELECT semua table dan view
GRANT USAGE ON SCHEMA SALAM TO bi_dev;
GRANT SELECT ON ALL TABLES IN SCHEMA SALAM TO bi_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA SALAM
    GRANT SELECT ON TABLES TO bi_dev;

-- 4c. Role data_engineer: CREATE, MODIFY, DROP semua objects & CRUD semua table
GRANT ALL PRIVILEGES ON SCHEMA SALAM TO data_engineer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SALAM TO data_engineer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA SALAM TO data_engineer;

ALTER SCHEMA SALAM OWNER TO data_engineer;
ALTER TABLE SALAM.mahasiswas OWNER TO data_engineer;
ALTER VIEW SALAM.vw_rekap_mahasiswa OWNER TO data_engineer;
ALTER FUNCTION SALAM.fn_update_timestamp() OWNER TO data_engineer;


-- ============================================================================
-- BAGIAN 2: PEMBUKTIAN ROLE backend_dev (SOAL 4A)
-- ============================================================================

-- UJI 4A-1: Buktikan backend_dev berhasil CRUD (INSERT, UPDATE, DELETE, SELECT)
RESET ROLE;
SET ROLE backend_dev;
INSERT INTO SALAM.mahasiswas (nim, nama_lengkap, email_kampus, angkatan, semester, ipk)
VALUES ('1247050077', 'Mahasiswa Uji Backend', 'backend@student.uinsgd.ac.id', 2024, 5, 3.60);
UPDATE SALAM.mahasiswas SET ipk = 3.75 WHERE nim = '1247050077';
DELETE FROM SALAM.mahasiswas WHERE nim = '1247050077';
SELECT CURRENT_USER AS role_aktif, * FROM SALAM.mahasiswas;

-- UJI 4A-2: Buktikan backend_dev ditolak membuat tabel baru (DDL)
CREATE TABLE SALAM.tes_tabel_backend (id INT);


-- ============================================================================
-- BAGIAN 3: PEMBUKTIAN ROLE bi_dev (SOAL 4B)
-- ============================================================================

-- UJI 4B-1: Buktikan bi_dev berhasil membaca (SELECT) View dan Tabel
RESET ROLE;
SET ROLE bi_dev;
SELECT CURRENT_USER AS role_aktif, * FROM SALAM.vw_rekap_mahasiswa;

-- UJI 4B-2: Buktikan bi_dev ditolak melakukan modifikasi data (CRUD)
UPDATE SALAM.mahasiswas SET ipk = 4.00 WHERE nim = '1247050061';


-- ============================================================================
-- BAGIAN 4: PEMBUKTIAN ROLE data_engineer (SOAL 4C)
-- ============================================================================

-- UJI 4C-1: Buktikan data_engineer berhasil CREATE, MODIFY (ALTER), dan CRUD
RESET ROLE;
SET ROLE data_engineer;
CREATE TABLE SALAM.log_aktivitas_akademik (
    id_log SERIAL PRIMARY KEY,
    nim CHAR(10) REFERENCES SALAM.mahasiswas(nim),
    aktivitas VARCHAR(100) NOT NULL
);
ALTER TABLE SALAM.log_aktivitas_akademik
ADD COLUMN waktu_catat TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
INSERT INTO SALAM.log_aktivitas_akademik (nim, aktivitas)
VALUES ('1247050061', 'Perwalian Semester Ganjil');
SELECT CURRENT_USER AS role_aktif, * FROM SALAM.log_aktivitas_akademik;

-- UJI 4C-2: Buktikan data_engineer berhasil DROP object
DROP TABLE SALAM.log_aktivitas_akademik;
RESET ROLE;
