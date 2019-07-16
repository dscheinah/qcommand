import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

QtObject {
    signal ready
    signal added(variant item)
    signal edited(variant item, variant data)
    signal removed(variant item)

    property var database

    function create() {
        database = LocalStorage.openDatabaseSync('qCommand', '1.0', 'stored commands from qCommand')
        database.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS commands(name TEXT UNIQUE, command TEXT)')
            ready()
        })
    }

    function load(callback) {
        database.transaction(function(tx) {
            var result = tx.executeSql('SELECT * from commands ORDER BY name'), length = result.rows.length
            for (var i = 0; i < length; i++) {
                callback(result.rows.item(i))
            }
        })
    }

    function read(data, callback) {
        database.transaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM commands WHERE name = ?', [data.name]), item = result.rows.item(0)
            if (item) {
                callback(item)
            }
        })
    }

    function add(item) {
        database.transaction(function(tx) {
            tx.executeSql('INSERT OR REPLACE INTO commands VALUES(?, ?)', [item.name, item.command])
            added(item)
        })
    }

    function edit(item, data) {
        database.transaction(function(tx) {
            tx.executeSql('INSERT OR REPLACE INTO commands VALUES(?, ?)', [data.name, data.command])
            edited(item, data)
        })
    }

    function remove(item) {
        database.transaction(function(tx) {
            tx.executeSql('DELETE FROM commands WHERE name = ?', [item.name])
            removed(item)
        })
    }
}
