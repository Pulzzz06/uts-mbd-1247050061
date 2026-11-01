-- ============================================================================
-- BAGIAN 1: PEMBUATAN SKEMA SALAM & TABEL MAHASISWAS (SOAL 3)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS SALAM;

CREATE TABLE SALAM.mahasiswas (
    nim CHAR(10) CONSTRAINT pk_mahasiswas_nim PRIMARY KEY,
    nama_lengkap VARCHAR(100) NOT NULL,
    email_kampus VARCHAR(100) NOT NULL CONSTRAINT uq_mahasiswas_email UNIQUE,
    angkatan INT NOT NULL CONSTRAINT chk_mahasiswas_angkatan CHECK (angkatan >= 2018 AND angkatan <= 2026),
    semester INT NOT NULL CONSTRAINT chk_mahasiswas_semester CHECK (semester BETWEEN 1 AND 14),
    ipk NUMERIC(3, 2) NOT NULL CONSTRAINT chk_mahasiswas_ipk CHECK (ipk >= 0.00 AND ipk <= 4.00),
    status_akademik VARCHAR(15) DEFAULT 'Aktif' CONSTRAINT chk_mahasiswas_status CHECK (status_akademik IN ('Aktif', 'Cuti', 'Lulus', 'Nonaktif')),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- BAGIAN 2: FITUR PEMBEDA (TRIGGER OTOMATIS, VIEW, & TRANSAKSI SAVEPOINT)
-- ============================================================================
-- 1. Trigger otomatis memperbarui kolom updated_at saat data mahasiswa diubah
CREATE OR REPLACE FUNCTION SALAM.fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mahasiswas_updated_at
BEFORE UPDATE ON SALAM.mahasiswas
FOR EACH ROW
EXECUTE FUNCTION SALAM.fn_update_timestamp();

-- 2. View Rekapitulasi Predikat Mahasiswa
CREATE OR REPLACE VIEW SALAM.vw_rekap_mahasiswa AS
SELECT 
    nim,
    nama_lengkap,
    angkatan,
    semester,
    ipk,
    CASE 
        WHEN ipk >= 3.51 THEN 'Cumlaude'
        WHEN ipk >= 3.01 THEN 'Sangat Memuaskan'
        ELSE 'Memuaskan'
    END AS predikat_sementara,
    status_akademik
FROM SALAM.mahasiswas;

-- 3. Transaksi Pengisian Data Awal dengan SAVEPOINT
BEGIN;

INSERT INTO SALAM.mahasiswas (nim, nama_lengkap, email_kampus, angkatan, semester, ipk, status_akademik)
VALUES 
    ('1247050061', 'Muhammad Zacky Firdaus', '1247050061@student.uinsgd.ac.id', 2024, 5, 3.85, 'Aktif'),
    ('1247050012', 'Ria Melisa', '1247050012@student.uinsgd.ac.id', 2024, 5, 3.78, 'Aktif'),
    ('1247050045', 'Rifqi Bilal', '1247050045@student.uinsgd.ac.id', 2024, 5, 3.72, 'Aktif');

SAVEPOINT sp_data_utama;

-- Simulasi insert data sementara lalu dibatalkan dengan ROLLBACK TO SAVEPOINT
INSERT INTO SALAM.mahasiswas (nim, nama_lengkap, email_kampus, angkatan, semester, ipk, status_akademik)
VALUES ('1247050999', 'Data Dummy Sementara', 'dummy@student.uinsgd.ac.id', 2024, 5, 3.10, 'Cuti');

ROLLBACK TO SAVEPOINT sp_data_utama;
COMMIT;

-- Menampilkan data yang berhasil tersimpan (3 baris utama)
SELECT * FROM SALAM.mahasiswas;


-- ============================================================================
-- BAGIAN 3: PEMBUKTIAN CONSTRAINT BEKERJA (JALANKAN SATU PER SATU)
-- ============================================================================

-- UJI 1: Buktikan PRIMARY KEY Constraint bekerja (Duplikasi NIM)
INSERT INTO SALAM.mahasiswas (nim, nama_lengkap, email_kampus, angkatan, semester, ipk)
VALUES ('1247050061', 'Mahasiswa Duplikat NIM', 'baru@student.uinsgd.ac.id', 2024, 5, 3.50);

-- UJI 2: Buktikan UNIQUE Constraint bekerja (Duplikasi Email Kampus)
INSERT INTO SALAM.mahasiswas (nim, nama_lengkap, email_kampus, angkatan, semester, ipk)
VALUES ('1247050088', 'Mahasiswa Duplikat Email', '1247050061@student.uinsgd.ac.id', 2024, 5, 3.50);

-- UJI 3: Buktikan CHECK Constraint bekerja (IPK 4.50 melebihi batas maksimal 4.00)
INSERT INTO SALAM.mahasiswas (nim, nama_lengkap, email_kampus, angkatan, semester, ipk)
VALUES ('1247050090', 'Mahasiswa IPK Tidak Valid', 'ipklebih@student.uinsgd.ac.id', 2024, 5, 4.50);