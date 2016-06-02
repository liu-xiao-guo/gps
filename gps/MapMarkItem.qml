import QtQuick 2.0
import Ubuntu.Components 1.3
import QtLocation 5.3

MapQuickItem {

    sourceItem: Item {
        width: units.gu(6)
        height: info.height

        Label {
            id: info
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -units.gu(2)
            text: "(" + coordinate.longitude.toFixed(2) + "," + coordinate.latitude.toFixed(2) + ")"
            color: "blue"
        }


        Rectangle {
            width: units.gu(2)
            height: width
            radius: width/2
            color: "red"
            x: parent.width/2
            y: parent.height/2
        }
    }

    Component.onCompleted: {
        console.log("long: " + coordinate.longitude)
    }
}
