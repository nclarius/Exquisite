import QtQuick 2.5
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kwin 2.0

import "./"

PlasmaComponents.Button {
    id: root
    implicitWidth: 160*1.2 * PlasmaCore.Units.devicePixelRatio
    implicitHeight: 90*1.2 * PlasmaCore.Units.devicePixelRatio

    property var windows
    property var clickedWindows: []

    function tileWindow(window, row, rowSpan, column, columnSpan) {
        if (!window.normalWindow) return;
        if (rememberWindowGeometries && !oldWindowGemoetries.has(window)) oldWindowGemoetries.set(window, [window.geometry.width, window.geometry.height]);

        let screen = workspace.clientArea(KWin.MaximizeArea, workspace.activeScreen, window.desktop);

        let xMult = screen.width / 12.0;
        let yMult = screen.height / 12.0;

        let newX = column * xMult;
        let newY = row * yMult;
        let newWidth = rowSpan * xMult;
        let newHeight = columnSpan * yMult;

        window.setMaximize(false, false);
        window.geometry = Qt.rect(screen.x + newX, screen.y + newY, newWidth, newHeight);
    }

    onClicked: {
        if (tileAvailableWindowsOnBackgroundClick) {
            let clientList = [];
            for (let i = 0; i < workspace.clientList().length; i++) {
                let client = workspace.clientList()[i];
                if (client.normalWindow && workspace.currentDesktop === client.desktop && !client.minimized)
                    clientList.push(client);
            }

            for (let i = 0; i < clientList.length; i++) {
                if (i >= windows.length || i >= clientList.length) return;
                let client = clientList[i];
                tileWindow(client, windows[i].row, windows[i].rowSpan, windows[i].column, windows[i].columnSpan);
                workspace.activeClient = client;
            }

            if (hideOnFirstTile || hideOnLayoutTiled) mainDialog.visible = false;
        }
        if (windows[0].rowSpan == 0  && windows[0].columnSpan == 0) {
            workspace.activeClient.minimized = true;
        }
    }

    SpanGridLayout {
        anchors.fill: parent
        anchors.margins: 10
        rows: 12
        columns: 12

        Repeater {
            model: windows.length

            PlasmaComponents.Button {
                Layout.row: windows[index].row
                Layout.rowSpan: windows[index].rowSpan
                Layout.column: windows[index].column
                Layout.columnSpan: windows[index].columnSpan

                onClicked: {
                    let focusedWindow = workspace.activeClient;
                    if (!focusedWindow || !focusedWindow.normalWindow) return;

                    let screen = workspace.clientArea(KWin.MaximizeArea, workspace.activeScreen, focusedWindow.desktop);

                    let xMult = screen.width / 12.0;
                    let yMult = screen.height / 12.0;

                    let newX = windows[index].column * xMult;
                    let newY = windows[index].row * yMult;
                    let newWidth = windows[index].rowSpan * xMult;
                    let newHeight = windows[index].columnSpan * yMult;

                    if (newWidth == 0 && newHeight == 0) {
                        focusedWindow.minimized = true;
                    }
                    else if (newWidth == screen.width && newHeight == screen.height) {
                        focusedWindow.setMaximize(true, true);
                    }
                    else {
                        focusedWindow.setMaximize(false, false);
                        focusedWindow.geometry = Qt.rect(screen.x + newX, screen.y + newY, newWidth, newHeight);
                    }

                    if (!clickedWindows.includes(windows[index])) clickedWindows.push(windows[index]);
                   
                    if (hideOnFirstTile) mainDialog.visible = false;
                    if (hideOnLayoutTiled && clickedWindows.length === windows.length) {
                        clickedWindows = [];
                        mainDialog.visible = false;
                    }
                }
            }
        }
    }
}
