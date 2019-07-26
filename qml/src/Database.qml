import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

QtObject {
    signal ready
    signal added(variant item)
    signal edited(variant item, variant data)
    signal removed(variant item)

    property var database
    property IntValidator intValidator: IntValidator {
    }

    function create() {
        database = LocalStorage.openDatabaseSync('qCommand', '', 'stored commands from qCommand')
        if (database.version === '1.4') {
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
            case '1.2':
                target = '1.3'
                callback = function(tx) {
                    tx.executeSql('ALTER TABLE commands ADD is_template INTEGER')
                }
                break;
            case '1.3':
                target = '1.4'
                callback = function(tx) {
                    tx.executeSql('ALTER TABLE commands ADD cover_group TEXT')
                    var result = tx.executeSql('SELECT rowid, name FROM commands WHERE name != ""'), length = result.rows.length
                    for (var i = 0; i < length; i++) {
                        var item = result.rows.item(i), name = item.name.trim().split(/\s+/)
                        if (name.length > 1) {
                            tx.executeSql('UPDATE commands SET cover_group = ? WHERE rowid = ?', [name[0], item.rowid])
                        }
                    }
                }
                break;
            default:
                return
        }
        database.changeVersion(database.version, target, callback)
        create()
    }

    function load(callback, callbackEmpty, search) {
        database.transaction(function(tx) {
            var result
            if (search) {
                var escaped = search.replace(/([%_#])/, '#$1')
                result = tx.executeSql('SELECT rowid, * FROM commands WHERE name LIKE ? ESCAPE "#" ORDER BY name', '%' + escaped + '%')
            } else {
                result = tx.executeSql('SELECT rowid, * FROM commands ORDER BY name')
            }
            var length = result.rows.length
            for (var i = 0; i < length; i++) {
                callback(result.rows.item(i))
            }
            if (!length) {
                callbackEmpty()
            }
        })
    }

    function read(data, callback) {
        database.transaction(function(tx) {
            var result = tx.executeSql(
                'SELECT rowid, * FROM commands WHERE rowid = ?',
                [data.rowid]
            )
            var item = result.rows.item(0)
            if (item) {
                callback(item)
            }
        })
    }

    function readNextTemplate(sql, bind, callback, callbackEmpty) {
        database.transaction(function(tx) {
            var result = tx.executeSql(sql, bind), item = result.rows.item(0)
            if (item) {
                callback(item)
            } else if (callbackEmpty) {
                callbackEmpty()
            }
        })
    }

    function readNext(data, callback, callbackEmpty) {
        if (!data.rowid) {
            readNextTemplate(
                'SELECT rowid, * FROM commands WHERE cover_group = ? ORDER BY name, rowid LIMIT 1',
                [data.cover_group],
                callback,
                callbackEmpty
            )
            return
        }
        readNextTemplate(
            'SELECT rowid, * FROM commands WHERE (name > ? OR (name = ? AND rowid > ?)) AND cover_group = ? ORDER BY name, rowid LIMIT 1',
            [data.name, data.name, data.rowid, data.cover_group],
            callback,
            function() {
                readNext({rowid: 0, name: '', cover_group: data.cover_group}, callback, callbackEmpty)
            }
        )
    }

    function readNextGroup(data, callback) {
        if (!data.cover_group) {
            readNextTemplate(
               'SELECT rowid, * FROM commands WHERE cover_group != "" ORDER BY name, rowid LIMIT 1',
                [],
                callback
            )
            return
        }
        readNextTemplate(
            'SELECT rowid, * FROM commands WHERE cover_group > ? AND cover_group != "" ORDER BY name, rowid LIMIT 1',
            [data.cover_group],
            callback,
            function() {
                readNextGroup({rowid: 0, name: '', cover_group: ''}, callback)
            }
        )
    }

    function add(data) {
        database.transaction(function(tx) {
            tx.executeSql(
                'INSERT INTO commands(name, command, has_output, is_template, cover_group) VALUES(?, ?, ?, ?, ?)',
                [data.name, data.command, data.has_output, data.is_template, data.cover_group]
            )
            var result = tx.executeSql('SELECT rowid, * FROM commands WHERE rowid = last_insert_rowid()')
            var item = result.rows.item(0)
            if (item) {
                added(item)
            }
        })
    }

    function edit(item, data) {
        database.transaction(function(tx) {
            tx.executeSql(
                'UPDATE commands SET name = ?, command = ?, has_output = ?, is_template = ?, cover_group = ? WHERE rowid = ?',
                [data.name, data.command, data.has_output, data.is_template, data.cover_group, item.rowid]
            )
            edited(item, data)
        })
    }

    function remove(item) {
        database.transaction(function(tx) {
            tx.executeSql('DELETE FROM commands WHERE rowid = ?', [item.rowid])
            removed(item)
        })
    }

    function readCoverPosition(item, callback) {
        database.transaction(function(tx) {
            var resultMax = tx.executeSql(
                'SELECT COUNT(*) AS max FROM commands WHERE cover_group = ? AND rowid != ?',
                [item.cover_group, item.rowid]
            )
            var resultMin = tx.executeSql(
                'SELECT COUNT(*) AS min FROM commands WHERE cover_group = ? AND (name < ? OR (name = ? AND rowid < ?)) AND rowid != ?',
                [item.cover_group, item.name, item.name, item.rowid || intValidator.top, item.rowid]
            )
            var max = resultMax.rows.item(0).max
            callback(resultMin.rows.item(0).min + 1, max + 1)
        })
    }
}
