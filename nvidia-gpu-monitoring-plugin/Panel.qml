import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.UI
import qs.Widgets

// Panel Component - Focused purely on GPU metrics
Item {
  id: root

  // Plugin API (injected by PluginPanelSlot)
  property var pluginApi: null
  property var gpuCoreUtil: pluginApi?.mainInstance?.gpuCoreUtil
  property var gpuMemPercent: pluginApi?.mainInstance?.gpuMemPercent
  property var gpuTemp: pluginApi?.mainInstance?.gpuTemp
  property var gpuAvailable: pluginApi?.mainInstance?.gpuAvailable
  property var gpuMemUsedGB: pluginApi?.mainInstance?.gpuMemUsedGB
  property var gpuMemTotalGB: pluginApi?.mainInstance?.gpuMemTotalGB
  property var gpuName: pluginApi?.mainInstance?.gpuName

  // SmartPanel
  readonly property var geometryPlaceholder: panelContainer

  property real contentPreferredWidth: 400 * Style.uiScaleRatio
  property real contentPreferredHeight: 540 * Style.uiScaleRatio
  property int graphHeight: 120 * Style.uiScaleRatio

  readonly property bool allowAttach: true
  anchors.fill: parent

  Component.onCompleted: {
    if (pluginApi) {
      Logger.i("HelloWorld", "Panel initialized");
      
      // Register GPU metrics component
      if (pluginApi && pluginApi.mainInstance) {
        // Example of registration if available
        // SystemStatService.registerComponent("panel-gpu")
      }
    }
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      Layout.fillWidth: true
      anchors {
        fill: parent
        margins: Style.marginS
      }
      spacing: Style.marginS

      // Content area - GPU Monitoring with TimeCharts
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Color.mSurfaceVariant
        radius: Style.radiusL
        // anchors.fill: parent

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: Style.marginL
          Layout.fillWidth: true
          // spacing: Style.marginM
          Layout.margins: Style.marginM
          Layout.bottomMargin: Style.marginXS
          // Header
          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM

            NText {
              Layout.alignment: Qt.AlignHCenter
              text: "GPU Status"
              pointSize: Style.fontSizeL
              font.weight: Font.Bold
              color: Color.mOnSurface
              Layout.fillWidth: true
            }
          }

          // --- GPU Name ---
          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM

            NText {
              text: "GPU Model:"
              font.pointSize: Style.fontSizeS
              color: Color.mOnSurfaceVariant
              Layout.preferredWidth: 100
            }

            NText {
              text: root.gpuName || "N/A"
                font.pointSize: Style.fontSizeS
                font.family: Settings.data.ui.fontFixed
              color: root.gpuName === "Unavailable" ? Color.mOnSurfaceVariant : Color.mOnSurface
                Layout.fillWidth: true
            }
          }

          // --- Temperature with TimeChart ---
          NBox {
            Layout.fillWidth: true
            color: Color.mSurface
            anchors.margins: Style.marginXXS
            
            Layout.preferredHeight: graphHeight + Style.marginM
            ColumnLayout {
              anchors.fill: parent
              anchors.margins: Style.marginM
              
              anchors.bottomMargin: Style.radiusM * 0.5
              spacing: Style.marginXS
              
              RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginXS
                NIcon {
                  icon: "flame"
                  pointSize: Style.fontSizeXS
                  color: Color.mPrimary
                }
                NText {
                  text: `${Math.round(root.gpuTemp)}°C`
                  pointSize: Style.fontSizeXS
                  color: Color.mPrimary
                  font.family: Settings.data.ui.fontFixed
                }
                Item {
                  Layout.fillWidth: true
                }
                NText {
                  text: I18n.tr("system-monitor.gpu-temp")
                  pointSize: Style.fontSizeXS
                  color: Color.mOnSurfaceVariant
                }
              }
              
              NGraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                values: pluginApi?.mainInstance?.gpuTempHistory || []
                minValue: Math.min(...(pluginApi?.mainInstance?.gpuTempHistory || [0, 50]), 0) - 5
                maxValue: Math.max(...(pluginApi?.mainInstance?.gpuTempHistory || [30, 60]), 0) + 5
                color: Color.mPrimary
                strokeWidth: Math.max(1, Style.uiScaleRatio)
                fill: true
                fillOpacity: 0.15
                updateInterval: pluginApi?.mainInstance?.tempIntervalMs || 1000
              }
            }
          }

          // --- Core Utilization with TimeChart ---
          NBox {
            Layout.fillWidth: true
            color: Color.mSurface
            anchors.margins: Style.marginXXS
            Layout.preferredHeight: graphHeight + Style.marginM
            ColumnLayout {
              anchors.fill: parent
              anchors.margins: Style.marginS
              anchors.bottomMargin: Style.radiusM * 0.5
              spacing: Style.marginXS
              
              RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginXS
                NIcon {
                  icon: "cpu-usage"
                  pointSize: Style.fontSizeXS
                  color: Color.mPrimary
                }
                NText {
                  text: `${Math.round(root.gpuCoreUtil)}%`
                  pointSize: Style.fontSizeXS
                  color: Color.mPrimary
                  font.family: Settings.data.ui.fontFixed
                }
                Item {
                  Layout.fillWidth: true
                }
                NText {
                  text: "GPU utilization"
                  pointSize: Style.fontSizeXS
                  color: Color.mOnSurfaceVariant
                }
              }
              
              NGraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                values: pluginApi?.mainInstance?.gpuCoreUtilHistory || []
                minValue: 0
                maxValue: 100
                color: root.gpuCoreUtil > 90 ? "#E53935" : // Critical
                       root.gpuCoreUtil > 85 ? "#FB8C00" : // Warning
                       Color.mPrimary
                strokeWidth: Math.max(1, Style.uiScaleRatio)
                fill: true
                fillOpacity: 0.15
                updateInterval: pluginApi?.mainInstance?.utilIntervalMs || 1000
              }
            }
          }

          // --- Memory Usage with TimeChart ---
          NBox {
            Layout.fillWidth: true
            color: Color.mSurface
            anchors.margins: Style.marginXXS
            Layout.preferredHeight: graphHeight + Style.marginM
            ColumnLayout {
              anchors.fill: parent
              anchors.margins: Style.marginS
              anchors.bottomMargin: Style.radiusM * 0.5
              spacing: Style.marginXS
              
              RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginXS
                NIcon {
                  icon: "memory"
                  pointSize: Style.fontSizeXS
                  color: Color.mPrimary
                }
                NText {
                  text: `${root.gpuMemUsedGB} / ${root.gpuMemTotalGB} GB (${root.gpuMemPercent.toFixed(1)}%)`
                  pointSize: Style.fontSizeXS
                  color: Color.mPrimary
                  font.family: Settings.data.ui.fontFixed
                }
                Item {
                  Layout.fillWidth: true
                }
                NText {
                  text: I18n.tr("common.memory")
                  pointSize: Style.fontSizeXS
                  color: Color.mOnSurfaceVariant
                }
              }
              
              NGraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                values: pluginApi?.mainInstance?.gpuMemPercentHistory || []
                minValue: 0
                maxValue: 100
                color: root.gpuMemPercent > 90 ? "#E53935" : // Critical
                       root.gpuMemPercent > 75 ? "#FB8C00" : // Warning
                       Color.mPrimary
                strokeWidth: Math.max(1, Style.uiScaleRatio)
                fill: true
                fillOpacity: 0.15
                updateInterval: pluginApi?.mainInstance?.memIntervalMs || 1000
              }
            }
          }
        }
      }
    }
  }
}