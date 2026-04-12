import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Modules.Panels.Settings
import qs.Services.System
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  property ShellScreen screen
  property var pluginApi: null

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property var widgetMetadata: BarWidgetRegistry.widgetMetadata[widgetId] ?? {}
  // Explicit screenName property ensures reactive binding when screen changes
  readonly property string screenName: screen ? screen.name : ""
  property var widgetSettings: {
    if (section && sectionWidgetIndex >= 0 && screenName) {
      var widgets = Settings.getBarWidgetsForScreen(screenName)[section];
      if (widgets && sectionWidgetIndex < widgets.length) {
        return widgets[sectionWidgetIndex];
      }
    }
    return {};
  }

  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)


  readonly property bool usePadding: widgetSettings.usePadding || true
  readonly property int paddingPercent: usePadding ? String("100%").length : 0
  readonly property int paddingTemp: usePadding ? String("999°").length : 0
  readonly property int paddingCpuFreq: usePadding ? String("9.9").length : 0
  readonly property int paddingSpeed: usePadding ? String("9999G").length : 0

  readonly property real iconSize: Style.toOdd(capsuleHeight * 0.48)
  readonly property real miniGaugeWidth: Math.max(3, Style.toOdd(root.iconSize * 0.25))

  // Content dimensions for implicit sizing
  readonly property real contentWidth: isVertical ? capsuleHeight : Math.round(mainGrid.implicitWidth + Style.margin2M)
  readonly property real contentHeight: isVertical ? Math.round(mainGrid.implicitHeight + Style.margin2M) : capsuleHeight


  // Size: use implicit width/height
  // BarWidgetLoader sets explicit width/height to extend click area
  implicitWidth: contentWidth
  implicitHeight: contentHeight

  Component.onCompleted: SystemStatService.registerComponent("bar-sysmon:" + (screen?.name || "unknown"))
  Component.onDestruction: SystemStatService.unregisterComponent("bar-sysmon:" + (screen?.name || "unknown"))

  function openExternalMonitor() {
    Quickshell.execDetached(["sh", "-c", Settings.data.systemMonitor.externalMonitor]);
  }

  // Build comprehensive tooltip text with all stats
  function buildTooltipContent() {
    let rows = [];

    // GPU (if available)
    if (SystemStatService.gpuAvailable) {
      rows.push([`${pluginApi.mainInstance.gpuName || "N/A"}`]);
    }

    return rows;
  }

  // Visibility-aware warning/critical states (delegates to service)
  readonly property bool gpuWarning: SystemStatService.gpuWarning
  readonly property bool gpuCritical: SystemStatService.gpuCritical

  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": I18n.tr("system-monitor.title"),
        "action": "sysmon-settings",
        "icon": "settings"
      },
      {
        "label": I18n.tr("actions.widget-settings"),
        "action": "widget-settings",
        "icon": "settings"
      },
    ]

    onTriggered: action => {
                   contextMenu.close();
                   PanelService.closeContextMenu(screen);

                   if (action === "sysmon-settings") {
                     let monitorCmd = Settings.data.systemMonitor.externalMonitor;
                     if (monitorCmd && monitorCmd.trim() !== "") {
                       openExternalMonitor();
                     } else {
                       SettingsPanelService.openToTab(SettingsPanel.Tab.System, 0, screen);
                     }
                   } else if (action === "widget-settings") {
                     //
                   }
                 }
  }

  // Visual capsule centered in parent
  Rectangle {
    id: visualCapsule
    width: root.contentWidth
    height: root.contentHeight
    anchors.centerIn: parent
    radius: Style.radiusM
    color: Style.capsuleColor
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    // Mini gauge component vertical gauge that fills from bottom
    Component {
      id: miniGaugeComponent

      NLinearGauge {
        ratio: 0
        orientation: Qt.Vertical
        fillColor: Color.mPrimary
        width: miniGaugeWidth
        height: iconSize
      }
    }

    GridLayout {
      id: mainGrid
      anchors.centerIn: parent
      flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
      rows: isVertical ? -1 : 1
      columns: isVertical ? 1 : -1
      rowSpacing: isVertical ? Style.marginXL : 0
      columnSpacing: isVertical ? 0 : Style.marginM


      // GPU Temperature Component
      Item {
        id: gpuTempContainer
        implicitWidth: gpuTempContent.implicitWidth
        implicitHeight: gpuTempContent.implicitHeight
        Layout.preferredWidth: isVertical ? root.width : implicitWidth
        Layout.preferredHeight: capsuleHeight
        Layout.alignment: isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
        visible: SystemStatService.gpuAvailable

        GridLayout {
          id: gpuTempContent
          anchors.centerIn: parent
          flow: (isVertical) ? GridLayout.TopToBottom : GridLayout.LeftToRight
          rows: (isVertical) ? 2 : 1
          columns: (isVertical ) ? 1 : 2
          rowSpacing: Style.marginXXS
          columnSpacing:  Style.marginXS

          Item {
            Layout.preferredWidth: iconSize
            Layout.preferredHeight: ( isVertical) ? iconSize : capsuleHeight
            Layout.alignment: Qt.AlignCenter
            Layout.row: (isVertical ) ? 1 : 0
            Layout.column: 0

            NIcon {
              icon: "flame"
              pointSize: iconSize
              applyUiScale: false
              x: Style.pixelAlignCenter(parent.width, width)
              y: Style.pixelAlignCenter(parent.height, contentHeight)
              color: (gpuWarning || gpuCritical) ? SystemStatService.gpuColor : 'black'
            }
          }

          // Text mode
          NText {
            visible: true
            text: `${Math.round(pluginApi.mainInstance.gpuTemp)}°`.padStart(paddingTemp, " ")
            // family: fontFamily
            pointSize: barFontSize
            applyUiScale: false
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: (gpuWarning || gpuCritical) ? SystemStatService.gpuColor : 'black'
            Layout.row: isVertical ? 0 : 0
            Layout.column: isVertical ? 0 : 1
          }
        }
      }


      // Memory Usage Component
      Item {
        id: memoryContainer
        implicitWidth: memoryContent.implicitWidth
        implicitHeight: memoryContent.implicitHeight
        Layout.preferredWidth: isVertical ? root.width : implicitWidth
        Layout.preferredHeight: capsuleHeight
        Layout.alignment: isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
        visible: true // showMemoryUsage

        GridLayout {
          id: memoryContent
          anchors.centerIn: parent
          flow: (isVertical ) ? GridLayout.TopToBottom : GridLayout.LeftToRight
          rows: (isVertical ) ? 2 : 1
          columns: (isVertical ) ? 1 : 2
          rowSpacing: Style.marginXXS
          columnSpacing:  Style.marginXS

          Item {
            Layout.preferredWidth: iconSize
            Layout.preferredHeight: (isVertical) ? iconSize : capsuleHeight
            Layout.alignment: Qt.AlignCenter
            Layout.row: (isVertical ) ? 1 : 0
            Layout.column: 0

            NIcon {
              icon: "memory"
              pointSize: iconSize
              applyUiScale: false
              x: Style.pixelAlignCenter(parent.width, width)
              y: Style.pixelAlignCenter(parent.height, contentHeight)
            }
          }

          // Text mode
          NText {
            visible: true
            text: `${pluginApi.mainInstance.gpuMemPercent.toFixed(1)}% (${pluginApi.mainInstance.gpuMemUsedGB} / ${pluginApi.mainInstance.gpuMemTotalGB} GB)`
            // family: fontFamily
            pointSize: barFontSize
            applyUiScale: false
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.row: isVertical ? 0 : 0
            Layout.column: isVertical ? 0 : 1
          }
        }
      }
    }
  }

  // MouseArea at root level for extended click area
  MouseArea {
    id: tooltipArea
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    hoverEnabled: true
    onClicked: mouse => {
                 if (mouse.button === Qt.LeftButton) {
                   pluginApi.openPanel(root.screen, root);
                   TooltipService.hide();
                 } else if (mouse.button === Qt.RightButton) {
                   TooltipService.hide();
                   PanelService.showContextMenu(contextMenu, root, screen);
                 } else if (mouse.button === Qt.MiddleButton) {
                   TooltipService.hide();
                   openExternalMonitor();
                 }
               }
    onEntered: {
      if (!PanelService.getPanel("systemStatsPanel", screen).isPanelOpen) {
        TooltipService.show(root, buildTooltipContent(), BarService.getTooltipDirection(root.screen?.name));
        tooltipRefreshTimer.start();
      }
    }
    onExited: {
      tooltipRefreshTimer.stop();
      TooltipService.hide();
    }
  }

  Timer {
    id: tooltipRefreshTimer
    interval: 1000
    repeat: true
    onTriggered: {
      if (tooltipArea.containsMouse) {
        TooltipService.updateText(buildTooltipContent());
      }
    }
  }
}