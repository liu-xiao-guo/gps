import QtQuick 2.4
import Ubuntu.Components 1.3
import QtLocation 5.3
import QtPositioning 5.0

MainView {
    id: main
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "gps.liu-xiao-guo"

    width: units.gu(60)
    height: units.gu(85)

    function hello(text) {
        console.log("text: " + text)
    }

    function onActionTriggered() {
        console.log("text: " + this.text)
        console.log("style: " + this.maptype.style)
        map.activeMapType = this.maptype
    }

    function creatAction(parent, iconName, maptype) {
        var action = Qt.createQmlObject('import Ubuntu.Components 1.3; Action {property var maptype; onTriggered: hello(text)}', parent)
        action.iconName = iconName
        action.text = maptype.name
        action.maptype = maptype
        action.triggered.connect(action, onActionTriggered)
        return action
    }

    function dumpObject(obj) {
        var keys = Object.keys(obj);
        console.log("length: " + keys.length)
        for( var i = 0; i < keys.length; i++ ) {
            var key = keys[ i ];
            var data = key + ' : ' + obj[ key ];
            console.log( key + ": " + data)
        }
    }

    Plugin {
        id: plugin

        // Set the default one
        Component.onCompleted: {
            name = availableServiceProviders[0]
        }
    }

    PositionSource {
        id: me
        active: true
        updateInterval: 1000
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        onPositionChanged: {
            console.log("lat: " + position.coordinate.latitude + " longitude: " +
                        position.coordinate.longitude);
            console.log(position.coordinate)
            console.log("mapzoom level: " + map.zoomLevel)
        }

        onSourceErrorChanged: {
            console.log("Source error: " + sourceError);
        }
    }

    Component {
        id: highlight
        Rectangle {
            width: parent.width
            height: plugins.delegate.height
            color: "lightsteelblue"; radius: 5
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }

    Page {
        id: page
        header: PageHeader {
            id: pageHeader
            title: i18n.tr("GPS")

            leadingActionBar {
                id: leadbar
                actions: {
                    var supported = map.supportedMapTypes;
                    console.log("count: " + supported.length)
                    var acts = []
                    console.log("Going to add the types")
                    for ( var i = 0; i < supported.length; i++ ) {
                        var item = supported[i]

                        console.log("map type name: " + item.name)
                        console.log("map style: " + item.style)
                        console.log("type des:" + i.description)
                        var action = creatAction(leadbar, "info", item)
                        acts.push(action)
                    }

                    return acts
                }
            }
        }

        Item {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                top: pageHeader.bottom
            }

            Column {
                anchors.fill: parent
                spacing: units.gu(1)

                Label {
                    text: "plugins are: "
                    fontSize: "x-large"
                }

                ListView {
                    id: plugins
                    width: parent.width
                    height: units.gu(5)
                    highlight: highlight
                    model: plugin.availableServiceProviders
                    delegate: Item {
                        width:plugins.width
                        height: item.height
                        Label {
                            id: item
                            text: modelData
                            fontSize: "large"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                plugins.currentIndex = index
                                plugin.name = modelData
                                map.zoomLevel = 17
                            }
                        }
                    }
                }

                // Add a devider
                Rectangle {
                    id: divider
                    width: parent.width
                    height: units.gu(0.1)
                    color: "green"
                }

                CustomListItem {
                    id: feature
                    title.text: (plugin.supportsMapping(Plugin.NoMappingFeatures) ?
                                     "No mapping features" : "Mapping feature supported" ) +
                                "  zoomLevel: " + map.zoomLevel.toFixed(2) +
                                ", "+ map.maximumZoomLevel +
                                ", " + map.minimumZoomLevel
                }

                Map {
                    id: map
                    width: parent.width
                    height: parent.height - divider.height - plugins.height - feature.height
                    plugin : Plugin {
                        name: "osm"
                    }

                    zoomLevel: 14
                    center: me.position.coordinate

//                                        MapCircle {
//                                            center: me.position.coordinate
//                                            radius: units.gu(3)
//                                            color: "red"
//                                        }

                    MapQuickItem {
                        id: mylocation
                        sourceItem: Item {
                            width: units.gu(6)
                            height: info.height

                            Label {
                                id: info
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -units.gu(2)
                                text: "(" + me.position.coordinate.longitude.toFixed(2) + "," + me.position.coordinate.latitude.toFixed(2) + ")"
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

                        coordinate : me.position.coordinate
                        opacity: 1.0
                        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                    }

                    gesture {
                        enabled: !setMarks.checked
                        activeGestures: MapGestureArea.ZoomGesture | MapGestureArea.PanGesture

                        onPanStarted:  {
                            console.log("onPanStarted")
                        }

                        onPanFinished: {
                            console.log("onPanFinished")
                        }

                        onPinchStarted: {
                            console.log("onPinchStarted")
                        }

                        onPinchFinished: {
                            console.log("onPinchFinished")
                        }

                        onPinchUpdated: {
                            console.log("onPinchUpdated")
                            console.log("point1: " + "(" + pinch.point1.x + pinch.point1.y + ")")
                        }
                    }

                    Component.onCompleted: {
                        zoomLevel = 14
                    }

                    MouseArea {
                        anchors.fill: parent

                        onPressed: {
                            if ( setMarks.checked ===false ) {
                                mouse.accepted = false
                                return;
                            }

                            console.log("mouse: " + mouseX + " " + mouseY)
                            var coord = map.toCoordinate(Qt.point(mouseX, mouseY))
                            console.log("longitude: " + coord.longitude)
                            console.log("latitude: " + coord.latitude)

                            var circle = Qt.createQmlObject('import QtLocation 5.3; MapCircle {}', page)
                            circle.center = coord
                            circle.radius = units.gu(4)
                            circle.color = 'green'
                            circle.border.width = 3
                            map.addMapItem(circle)

                            mouse.accepted = true;
                        }
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        anchors { top: parent.top  }
                        text: "Map type: " + map.activeMapType.name + ", " +
                              "mobile: " + map.activeMapType.mobile + ", " +
                              "night: " + map.activeMapType.night
                        fontSize: "large"
                        color: "red"
                    }
                }
            }
        }

        Row {
            width: row1.width + row2.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(1)

            TemplateRow {
                id: row1
                width: units.gu(20)
                height: row2.height
                title: "Set Marks"

                CheckBox {
                    id: setMarks
                    checked: true
                    onCheckedChanged: {
                        console.log("checked: " + checked)
                    }
                }
            }

            Button {
                id: row2
                anchors.verticalCenter: parent.verticalCenter
                text: "Clear marks"
                onClicked: {
                    map.clearMapItems();
                }
            }
        }

        Component.onCompleted: {
            console.log("plugin length: " + plugin.availableServiceProviders.length)
            dumpObject( plugin )
            console.log("Online: " + plugin.supportsMapping(Plugin.OnlineMappingFeature))
            console.log("Offline: " + plugin.supportsMapping(Plugin.OfflineMappingFeature))
        }
    }
}

