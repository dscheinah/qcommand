import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject {
    signal exec(string cmd, bool emitOutput)
    signal execAsRoot(string cmd, bool emitOutput, string password)
    signal execInteractive(string cmd)
    signal execAsRootInteractive(string cmd)

    function path(item) {
        return StandardPaths.data + '/' + item.rowid + '.sh'
    }

    function store(item, callback) {
        var request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                callback()
            }
        }
        request.open('PUT', 'file:' + path(item))
        request.send(item.command)
    }

    function desktop(item, target, callback) {
        var request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                callback()
            }
        }
        request.open('PUT', 'file:' + target, false)

        var entry, prefix, sh = path(item)
        if (item.is_interactive) {
            entry = 'fingerterm -e'
            prefix = item.run_as_root ? 'devel-su bash -c ' : 'bash -c '
        } else {
            entry = 'bash -c'
            prefix = item.run_as_root ? 'pkexec bash -c ' : ''
        }

        request.send('
[Desktop Entry]
Type=Application
Icon=qCommand
Exec=' + entry + ' "chmod +x ' + sh + ' && ' + prefix + sh + '"
Name=' + item.name + '
X-Nemo-Single-Instance=no

[X-Sailjail]
Sandboxing=Disabled
')
    }
}
