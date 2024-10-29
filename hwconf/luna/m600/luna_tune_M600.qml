import Vedder.vesc.vescinterface 1.0;import "qrc:/mobile";import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1 as Platform
import Qt.labs.settings 1.0 as QSettings
import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.bleuart 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0
import Vedder.vesc.utility 1.0
Item {
    id: mainItem
    anchors.fill: parent
    //anchors.margins: 10    //fix this
    property BleUart mBle: VescIf.bleDevice()
    property Commands mCommands: VescIf.commands()
    property var fwVersion: mCommands.getFwVersion()
    property ConfigParams mMcConf: VescIf.mcConfig()
    property ConfigParams mAppConf: VescIf.appConfig()
    property ConfigParams mInfoConf: VescIf.infoConfig()
    property bool isHorizontal: width > height
    property bool scheduleConfWrite: false
    property bool fixedThrottle: false
    property bool launching: true
    property var parentTabBar: parent.tabBarItem
    property var tuneProfile: 0
    property var voltPorc:0

    QSettings.Settings {
        property alias rtLog: rtLogFileText.text
        property alias rtLogEnable: rtLogEnBox.checked
        property alias m600profileIndex: profilesBar.currentIndex

        property alias m600streetTorque: streetTorqueSlider.value
        property alias m600streetPas: streetPasSlider.value
        property alias m600streetPower: streetPowerSlider.value
        property alias m600streetSpeed: streetSpeedSlider.value
        property alias m600streetThrottleResponse: streetThrottleResponseSlider.value
        property alias m600streetThrottleExpo: streetThrottleExpoSlider.value
        property alias m600streetPasResponseSlider: streetPasResponseSlider.value
        property alias m600streetFW: streetFWSlider.value
        property alias m600streetFixedThrottle: streetFixedThrottleCheckbox.checked

        property alias m600trailTorque: trailTorqueSlider.value
        property alias m600trailPas: trailPasSlider.value
        property alias m600trailPower: trailPowerSlider.value
        property alias m600trailSpeed: trailSpeedSlider.value
        property alias m600trailThrottleResponse: trailThrottleResponseSlider.value
        property alias m600trailThrottleExpo: trailThrottleExpoSlider.value 
        property alias m600trailPasResponseSlider: streetPasResponseSlider.value
        property alias m600trailFW: trailFWSlider.value
        property alias m600trailFixedThrottle: trailFixedThrottleCheckbox.checked

        property alias m600ludiTorque: torqueSlider.value
        property alias m600ludiPas: pasSlider.value
        property alias m600ludiPower: powerSlider.value
        property alias m600ludiSpeed: speedSlider.value
        property alias m600ludiThrottleResponse: throttleResponseSlider.value
        property alias m600ludiThrottleExpo: throttleExpoSlider.value
        property alias m600ludiPasResponseSlider: pasResponseSlider.value
        property alias m600ludiFW: fWSlider.value
        property alias m600ludiFixedThrottle: fixedThrottleCheckbox.checked

        property alias m600battCurrentMaxSetting: battCurrBox.realValue
        property alias m600battCellseSetting: battCellsBox.realValue
        property alias m600overVoltageSetting: battOvervoltageBox.realValue
        property alias m600underVoltageStartSetting: battUndervoltageStartBox.realValue
        property alias m600underVoltageEndSetting: battUndervoltageEndBox.realValue
        property alias m600wheelDiameterSetting: wheelDiameterBox.currentIndex
        property alias m600encoderOffsetSetting: encoderOffsetBox.realValue
        property alias m600motorDirectionSetting: motorDirectionBox.position      
        }
                                        
    Component.onCompleted: {
        parentTabBar.visible = true
        parentTabBar.enabled = true
        if (typeof VescIf.setShowFwUpdateAvailable === "function") {
            VescIf.setShowFwUpdateAvailable(false) //called only if defined
        }
        readSettings()
    }

    ColumnLayout {
        anchors.fill: parent

        TabBar {
            id: tabBar
            currentIndex: swipeView.currentIndex
            Layout.fillWidth: true
            implicitWidth: 0
            clip: true
            property int buttons: 5
            property int buttonWidth: 100

            TabButton {
                text: qsTr("Ride")
                width: Math.max(tabBar.buttonWidth,tabBar.width / tabBar.buttons)
            }
            TabButton {
                text: qsTr("Tune")
                width: Math.max(tabBar.buttonWidth,tabBar.width / tabBar.buttons)
            }
            TabButton {
                text: qsTr("Bike CFG")
                width: Math.max(tabBar.buttonWidth,tabBar.width / tabBar.buttons)
            }
            TabButton {
                text: qsTr("Logging")
                width: Math.max(tabBar.buttonWidth,tabBar.width / tabBar.buttons)
            }
            TabButton {
                text: qsTr("Firmware")
                width: Math.max(tabBar.buttonWidth,tabBar.width / tabBar.buttons)
            }
        }

        SwipeView {
            id: swipeView
            currentIndex: tabBar.currentIndex
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            Page {
            id:gaugePage
            property int batteryPercentage:0
            property int batteryVoltage:0
            property var maxMotorCurrent:100
            property var hintColor:"#76bd21"
            property var hintSubColor:"#c9ea82"

            SwipeView { // swipe down for vesc gauges
                id: innerSwipeView
                anchors.fill: parent
                orientation: Qt.Vertical

           Page{ // luna gauge
            background: Rectangle {
                opacity: 0.0
                anchors.fill: parent
            }
            ColumnLayout{
                anchors.topMargin: 2
                anchors.bottomMargin: 1
                anchors.fill: parent
                clip: false
                spacing: 5
            RowLayout {
                clip: false
                spacing: 5
                Text {
                    id: pasText
                    Layout.leftMargin:10
                    text:"PAS 1"
                    color: {color=Utility.getAppHexColor("lightText")}
                    font.pixelSize: 30
                    font.bold: true
                }
                Item{Layout.fillWidth:true}
                Text {
                    id:profileText
                    text: "TRAIL"
                    color:gaugePage.hintColor
                    font.pixelSize:32
                    font.bold:true
                    anchors.centerIn:parent
                }
                Item{Layout.fillWidth:true}
                Item{
                id: batteryIndicator
                    Layout.preferredWidth:40
                    Layout.rightMargin:25
                Image {
                    id:img
                    anchors.centerIn: parent
                    width:batteryIndicator.width+25
                    fillMode:Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignHCenter
                    source:"qrc"+Utility.getThemePath()+"icons/icons8-battery-100.png"
                    smooth:true
                    rotation:90
                }
                Button {
                    text: ""
                    anchors.centerIn: parent
                    width:batteryIndicator.width+25
                    background: Rectangle {
                        opacity: 0.0
                        color: "transparent"
                        }
                    onClicked: {
                        if(voltPorc == 0){
                            voltPorc=1
                        }else{
                            voltPorc=0
                        }
                    }
                }
                Rectangle {
                    id: batBack
                    width: 45
                    height: 25
                    radius: 2
                    anchors.horizontalCenter: parent.left
                    anchors.verticalCenter: parent.top
                    anchors.horizontalCenterOffset: 19

                }
                Text {
                    id:batteryText
                    text:gaugePage.batteryVoltage+"V"
                    font.pixelSize:23
                    font.bold: true
                    color: {color=Utility.getAppHexColor("black")}
                    anchors.centerIn: batBack
                    anchors.horizontalCenterOffset: -1
                }
            }
                        }
RowLayout {
           clip: false
           spacing: 5
    Rectangle {
        id: speedBar
        Layout.leftMargin: 20
        Layout.rightMargin: 20
        Layout.fillWidth: true
        height: 8
        color: {color=Utility.getAppHexColor("disabledText")}
        property real progress:0.0

        Rectangle {
            id: fillBar
            width: speedBar.width*speedBar.progress
            height: speedBar.height
            color: {color=Utility.getAppHexColor("lightText")}
            anchors.left:speedBar.left
        }
    }

}
        Item {
            id: arcProgressBar
            Layout.fillWidth:true
            Layout.fillHeight:true
            width: 350
            height: 350
            property real progress:1
            property real progressMotor:0
            property real maximumValue:1
            property real minimumValue:0
            Canvas {
                id: canvas
                anchors.fill: parent
                antialiasing:true

                onPaint: {
                    var ctx=getContext("2d");
                    ctx.reset();
                    var lineWidth=40;
                    var centerX=width*0.45;
                    var centerY=height/2;
                    var radius=Math.min(width,height)*0.8/2-lineWidth/2;
                    var startAngle=Math.PI/2;
                    var endAngle=startAngle+Math.max((arcProgressBar.progress-0.24)/(1-0.24)*1.2*Math.PI,0);
                    var endAngleMotor=startAngle+Math.max((arcProgressBar.progressMotor-0.24)/(1-0.24)*1.2*Math.PI,0);
                    var lineWidth=40;

                    ctx.beginPath();
                    ctx.arc(centerX,centerY,radius,startAngle,1.7*Math.PI,false);
                    ctx.lineWidth=lineWidth;
                    ctx.strokeStyle=Utility.getAppHexColor("disabledText");
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.arc(centerX,centerY,radius,startAngle,endAngle,false);
                    ctx.lineWidth=lineWidth;
                    ctx.strokeStyle=gaugePage.hintSubColor;
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.arc(centerX,centerY,radius,startAngle,endAngleMotor,false);
                    ctx.lineWidth=lineWidth;
                    ctx.strokeStyle=gaugePage.hintColor;
                    ctx.stroke();

                    var linearBarX=centerX+5;
                    var linearBarY=centerY+radius-lineWidth/2;
                    var linearBarWidth=radius*1.35;
                    var linearBarHeight=lineWidth;
                    ctx.fillStyle=Utility.getAppHexColor("disabledText");
                    ctx.fillRect(linearBarX,linearBarY,linearBarWidth,linearBarHeight);

                    var linearBarFillWidth=Math.min(arcProgressBar.progress*linearBarWidth/0.24,linearBarWidth);
                    var motorBarFillWidth=Math.min(arcProgressBar.progressMotor*linearBarWidth/0.24,linearBarWidth);

                    ctx.fillStyle=gaugePage.hintSubColor;
                    ctx.fillRect(linearBarX+linearBarWidth-linearBarFillWidth,linearBarY,linearBarFillWidth,linearBarHeight);
                    ctx.fillStyle=gaugePage.hintColor;
                    ctx.fillRect(linearBarX+linearBarWidth-motorBarFillWidth,linearBarY,motorBarFillWidth,linearBarHeight);
                }
            }

    Item {
    id: speedDisplay
    width: mainText.width + decimalText.width
    height: mainText.height
    Layout.fillHeight: true
    Layout.fillWidth: true
    anchors.centerIn: parent
    anchors.horizontalCenterOffset: 25
    property real value:0
    property int mainFontSize:Math.min(arcProgressBar.width,arcProgressBar.height)*0.28
    property int decimalFontSize:mainFontSize*0.75

    Row {
        anchors.centerIn: parent
        spacing: 0

        Text {
            id: mainText
            text: Math.floor(speedDisplay.value)+"."
            font.pixelSize:speedDisplay.mainFontSize
            font.bold: true
            color: {color=Utility.getAppHexColor("lightText")}
            anchors.bottom: parent.bottom

        }
        Text {
            id: decimalText
            text: Math.round((speedDisplay.value - Math.floor(speedDisplay.value)) * 10)
            font.pixelSize: speedDisplay.decimalFontSize
            font.bold: true
            color: {color=Utility.getAppHexColor("lightText")}
            anchors.baseline: mainText.baseline
        }
        Text {
            id: speedUnitsText
            text: VescIf.useImperialUnits() ? " mph" : " km/h"
            color: {color=Utility.getAppHexColor("disabledText")}
            font.pixelSize: 30
            font.bold:true
            anchors.baseline: mainText.baseline
        }
    }
}
}

          Item{Layout.fillHeight:true}
                            RowLayout {
                            clip: false
                            spacing: 5
                            Layout.bottomMargin: 10

                            Text {
                                id: tempText
                                Layout.leftMargin: 20
                                text: "Motor: --°C"
                                color: {color=Utility.getAppHexColor("lightText")}
                                font.pixelSize:20
                            }
                            Item{Layout.fillWidth:true}

                            Text {
                                id: odoText
                                Layout.rightMargin: 20
                                text:  VescIf.useImperialUnits() ? "0 mi" : "0 km"
                                color: {color=Utility.getAppHexColor("lightText")}
                                font.pixelSize:22
                            }
                          }
                        }

         Connections {
            target: mCommands

            function onPrintReceived(str) {
                if (str.startsWith("PAS level: ")) {
                    if(str.slice("PAS level:".length) == " W") {
                        pasText.text="WALK"
                    }else{
                        pasText.text= "PAS"+str.slice("PAS level:".length);
                    }
                }
                if (str.startsWith("Tune profile: ")) {
                    tuneProfile= str.slice("Tune profile: ".length);
                }
                if (str.startsWith("Fixed throttle: ")) {
                    var auxThrottle = str.slice("Fixed throttle: ".length)
                    if(auxThrottle == 0){
                         auxThrottle = false;
                    }else{
                         auxThrottle = true;
                    }
                    switch(tuneProfile){
                        case "0": streetFixedThrottleCheckbox.checked = auxThrottle; break;
                        case "1": trailFixedThrottleCheckbox.checked = auxThrottle; break;
                        case "2": fixedThrottleCheckbox.checked = auxThrottle; break;
                        default: break;
                    }
                }
            }

            function onValuesSetupReceived(values){

            arcProgressBar.progress=gaugePage.maxMotorCurrent/100
            if(values.current_motor > 0)
                {arcProgressBar.progressMotor=values.current_motor/gaugePage.maxMotorCurrent}
            else
                {arcProgressBar.progressMotor=0}

            VescIf.useImperialUnits() ? (speedDisplay.value=values.speed*2.23) : (speedDisplay.value=values.speed*3.6)
            VescIf.useImperialUnits() ? (speedUnitsText.text = " mph") : (speedUnitsText.text = " km/h")
            if(values.speed*3.6/32 > 1){speedBar.progress = 1}else{speedBar.progress=values.speed*3.6/32}
            tempText.text="Motor: "+Math.round(values.temp_motor)+"°C";

            if(values.temp_motor<95.0)
                {tempText.color=Utility.getAppHexColor("lightText")}
            else
                {
                if(values.temp_motor >= 95.0 && values.temp_motor < 120.0)
                    {tempText.color="Orange"}
                else
                    {tempText.color="Red"}
                }
            voltPorc ? gaugePage.batteryVoltage=values.v_in : gaugePage.batteryVoltage=values.battery_level*100.0
            voltPorc ? batteryText.text = gaugePage.batteryVoltage + "V" : batteryText.text = gaugePage.batteryVoltage + "%"
            if(values.battery_level<0.15)
                {batBack.color=Utility.getAppHexColor("red")}
            else
                {
                if(values.battery_level >= 0.15 && values.battery_level < 0.30)
                    {batBack.color=Utility.getAppHexColor("orange")}
                else
                   {batBack.color=Utility.getAppHexColor("green")}
                }
            VescIf.useImperialUnits() ? (odoText.text=Math.round(values.odometer/1609)+" mi") : (odoText.text=Math.round(values.odometer/1000)+" km")
            if(tuneProfile==0){profileText.text="STREET";gaugePage.hintColor="royalblue";gaugePage.hintSubColor="#ccccff"}
            if(tuneProfile==1){profileText.text="TRAIL";gaugePage.hintColor="#76bd21";gaugePage.hintSubColor="#c9ea82";}
            if(tuneProfile==2){profileText.text="LUDI";gaugePage.hintColor="indianred";gaugePage.hintSubColor="#ffcccc"}
            canvas.requestPaint();
            }
    }
}
           Page{
                RtDataSetup {
                    anchors.fill: parent
                    updateData: swipeView.currentIndex == 0
                }
           }
            }// close vertical swipe
            }// close gauges page
            Page {
                background: Rectangle {
                    opacity: 0.0
                }

                ColumnLayout {
                    anchors.topMargin: 5
                    anchors.bottomMargin: 1
                    anchors.fill: parent

                    clip: false
                    spacing: 5

                    TabBar {
                        id: profilesBar
                        currentIndex: profileSwipeView.currentIndex
                        property var lastProfileIndex: currentIndex
                        Layout.fillWidth: true
                        implicitWidth: 0
                        clip: true
                        property int buttons: 3
                        property int buttonWidth: 100

                        TabButton {
                            text: qsTr("Street\nlegal")
                            width: Math.max(
                                       profilesBar.buttonWidth,
                                       profilesBar.width / profilesBar.buttons)
                        }
                        TabButton {
                            text: qsTr("Trail")
                            width: Math.max(
                                       profilesBar.buttonWidth,
                                       profilesBar.width / profilesBar.buttons)
                        }
                        TabButton {
                            text: qsTr("Ludicrous")
                            width: Math.max(
                                       profilesBar.buttonWidth,
                                       profilesBar.width / profilesBar.buttons)
                        }
                    }
                    SwipeView {
                        id: profileSwipeView
                        currentIndex: profilesBar.currentIndex
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        interactive: false
                        // Street Legal
                        Page 
                        {
                            ColumnLayout {
                                anchors.topMargin: 5
                                anchors.bottomMargin: 1
                                anchors.fill: parent

                                clip: false
                                spacing: 5

                                ScrollView {
                                    clip: true
                                    contentWidth: parent.width
                                    Layout.fillHeight: true

                                    ColumnLayout {
                                        anchors.topMargin: 5
                                        anchors.bottomMargin: 1
                                        anchors.fill: parent

                                        clip: false
                                        visible: true
                                        spacing: 5

                                        Item {
                                            // Spacer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                        }

                                        GroupBox {
                                            id: streetTorqueBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                // anchors.topMargin: 5
                                                //anchors.bottomMargin: 1
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Throttle\nAmps"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: streetTorqueSlider
                                                    stepSize: 10
                                                    from: 20
                                                    value: 30
                                                    to: 100 //max phase amps
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: streetTorqueSlider.handle
                                                        visible: streetTorqueSlider.pressed
                                                        text: streetTorqueSlider.value.toFixed(1)+" A"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: streetPasBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "PAS\nAmps"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: streetPasSlider
                                                    stepSize: 1
                                                    from: 0
                                                    value: 20
                                                    to: streetTorqueSlider.value.toFixed(
                                                            1) //% of phase amps
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: streetPasSlider.handle
                                                        visible: streetPasSlider.pressed
                                                        text: streetPasSlider.value.toFixed(1)+" A"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: streetPowerBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Power"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: streetPowerSlider
                                                    stepSize: 250
                                                    from: 0
                                                    value: 500
                                                    to: 2500
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: streetPowerSlider.handle
                                                        visible: streetPowerSlider.pressed
                                                        text: streetPowerSlider.value.toFixed(1)+" W"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: streetSpeedBox
                                            Layout.fillWidth: true
                                            visible : false
                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Speed\nLimit"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: streetSpeedSlider
                                                    stepSize: 1
                                                    from: 20
                                                    value: 20
                                                    to: 60
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: streetSpeedSlider.handle
                                                        visible: streetSpeedSlider.pressed
                                                        text: streetSpeedSlider.value.toFixed(1) + (VescIf.useImperialUnits() ? " mph":" km/h")
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: streetThrottleResponseBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Throttle\nResponse"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: streetThrottleResponseSlider
                                                    stepSize: 0.1
                                                    from: 3
                                                    value: 0.9
                                                    to: 0.3
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: streetThrottleResponseSlider.handle
                                                        visible: streetThrottleResponseSlider.pressed
                                                        text: streetThrottleResponseSlider.value.toFixed(1)+" sec"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: streetThrottleExpoBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Throttle\nLinearity"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: streetThrottleExpoSlider
                                                    stepSize: 1
                                                    from: 0
                                                    value: 100
                                                    to: 100
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: streetThrottleExpoSlider.handle
                                                        visible: streetThrottleExpoSlider.pressed
                                                        text: streetThrottleExpoSlider.value.toFixed(1)+"%"
                                                    }
                                                }
                                            }
                                        }
                                        GroupBox {
                                            id: streetPasResponseBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "PAS\nResponse"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: streetPasResponseSlider
                                                    stepSize: 0.1
                                                    from: 1.5
                                                    value: 0.8
                                                    to: 0.3
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: streetPasResponseSlider.handle
                                                        visible: streetPasResponseSlider.pressed
                                                        text: streetPasResponseSlider.value.toFixed(1)+" sec"
                                                    }
                                                }
                                            }
                                        }
                                        GroupBox {
                                            id: streetFWExpoBox
                                            Layout.fillWidth: true
                                            RowLayout {
                                                anchors.fill: parent
                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Field\nWeakening"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: streetFWSlider
                                                    stepSize: 1
                                                    from: 0
                                                    value: 2
                                                    to: 7
                                                    Layout.fillWidth: true
                                                    ToolTip {
                                                        parent: streetFWSlider.handle
                                                        visible: streetFWSlider.pressed
                                                        text: streetFWSlider.value.toFixed(1)+" A"
                                                    }
                                                }
                                            }
                                        }
                                        GroupBox {
                                            id: streetFixedThrottleBox
                                            Layout.fillWidth: true
                                            RowLayout {
                                                anchors.fill: parent
                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Fixed Throttle\nAmps"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                CheckBox {
                                                    id: streetFixedThrottleCheckbox
                                                    checked: false
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }

                                        Button {
                                            text: "Restore street legal\ndefaults"
                                            Layout.columnSpan: 2
                                            Layout.preferredWidth: 200
                                            Layout.preferredHeight: 80
                                            Layout.fillWidth: true
                                            onClicked: {
                                               restoreTuneSettings()
                                            }
                                        }
                                    }
                                }
                            }                        
                        }

                        // Trail
                        Page {
                            ColumnLayout {
                                anchors.topMargin: 5
                                anchors.bottomMargin: 1
                                anchors.fill: parent

                                clip: false
                                spacing: 5

                                ScrollView {
                                    clip: true
                                    contentWidth: parent.width
                                    Layout.fillHeight: true

                                    ColumnLayout {
                                        anchors.topMargin: 5
                                        anchors.bottomMargin: 1
                                        anchors.fill: parent

                                        clip: false
                                        spacing: 5

                                        Item {
                                            // Spacer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                        }

                                        GroupBox {
                                            id: trailTorqueBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                // anchors.topMargin: 5
                                                //anchors.bottomMargin: 1
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Throttle\nAmps"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: trailTorqueSlider
                                                    stepSize: 10
                                                    from: 20
                                                    value: 70
                                                    to: 100 //max phase amps
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: trailTorqueSlider.handle
                                                        visible: trailTorqueSlider.pressed
                                                        text: trailTorqueSlider.value.toFixed(1)+" A"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: trailPasBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "PAS\nAmps"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: trailPasSlider
                                                    stepSize: 1
                                                    from: 0
                                                    value: 60
                                                    to: trailTorqueSlider.value.toFixed(
                                                            1) //% of phase amps
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: trailPasSlider.handle
                                                        visible: trailPasSlider.pressed
                                                        text: trailPasSlider.value.toFixed(1)+" A"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: trailPowerBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Power"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: trailPowerSlider
                                                    stepSize: 250
                                                    from: 0
                                                    value: 2000
                                                    to: 2500
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: trailPowerSlider.handle
                                                        visible: trailPowerSlider.pressed
                                                        text: trailPowerSlider.value.toFixed(1)+" W"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: trailSpeedBox
                                            Layout.fillWidth: true
                                            visible : false
                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Speed\nLimit"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: trailSpeedSlider
                                                    stepSize: 1
                                                    from: 20
                                                    value: 60
                                                    to: 60
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: trailSpeedSlider.handle
                                                        visible: trailSpeedSlider.pressed
                                                        text: trailSpeedSlider.value.toFixed(1) + (VescIf.useImperialUnits() ? " mph":" km/h")
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: trailThrottleResponseBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Throttle\nResponse"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: trailThrottleResponseSlider
                                                    stepSize: 0.1
                                                    from: 3
                                                    value: 0.4
                                                    to: 0.3
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: trailThrottleResponseSlider.handle
                                                        visible: trailThrottleResponseSlider.pressed
                                                        text: trailThrottleResponseSlider.value.toFixed(1)+" sec"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: trailThrottleExpoBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Throttle\nLinearity"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: trailThrottleExpoSlider
                                                    stepSize: 1
                                                    from: 0
                                                    value: 100
                                                    to: 100
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: trailThrottleExpoSlider.handle
                                                        visible: trailThrottleExpoSlider.pressed
                                                        text: trailThrottleExpoSlider.value.toFixed(1)+"%"
                                                    }
                                                }
                                            }
                                        }
                                        GroupBox {
                                            id: trailPasResponseBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "PAS\nResponse"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: trailPasResponseSlider
                                                    stepSize: 0.1
                                                    from: 1.5
                                                    value: 0.6
                                                    to: 0.3
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: trailPasResponseSlider.handle
                                                        visible: trailPasResponseSlider.pressed
                                                        text: trailPasResponseSlider.value.toFixed(1)+" sec"
                                                    }
                                                }
                                            }
                                        }
                                        GroupBox {
                                            id: trailFWExpoBox
                                            Layout.fillWidth: true
                                            RowLayout {
                                                anchors.fill: parent
                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Field\nWeakening"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: trailFWSlider
                                                    stepSize: 1
                                                    from: 0
                                                    value: 7
                                                    to: 7
                                                    Layout.fillWidth: true
                                                    ToolTip {
                                                        parent: trailFWSlider.handle
                                                        visible: trailFWSlider.pressed
                                                        text: trailFWSlider.value.toFixed(1)+" A"
                                                    }
                                                }
                                            }
                                        }
                                        GroupBox {
                                            id: trailFixedThrottleBox
                                            Layout.fillWidth: true
                                            RowLayout {
                                                anchors.fill: parent
                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Fixed Throttle\nAmps"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                CheckBox {
                                                    id: trailFixedThrottleCheckbox
                                                    checked: false
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }
                                        Button {
                                            text: "Restore trail\ndefaults"
                                            Layout.columnSpan: 2
                                            Layout.preferredWidth: 200
                                            Layout.preferredHeight: 80
                                            Layout.fillWidth: true
                                            onClicked: {
                                               restoreTuneSettings()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Ludicrous
                        Page {
                            ColumnLayout {
                                anchors.topMargin: 5
                                anchors.bottomMargin: 1
                                anchors.fill: parent

                                clip: false
                                spacing: 5

                                ScrollView {
                                    clip: true
                                    contentWidth: parent.width
                                    Layout.fillHeight: true

                                    ColumnLayout {
                                        anchors.topMargin: 5
                                        anchors.bottomMargin: 1
                                        anchors.fill: parent

                                        clip: false
                                        spacing: 5

                                        Item {
                                            // Spacer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                        }

                                        GroupBox {
                                            id: torqueBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                // anchors.topMargin: 5
                                                //anchors.bottomMargin: 1
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Throttle\nAmps"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: torqueSlider
                                                    stepSize: 10
                                                    from: 20
                                                    value: 100
                                                    to: 100 //max phase amps
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: torqueSlider.handle
                                                        visible: torqueSlider.pressed
                                                        text: torqueSlider.value.toFixed(1)+" A"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: pasBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "PAS\nAmps"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: pasSlider
                                                    stepSize: 1
                                                    from: 0
                                                    value: 90
                                                    to: torqueSlider.value.toFixed(
                                                            1) //% of phase amps
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: pasSlider.handle
                                                        visible: pasSlider.pressed
                                                        text: pasSlider.value.toFixed(1)+" A"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: powerBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Power"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: powerSlider
                                                    stepSize: 250
                                                    from: 0
                                                    value: 2500
                                                    to: 2500
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: powerSlider.handle
                                                        visible: powerSlider.pressed
                                                        text: powerSlider.value.toFixed(1)+" W"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: speedBox
                                            Layout.fillWidth: true
                                            visible : false
                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Speed\nLimit"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: speedSlider
                                                    stepSize: 1
                                                    from: 20
                                                    value: 60
                                                    to: 60
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: speedSlider.handle
                                                        visible: speedSlider.pressed
                                                        text: speedSlider.value.toFixed(1) + (VescIf.useImperialUnits() ? " mph":" km/h")
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: throttleResponseBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Throttle\nResponse"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: throttleResponseSlider
                                                    stepSize: 0.1
                                                    from: 3
                                                    value: 0.3
                                                    to: 0.3
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: throttleResponseSlider.handle
                                                        visible: throttleResponseSlider.pressed
                                                        text: throttleResponseSlider.value.toFixed(1)+" sec"
                                                    }
                                                }
                                            }
                                        }

                                        GroupBox {
                                            id: throttleExpoBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Throttle\nLinearity"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: throttleExpoSlider
                                                    stepSize: 1
                                                    from: 0
                                                    value: 95
                                                    to: 100
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: throttleExpoSlider.handle
                                                        visible: throttleExpoSlider.pressed
                                                        text: throttleExpoSlider.value.toFixed(1)+"%"
                                                    }
                                                }
                                            }
                                        }
                                        GroupBox {
                                            id: pasResponseBox
                                            Layout.fillWidth: true

                                            RowLayout {
                                                anchors.fill: parent

                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "PAS\nResponse"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: pasResponseSlider
                                                    stepSize: 0.1
                                                    from: 1.5
                                                    value: 0.3
                                                    to: 0.3
                                                    Layout.fillWidth: true

                                                    ToolTip {
                                                        parent: pasResponseSlider.handle
                                                        visible: pasResponseSlider.pressed
                                                        text: pasResponseSlider.value.toFixed(1)+" sec"
                                                    }
                                                }
                                            }
                                        }                                        
                                        GroupBox {
                                            id: fWExpoBox
                                            Layout.fillWidth: true
                                            RowLayout {
                                                anchors.fill: parent
                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Field\nWeakening"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                Slider {
                                                    id: fWSlider
                                                    stepSize: 1
                                                    from: 0
                                                    value: 7
                                                    to: 7
                                                    Layout.fillWidth: true
                                                    ToolTip {
                                                        parent: fWSlider.handle
                                                        visible: fWSlider.pressed
                                                        text: fWSlider.value.toFixed(1)+" A"
                                                    }
                                                }
                                            }
                                        }
                                        GroupBox {
                                            id: fixedThrottleBox
                                            Layout.fillWidth: true
                                            RowLayout {
                                                anchors.fill: parent
                                                clip: false
                                                spacing: 5
                                                Text {
                                                    text: "Fixed Throttle\nAmps"
                                                    color:{color=Utility.getAppHexColor("lightText")}
                                                    horizontalAlignment: Text.AlignHCenter
                                                    Layout.minimumWidth: 100
                                                }
                                                CheckBox {
                                                    id: fixedThrottleCheckbox
                                                    checked: false
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }
                                        Button {
                                            text: "Restore ludicrous\ndefaults"
                                            Layout.columnSpan: 2
                                            Layout.preferredWidth: 200
                                            Layout.preferredHeight: 80
                                            Layout.fillWidth: true
                                            onClicked: {
                                               restoreTuneSettings()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        id: profilesRow
                        clip: false
                        visible: true
                        spacing: 5

                        Button {
                            text: "Read\nSettings"
                            Layout.columnSpan: 2
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 80
                            Layout.fillWidth: true
                            onClicked: {
                                readSettings()                              
                            }
                        }
                        Button {
                            id: tuneWriteSettingsButton                            
                            text: "Write\nSettings"
                            Layout.columnSpan: 2
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 80
                            Layout.fillWidth: true
                            onClicked: {
                                writeSettings()
                            }
                        }
                    }
                }
            }

            Page {
                background: Rectangle {
                    opacity: 0.0
                }

                ColumnLayout {
                    anchors.topMargin: 5
                    anchors.bottomMargin: 1
                    anchors.fill: parent

                    ScrollView {
                        clip: true
                        contentWidth: parent.width
                        Layout.fillHeight: true
                        GridLayout {
                            id: grid2
                            anchors.fill: parent
                            columns: 1
                            columnSpacing: 5
                            rowSpacing: 10
                            GroupBox {
                                id: battSelectorBox
                                title: qsTr("Battery Presets")
                                Layout.fillWidth: true
                                Layout.columnSpan: 1

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 10

                                    Button {
                                        id: wolfButton
                                        text: "LUNA X2\n48V"
                                        Layout.columnSpan: 2
                                        Layout.preferredWidth: 200
                                        Layout.preferredHeight: 70
                                        Layout.fillWidth: true

                                        onClicked: {
                                            battCurrBox.realValue = 60.0
                                            battCellsBox.realValue = 13
                                            battOvervoltageBox.realValue = 60.0
                                            battUndervoltageStartBox.realValue = 40
                                            battUndervoltageEndBox.realValue = 39
                                        }
                                    }

                                    Button {
                                        text: "LUNA X2.5\n60V"
                                        Layout.columnSpan: 2
                                        Layout.preferredWidth: 200
                                        Layout.preferredHeight: 70
                                        Layout.fillWidth: true
                                        onClicked: {
                                            battCurrBox.realValue = 50.0
                                            battCellsBox.realValue = 16
                                            battOvervoltageBox.realValue = 72.0
                                            battUndervoltageStartBox.realValue = 49.0
                                            battUndervoltageEndBox.realValue = 48.0
                                        }
                                    }
                                }
                            }
                            GroupBox {
                                id: battCurrentBox
                                title: qsTr("Battery")
                                Layout.fillWidth: true
                                Layout.columnSpan: 1

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text {
                                        text: "Current\nMax"
                                        color:{color=Utility.getAppHexColor("lightText")}
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.minimumWidth: 100
                                    }

                                    DoubleSpinBox {
                                        id: battCurrBox
                                        Layout.fillWidth: true
                                        decimals: 2
                                        realValue: 60.0
                                        realFrom: 0.0
                                        realTo: 60.0
                                        prefix: "I: "
                                        suffix: " A"
                                    }
                                }
                            }
                            GroupBox {
                                id: batt8Box
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    Text {
                                        text: "Cells"
                                        color:{color=Utility.getAppHexColor("lightText")}
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.minimumWidth: 100
                                    }
                                    DoubleSpinBox {
                                        id: battCellsBox
                                        Layout.fillWidth: true
                                        decimals: 0
                                        realValue: 13.0
                                        realFrom: 13.0
                                        realTo: 20.0
                                        suffix: "s"
                                    }
                                }
                            }
                            GroupBox {
                                id: battBox
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text {
                                        text: "Overvoltage"
                                        color:{color=Utility.getAppHexColor("lightText")}
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.minimumWidth: 100
                                    }

                                    DoubleSpinBox {
                                        id: battOvervoltageBox
                                        Layout.fillWidth: true
                                        decimals: 2
                                        realValue: 55.0
                                        realFrom: 0.0
                                        realTo: 86.0
                                        prefix: "V: "
                                        suffix: " V"
                                    }
                                }
                            }
                            GroupBox {
                                id: batt2Box
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text {
                                        text: "Undervoltage\nCutoff Start"
                                        color:{color=Utility.getAppHexColor("lightText")}
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.minimumWidth: 100
                                    }

                                    DoubleSpinBox {
                                        id: battUndervoltageStartBox
                                        Layout.fillWidth: true
                                        decimals: 2
                                        realValue: 40.0
                                        realFrom: 0.0
                                        realTo: 86.0
                                        prefix: "V: "
                                        suffix: " V"
                                    }
                                }
                            }
                            GroupBox {
                                id: batt3Box
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text {
                                        text: "Undervoltage\nCutoff End"
                                        color:{color=Utility.getAppHexColor("lightText")}
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.minimumWidth: 100
                                    }

                                    DoubleSpinBox {
                                        id: battUndervoltageEndBox
                                        Layout.fillWidth: true
                                        decimals: 2
                                        realValue: 39.0
                                        realFrom: 0.0
                                        realTo: 86.0
                                        prefix: "V: "
                                        suffix: " V"
                                    }
                                }
                            }

                            GroupBox {
                                id: batt4Box
                                title: qsTr("Speedo")
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text {
                                        text: "Wheel\nSize"
                                        color:{color=Utility.getAppHexColor("lightText")}
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.minimumWidth: 100
                                    }

ComboBox {
    id: wheelDiameterBox
    textRole: "text"
    currentIndex: 1
    model: ListModel {
        id: wheelDiameterModel
        ListElement{text:"26\"";value:0.676}
        ListElement{text:"27.5\"";value:0.714}
        ListElement{text:"29\"";value:0.752}
    }
}
}
                            }

                            GroupBox {
                                id: encoderBox
                                title: qsTr("Encoder")
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Button {
                                        id: encoderOffsetButton
                                        text: "Offset\ncorrection"
                                        Layout.preferredHeight: 70
                                        Layout.preferredWidth: 120
                                        onClicked: {
                                            m600detectDialog.open()
                                        }
                                    }

                                    DoubleSpinBox {
                                        id: encoderOffsetBox
                                        Layout.fillWidth: true
                                        decimals: 1
                                        realValue: 0.0
                                        realFrom: 0.0
                                        realTo: 460.0
                                        suffix: "°"
                                    }
                                }
                            }
                            GroupBox {
                                id: torqueSensorBox
                                title: qsTr("Torque Sensor")
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Button {
                                        id: torqueSensorOffsetButton
                                        text: "Offset\ncorrection"
                                        Layout.preferredHeight: 70
                                        Layout.preferredWidth: 120
                                        onClicked: {
                                            m600torqueSensorCalibrationDialog.open()
                                        }
                                    }
                                    Button {
                                        id: tsOffsetBox
                                        text:"Not acquired"
                                        flat:true
                                        Layout.preferredHeight: 70
                                        Layout.preferredWidth: 120
                                     }
                                }
                            }
                            GroupBox {
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text {
                                        text: "Invert Motor\nDirection"
                                        color:{color=Utility.getAppHexColor("lightText")}
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.minimumWidth: 100
                                    }

                                    Switch {
                                        id: motorDirectionBox
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            Item {
                                // Spacer
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                        }
                    }

                    RowLayout {
                        id: bikeCfgRow
                        clip: false
                        visible: true
                        spacing: 5

                        Button {
                            text: "Read\nSettings"
                            Layout.columnSpan: 2
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 80
                            Layout.fillWidth: true
                            onClicked: {
                                readSettings()
                            }
                        }
                        Button {
                            id: bikeWriteSettingsButton
                            text: "Write\nSettings"
                            Layout.columnSpan: 2
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 80
                            Layout.fillWidth: true
                            onClicked: {
                                writeSettings()
                                bikeWriteSettingsButton.background.color = Utility.getAppHexColor("lightBackground");
                            }
                        }
                    }
                }

            }

            // Logging
            Page {
                background: Rectangle {
                    opacity: 0.0
                }

                    ScrollView {
                        clip: true
                        contentWidth: parent.width
                        Layout.fillHeight: true
                        GridLayout {
                            id: gridLog
                            anchors.fill: parent
                            columns: 1
                            columnSpacing: 5
                            rowSpacing: 10
                            
                            GroupBox {
                                id: batt6Box
                                title: "Data Logging"
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                
                            Switch {
                            id: rtLogEnBox
                            text: "Enable Data Logging"
                            anchors.centerIn: parent
                            Layout.fillWidth: true
                            Layout.columnSpan: 2

                            onClicked: {
                                if (checked) {
                                    if (VescIf.openRtLogFile(
                                                rtLogFileText.text)) {
                                        Utility.startGnssForegroundService()
                                        VescIf.setWakeLock(true)
                                    }
                                } else {
                                    VescIf.closeRtLogFile()
                                    Utility.stopGnssForegroundService()

                                    if (!VescIf.useWakeLock()) {
                                        VescIf.setWakeLock(false)
                                    }
                                }
                            }

                            Timer {
                                repeat: true
                                running: true
                                interval: 500
                                onTriggered: {
                                    if (rtLogEnBox.checked
                                            && !VescIf.isRtLogOpen()) {
                                        Utility.stopGnssForegroundService()
                                        if (!VescIf.useWakeLock()) {
                                            VescIf.setWakeLock(false)
                                        }
                                    }
                                    rtLogEnBox.checked = VescIf.isRtLogOpen()
                                }
                            }
                        }
}  

                            GroupBox {
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 5

                                    Button {
                                        text: "Choose Log\nDirectory..."
                                        Layout.preferredHeight: 70

                                        Layout.preferredWidth: 120
                                        onClicked: {
                                            if (Utility.requestFilePermission()) {
                                                logFilePicker.enabled = true
                                                logFilePicker.visible = true
                                            } else {
                                                VescIf.emitMessageDialog("File Permissions","Unable to request file system permission.",false,false)
                                            }
                                        }
                                    }

                                    TextInput {
                                        color:{color=Utility.getAppHexColor("lightText")}
                                        id: rtLogFileText
                                        font.pointSize: 12
                                        text: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation) + "/logs"


                                    }
                                }
                            }
                            GroupBox {
                                Layout.fillWidth: true
                                Layout.columnSpan: 1
                                
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 5
                                    Button {
                                        text: "Set default directory"
                                        Layout.fillWidth: true

                                        onClicked: {
                                            rtLogFileText.text = Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation) + "/logs"
                                        }
                                    }
                                }
                            }
    }
    }                
                DirectoryPicker {
                    id: logFilePicker
                    anchors.fill: parent
                    showDotAndDotDot: true
                    visible: false
                    enabled: false

                    onDirSelected: {
                        rtLogFileText.text = fileName
                    }
                }
            }

            // FW update
            Page {
                background: Rectangle {
                    opacity: 0.0
                }

                FwUpdate {
                    anchors.fill: parent
                    showUploadAllButton: false
                }
            }
            // Support    
        }
    }
