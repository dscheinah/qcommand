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
        database = LocalStorage.openDatabaseSync('qCommand', '', 'stored commands from qCommand')
        if (database.version === '1.2') {
            ready()
            return
        }
        var target, callback
        switch (database.version) {
            case '':
                target = '1.0'
                callback = function(tx) {
                    tx.executeSql('CREATE TABLE commands(name TEXT UNIQUE, command TEXT)')
                }
                break
            case '1.0':
                target = '1.1'
                callback = function(tx) {
                    tx.executeSql('ALTER TABLE commands RENAME TO commands_migration')
                    tx.executeSql('CREATE TABLE commands(name TEXT, command TEXT)')
                    tx.executeSql('INSERT INTO commands(name, command) SELECT name, command FROM commands_migration')
                    tx.executeSql('DROP TABLE commands_migration')
                }
                break
            case '1.1':
                target = '1.2'
                callback = function(tx) {
                    tx.executeSql('ALTER TABLE commands ADD has_output INTEGER')
                }
                break
            default:
                return
        }
        database.changeVersion(database.version, target, callback)
        create()
    }

    function load(callback) {
        database.transaction(function(tx) {
            var result = tx.executeSql('SELECT rowid, * from commands ORDER BY name'), length = result.rows.length
            for (var i = 0; i < length; i++) {
                callback(result.rows.item(i))
            }
        })
    }

    function read(data, callback) {
        database.transaction(function(tx) {
            var result = tx.executeSql('SELECT rowid, * FROM commands WHERE rowid = ?', [data.rowid]), item = result.rows.item(0)
            if (item) {
                callback(item)
            }
        })
    }

    function add(data) {
        database.transaction(function(tx) {
            tx.executeSql('INSERT INTO commands(name, command, has_output) VALUES(?, ?)', [data.name, data.command, data.has_output])
            var result = tx.executeSql('SELECT rowid, * FROM commands WHERE rowid = last_insert_rowid()'), item = result.rows.item(0)
            if (item) {
                added(item)
            }
        })
    }

    function edit(item, data) {
        database.transaction(function(tx) {
            tx.executeSql('UPDATE commands SET name = ?, command = ?, has_output = ? WHERE rowid = ?', [data.name, data.command, data.has_output, item.rowid])
            edited(item, data)
        })
    }

    function remove(item) {
        database.transaction(function(tx) {
            tx.executeSql('DELETE FROM commands WHERE rowid = ?', [item.rowid])
            removed(item)
        })
    }
}
