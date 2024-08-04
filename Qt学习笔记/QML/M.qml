import QtQuick 2.3

Rectangle{
    width : 100
    height : 100
    Text {
        text : qsTr("Hello QML")
        //anchors.top : parent.top
        anchors.bottom : parent.bottom
        //anchors.bottomMargin : 10
        anchors.leftMargin : 10
    }
}