function restoreTuneSettings() {

    // restore street legal
    if(profilesBar.currentIndex == 0){
        streetTorqueSlider.value = 30
        streetPasSlider.value = 20
        streetPowerSlider.value = 500
        streetSpeedSlider.value = 20
        streetThrottleResponseSlider.value = 0.9
        streetThrottleExpoSlider.value = 100
        streetPasResponseSlider.value = 0.8
        streetFWSlider.value = 2
        streetFixedThrottleCheckbox.checked = false
    }
    // restore trial
    if(profilesBar.currentIndex == 1){
        trailTorqueSlider.value = 70
        trailPasSlider.value = 60
        trailPowerSlider.value = 2000
        trailSpeedSlider.value = 60
        trailThrottleResponseSlider.value = 0.4
        trailThrottleExpoSlider.value = 100
        trailPasResponseSlider.value = 0.6
        trailFWSlider.value = 7
        trailFixedThrottleCheckbox.checked = false
    }
     // restore ludi
    if(profilesBar.currentIndex == 2){
        torqueSlider.value = 100
        pasSlider.value = 90
        powerSlider.value = 2500
        speedSlider.value = 60
        throttleResponseSlider.value = 0.3
        throttleExpoSlider.value = 95
        pasResponseSlider.value = 0.3
        fWSlider.value = 7
        fixedThrottleCheckbox.checked = false
    }
}
function readSettings() {
    mCommands.getMcconf()
    mCommands.getAppConf()

    var useImperial = VescIf.useImperialUnits()
    var impFact = useImperial?1.60934:1.0

    var power = mMcConf.getParamDouble("l_watt_max")
    var torque = mMcConf.getParamDouble("l_current_max")           
    var speed = -mMcConf.getParamDouble("l_min_erpm") / impFact
    var pas = mAppConf.getParamDouble("app_pas_conf.current_scaling") * torque
    var throttleResponse = mAppConf.getParamDouble("app_adc_conf.ramp_time_pos")
    var pasResponse = mAppConf.getParamDouble("app_pas_conf.ramp_time_pos")
    var throttleExpo = 100.0-(mAppConf.getParamDouble("app_adc_conf.throttle_exp")) * -20.0
    var battCurr = mMcConf.getParamDouble("l_in_current_max")
    var battOvervoltage = mMcConf.getParamDouble("l_max_vin")
    var battUndervoltageStart = mMcConf.getParamDouble("l_battery_cut_start")
    var battUndervoltageEnd = mMcConf.getParamDouble("l_battery_cut_end")
    var battCells = mMcConf.getParamInt("si_battery_cells")
    var encoderOffset = mMcConf.getParamDouble("foc_encoder_offset")
    var fieldWeak = mMcConf.getParamDouble("foc_fw_current_max")
    var fixedThrottle
    var motorDirection = mMcConf.getParamBool("m_invert_direction")

   if(tuneProfile == 0){
        profilesBar.setCurrentIndex(0)
        streetTorqueSlider.value = torque
        streetPowerSlider.value = power                                                                
        streetSpeedSlider.value = speed
        streetPasSlider.value = pas
        streetThrottleResponseSlider.value = throttleResponse
        streetPasResponseSlider.value = pasResponse
        streetFWSlider.value = fieldWeak
        streetThrottleExpoSlider.value = throttleExpo
        }

    if(tuneProfile == 1){
        profilesBar.setCurrentIndex(1)
        trailTorqueSlider.value = torque
        trailPowerSlider.value = power                                                                
        trailSpeedSlider.value = speed
        trailPasSlider.value = pas
        trailThrottleResponseSlider.value = throttleResponse
        trailPasResponseSlider.value = pasResponse
        trailFWSlider.value = fieldWeak
        trailThrottleExpoSlider.value = throttleExpo
        }

     if(tuneProfile == 2){
        profilesBar.setCurrentIndex(2)
        torqueSlider.value = torque
        powerSlider.value = power                                                               
        speedSlider.value = speed
        pasSlider.value = pas
        throttleResponseSlider.value = throttleResponse
        pasResponseSlider.value = pasResponse
        fWSlider.value = fieldWeak
        throttleExpoSlider.value = throttleExpo
        }
    battCurrBox.realValue = mMcConf.getParamDouble("l_in_current_max")
    battCellsBox.realValue = mMcConf.getParamInt("si_battery_cells")
    battOvervoltageBox.realValue = mMcConf.getParamDouble("l_max_vin")
    battUndervoltageStartBox.realValue = mMcConf.getParamDouble("l_battery_cut_start")
    battUndervoltageEndBox.realValue = mMcConf.getParamDouble("l_battery_cut_end")
    motorDirectionBox.position = mMcConf.getParamBool("m_invert_direction")    
    if(mMcConf.getParamDouble("si_wheel_diameter") <= 0.7){wheelDiameterBox.currentIndex=0}                           
    if(mMcConf.getParamDouble("si_wheel_diameter") >= 0.7){wheelDiameterBox.currentIndex=1}                           
    if(mMcConf.getParamDouble("si_wheel_diameter") >= 0.75){wheelDiameterBox.currentIndex=2}  
    if(encoderOffset >= 360.1) {
        encoderOffsetBox.realValue = 0.0
        encoderOffsetBox.prefix ="ERROR ("
        encoderOffsetBox.suffix ="°)"
        tabBar.currentIndex = 2
        encoderOffsetButton.background.color = "#ff9595";
        VescIf.emitMessageDialog("Offset Calibration Required","Go to BIKE CFG tab, run Offset Calibration and then Write Settings.\n\nLet the rear wheel rotate freely during calibration.",false, false)
    } else {
        encoderOffsetBox.realValue = encoderOffset      
        encoderOffsetBox.prefix =""
        encoderOffsetBox.suffix ="°"  
        encoderOffsetButton.background.color = Utility.getAppHexColor("lightBackground");
    }

    mCommands.sendTerminalCmd("ui_init_info")

}

