CREATE OR REPLACE FUNCTION update_penjualan() RETURNS TRIGGER AS $set_penjualan$
    DECLARE
    stok_lama INTEGER;
    sum_harga NUMERIC;
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            -- upadate stok
            SELECT stok INTO stok_lama FROM barang WHERE kode_barang = NEW.kode_barang;
            UPDATE barang SET stok = stok_lama - NEW.qty WHERE kode_barang = NEW.kode_barang;
             
        ELSIF (TG_OP = 'UPDATE') THEN
            -- update stok
            SELECT stok INTO stok_lama FROM barang WHERE kode_barang = NEW.kode_barang;
            UPDATE barang SET stok = stok_lama - NEW.qty WHERE kode_barang = NEW.kode_barang;
             
        ELSIF (TG_OP = 'DELETE') THEN
            -- update stok
            SELECT stok INTO stok_lama FROM barang WHERE kode_barang = NEW.kode_barang;
            UPDATE barang SET stok = stok_lama - NEW.qty WHERE kode_barang = NEW.kode_barang;
              
        END IF;
        -- update penjualan
        SELECT sum(total_harga) INTO sum_harga FROM detail_penjualan WHERE no_invoice = NEW.no_invoice;
        UPDATE penjualan SET total_harga = sum_harga WHERE no_invoice = NEW.no_invoice;
             
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$set_penjualan$ LANGUAGE plpgsql;

CREATE TRIGGER set_penjualan
AFTER INSERT OR UPDATE OR DELETE ON detail_penjualan
    FOR EACH ROW EXECUTE FUNCTION update_penjualan();

-- update total harga
CREATE OR REPLACE FUNCTION update_harga() RETURNS TRIGGER AS $set_total_harga$
    DECLARE
        harga_jual_barang NUMERIC;
    BEGIN
        SELECT harga_jual INTO harga_jual_barang FROM barang WHERE kode_barang = NEW.kode_barang
        NEW.harga_jual := harga_jual_barang;
        NEW.total_harga := NEW.qty * harga_jual_barang;
        RETURN NEW;
    END;
$set_total_harga$ LANGUAGE plpgsql;

CREATE TRIGGER set_total_harga
BEFORE INSERT OR UPDATE ON detail_penjualan
    FOR EACH ROW EXECUTE FUNCTION update_harga();
