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
  property var gpuTempHistory: pluginApi.mainInstance.gpuTempHistory
  property var gpuCoreUtilHistory: pluginApi.mainInstance.gpuCoreUtilHistory 
  property var gpuMemPercentHistory: pluginApi.mainInstance.gpuMemPercentHistory

  property int selectedDurationSec: 60 // 60, 300, 1800
  property int targetPoints: 200
  property int sampleIntervalMs: 50


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

  function downsample(data, durationSec) {
    if (!data || data.length === 0) return []

    let totalSamples = data.length
    let samplesNeeded = targetPoints

    // How many raw samples per bucket
    let bucketSize = Math.max(1, Math.floor(totalSamples / samplesNeeded))

    let result = []

    for (let i = 0; i < totalSamples; i += bucketSize) {
      let chunk = data.slice(i, i + bucketSize)

      let sum = 0
      for (let j = 0; j < chunk.length; j++) {
        sum += chunk[j]
      }

      result.push(sum / chunk.length)
    }

    return result
  }

  function getWindow(data, durationSec) {
    let maxSamples = Math.floor((durationSec * 1000) / sampleIntervalMs)
    return data.slice(-maxSamples)
  }

  property var tempGraphData: downsample(
    getWindow(root.gpuTempHistory, selectedDurationSec),
    selectedDurationSec
  )

  property var utilGraphData: downsample(
    getWindow(root.gpuCoreUtilHistory, selectedDurationSec),
    selectedDurationSec
  )

  property var memGraphData: downsample(
    getWindow(root.gpuMemPercentHistory, selectedDurationSec),
    selectedDurationSec
  )

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

          // Toggle sampling
          Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 30
            Layout.preferredWidth: 180
            radius: 999
            color: Color.mSurface
            border.color: Color.mOutlineVariant

            RowLayout {
              anchors.fill: parent
              anchors.margins: Style.marginXS
              spacing: Style.marginXS

              Repeater {
                model: [
                  { label: "1m", value: 60 },
                  { label: "5m", value: 300 },
                  { label: "15m", value: 900 },
                  { label: "30m", value: 1800 }
                ]

                delegate: Rectangle {
                  Layout.preferredWidth: 40
                  Layout.preferredHeight: 24
                  radius: 999
                  color: root.selectedDurationSec === modelData.value
                        ? Color.mPrimary
                        : "transparent"

                  NText {
                    anchors.centerIn: parent
                    text: modelData.label
                    pointSize: Style.fontSizeXS
                    color: root.selectedDurationSec === modelData.value
                          ? Color.mOnPrimary
                          : Color.mOnSurfaceVariant
                  }

                  MouseArea {
                    anchors.fill: parent
                    onClicked: root.selectedDurationSec = modelData.value
                  }
                }
              }
            }
          }

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
                values: tempGraphData || []
                minValue: 20
                maxValue: 100
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
                values: utilGraphData || []
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
                values: memGraphData || []
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