function writeSettings() {
    var useImperial = VescIf.useImperialUnits()
    var impFact = useImperial ? 1.60934 : 1.0

    if(profilesBar.currentIndex == 0) {
        mMcConf.updateParamDouble("l_current_max", streetTorqueSlider.value)
        mMcConf.updateParamDouble("l_watt_max", streetPowerSlider.value)
        //mMcConf.updateParamDouble("l_min_erpm", -streetSpeedSlider.value * impFact)
        mMcConf.updateParamDouble("foc_fw_current_max", streetFWSlider.value)
        mAppConf.updateParamDouble("app_pas_conf.current_scaling", streetPasSlider.value / streetTorqueSlider.value)
        mAppConf.updateParamDouble("app_adc_conf.ramp_time_pos", streetThrottleResponseSlider.value)                                                                        
        mAppConf.updateParamDouble("app_pas_conf.ramp_time_pos", streetPasResponseSlider.value)                                                                        
        mAppConf.updateParamDouble("app_pas_conf.ramp_time_neg", streetPasResponseSlider.value / 2)                                                                        
        mAppConf.updateParamDouble("app_adc_conf.throttle_exp", (100.0 - streetThrottleExpoSlider.value) / -20.0)
        fixedThrottle = streetFixedThrottleCheckbox.checked
        mCommands.sendTerminalCmd("write_tune_profile 0")

    }
    if(profilesBar.currentIndex == 1) {
        mMcConf.updateParamDouble("l_current_max", trailTorqueSlider.value)
        mMcConf.updateParamDouble("l_watt_max", trailPowerSlider.value)
        //mMcConf.updateParamDouble("l_min_erpm", -trailSpeedSlider.value * impFact)
        mMcConf.updateParamDouble("foc_fw_current_max", trailFWSlider.value)
        mAppConf.updateParamDouble("app_pas_conf.current_scaling", trailPasSlider.value / trailTorqueSlider.value)
        mAppConf.updateParamDouble("app_adc_conf.ramp_time_pos", trailThrottleResponseSlider.value)
        mAppConf.updateParamDouble("app_pas_conf.ramp_time_pos", trailPasResponseSlider.value)                                                                        
        mAppConf.updateParamDouble("app_pas_conf.ramp_time_neg", trailPasResponseSlider.value / 2)                                    
        mAppConf.updateParamDouble("app_adc_conf.throttle_exp", (100.0 - trailThrottleExpoSlider.value) / -20.0)
        fixedThrottle = trailFixedThrottleCheckbox.checked
        mCommands.sendTerminalCmd("write_tune_profile 1")
        }
    if(profilesBar.currentIndex == 2) {
        mMcConf.updateParamDouble("l_current_max", torqueSlider.value)
        mMcConf.updateParamDouble("l_watt_max", powerSlider.value)
        //mMcConf.updateParamDouble("l_min_erpm", -speedSlider.value * impFact)
        mMcConf.updateParamDouble("foc_fw_current_max", fWSlider.value)
        mAppConf.updateParamDouble("app_pas_conf.current_scaling", pasSlider.value / torqueSlider.value)
        mAppConf.updateParamDouble("app_adc_conf.ramp_time_pos", throttleResponseSlider.value)
        mAppConf.updateParamDouble("app_pas_conf.ramp_time_pos", pasResponseSlider.value)                                                                        
        mAppConf.updateParamDouble("app_pas_conf.ramp_time_neg", pasResponseSlider.value / 8 + 0.15)
        mAppConf.updateParamDouble("app_adc_conf.throttle_exp", (100.0 - throttleExpoSlider.value) / -20.0)
        fixedThrottle = fixedThrottleCheckbox.checked
        mCommands.sendTerminalCmd("write_tune_profile 2")
    }
    mMcConf.updateParamDouble("l_in_current_max", battCurrBox.realValue)
    mMcConf.updateParamInt("si_battery_cells", battCellsBox.realValue)
    mMcConf.updateParamDouble("l_max_vin",battOvervoltageBox.realValue)
    mMcConf.updateParamDouble("l_battery_cut_start",battUndervoltageStartBox.realValue)
    mMcConf.updateParamDouble("l_battery_cut_end",battUndervoltageEndBox.realValue)
    mMcConf.updateParamDouble("si_wheel_diameter",wheelDiameterModel.get(wheelDiameterBox.currentIndex).value)
    mMcConf.updateParamDouble("foc_encoder_offset",encoderOffsetBox.realValue)
    mMcConf.updateParamBool("m_invert_direction", motorDirectionBox.position)
    scheduleConfWrite = true
}

    Connections {
        target: mMcConf
        function onUpdated() {
            confTimer.mcConfRx = true
        }
    }

    Connections {
        target: mAppConf
        function onUpdated() {
            confTimer.appConfRx = true

        }
    }

    Timer {
        id: statusTimer
        interval: 1600
        running: false
        repeat: false
        onTriggered: {
            connectedText.text = VescIf.getConnectedPortName()
            connectedRect.color = "#4f4f4f"
        }
    }

    Timer {
        id: uiTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
        }
    }

    Timer {
        id: confTimer
        interval: 1000
        running: true
        repeat: true

        property bool mcConfRx: false
        property bool appConfRx: false
        property int writingStage: 0

        onTriggered: {
            VescIf.setSpeedGaugeUseNegativeValues(false)
            if(tabBar.currentIndex !== 3) {
                if (VescIf.isPortConnected() && VescIf.getLastFwRxParams().hwTypeStr() === "VESC") {
                    if(scheduleConfWrite) {
                        if(writingStage === 0) {
                            mCommands.setMcconf(true)
                            writingStage = 1
                        } else {
                            if(writingStage === 1) {
                                mCommands.getMcconf()
                                writingStage = 2
                            } else {
                                if(writingStage === 2) {
                                    mCommands.setAppConf(true)                                    
                                    writingStage = 3
                                } else {
                                    if(fixedThrottle) {
                                        mCommands.sendTerminalCmd("fix_throttle 1")
                                    } else {
                                        mCommands.sendTerminalCmd("fix_throttle 0")
                                    }
                                    writingStage = 0
                                    scheduleConfWrite = false
                                }
                            }
                        }                        
                    }
                    if (!mcConfRx) {
                        mCommands.getMcconf()
                    }
                    if (!appConfRx) {
                        mCommands.getAppConf()
                    }
                }
            }
        }
    }
    Timer {
        id: rtTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if(launching) {
                readSettings()
                launching = false
            }
        
            if (VescIf.isPortConnected()) {
                if (VescIf.isRtLogOpen()) {
                    interval = 50
                    mCommands.getValues()
                    mCommands.getValuesSetup()
                } else {
                    if (tabBar.currentIndex == 0) {
                        interval = 50
                        mCommands.getValuesSetup()
                    }                    
                }
            }
        }
    }
    
        Dialog {
        id: m600detectDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        title: "Detect Magnetic Encoder Offset"
        x:10
        y:Math.max((parent.height-height)/2,10)
        parent: ApplicationWindow.overlay
        width: parent.width - 20
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            Text {
                id: detectLambdaLabel
                color:{color=Utility.getAppHexColor("lightText")}
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text:
                    "This will turn the motor slowly. Lift the rear wheel and make " +
                    "sure that nothing is in the way.\nAfter detection, write the settings and powercycle the controller"
            }
        }

        onAccepted: {
            mCommands.measureEncoder(15.0)
        }
    }
        Dialog {
        id: m600torqueSensorCalibrationDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        title: "Correct Torque Sensor Offset"
        x:10
        y:Math.max((parent.height-height)/2,10)
        parent: ApplicationWindow.overlay
        width: parent.width - 20
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            Text {
                id: detectTSOffsetLabel
                color:{color=Utility.getAppHexColor("lightText")}
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text:
                    "This will measure the torque sensor output at rest to calibrate the zero offset. Make " +
                    "sure that no pressure is applied to the pedals."
            }
        }

        onAccepted: {
            tsOffsetBox.text = "(Measuring...)"
            mCommands.sendTerminalCmd("calibrate_torque_sensor")
        }
    }
        Connections {
        target: mCommands

        function onEncoderParamReceived(res) {
            VescIf.emitStatusMessage("Encoder Result Received", true)
            encoderOffsetBox.realValue = res.offset
            encoderOffsetBox.prefix =""
            encoderOffsetBox.suffix ="°"        
            encoderOffsetBox.decimals = 1
            encoderOffsetButton.background.color = Utility.getAppHexColor("lightBackground");
            bikeWriteSettingsButton.background.color = "#ff9595";
        }
    }
        Connections {
        target: mCommands

        function onPrintReceived(str) {
            if (str.startsWith("Measured offset: ")) {
                tsOffsetBox.text = str.slice("Measured offset: ".length);
            }
            if (str.startsWith("Torque sensor lower range: ")) {
                tsOffsetBox.text = str.slice("Torque sensor lower range: ".length);
            }
        }
    }
}
