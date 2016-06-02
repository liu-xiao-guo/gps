import QtQuick 2.4
import Ubuntu.Components 1.3

ListItem {
    id: listitem
    property alias title: layout.title
    property alias iconName: icon.name

    height: layout.height + (divider.visible ? divider.height : 0)
    ListItemLayout {
        id: layout
        Icon {
            id: icon
            width: units.gu(2)
            name: "info"
            SlotsLayout.position: SlotsLayout.Leading
        }
    }
}
