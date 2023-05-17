var express = require('express');
var router = express.Router();
const { currencyFormatter } = require('../helpers/util');
const moment = require('moment')

module.exports = function (db) {
    router.get('/', async function (req, res, next) {
        try {
            const { rows } = await db.query('SELECT * FROM penjualan');
            const noInvoice = req.query.noInvoice || rows.length > 0 ? rows[0].no_invoice : '';
            const details = await db.query('SELECT dp.*, b.nama_barang FROM detail_penjualan as dp LEFT JOIN barang as b ON dp.kode_barang = b.kode_barang WHERE dp.no_invoice = $1 ORDER BY dp.id_detail', [req.query.no_invoice]);
            res.render('penjualan/list', {
                currentPage: 'penjualan',
                rows,
                currencyFormatter,
                moment,
                details: details.rows
            })
        } catch (e) {
            res.send(e)
        }
    });

    router.get('/add', async function (req, res, next) {
        try {
            const {rows} = await db.query('SELECT kode_barang FROM barang')
            res.render('penjualan/add', {
                currentPage: 'penjualan',
                barang: rows
            })
        } catch (e) {
            res.send(e)
        }
    });

    router.post('/start', async function (req, res, next) {
        try {
            const {rows} = await db.query('INSERT INTO penjualan(total_harga) VALUES(0) returning *')
            res.json(rows[0])
        } catch (e) {
            res.send(e)
        }
    });
    return router;
}