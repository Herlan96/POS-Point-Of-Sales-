var express = require('express');
var router = express.Router();
const { currencyFormatter } = require('../helpers/util');

module.exports = function (db) {
    router.get('/', async function (req, res, next) {
        try {
            const { rows } = await db.query('SELECT * FROM barang');
            res.render('barang/list', {
                currentPage: 'barang',
                rows,
                currencyFormatter
            })
        } catch (e) {
            res.send(e)
        }
    });

    return router;
}