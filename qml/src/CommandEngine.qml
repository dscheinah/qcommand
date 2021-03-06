import QtQuick 2.0

QtObject {
    signal exec(string cmd, bool emitOutput)
    signal execAsRoot(string cmd, bool emitOutput, string password)
    signal execInteractive(string cmd)
    signal execAsRootInteractive(string cmd)
}
