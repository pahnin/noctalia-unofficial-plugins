import QtQuick
import Quickshell.Io
import qs.Services.UI

Item {
  id: root
  property var pluginApi: null
  property real gpuMemPercent: 0
  property real gpuCoreUtil: 0
  property real gpuTemp: 0
  property bool gpuAvailable: false

  property string gpuMemUsedGB: "0"
  property string gpuMemTotalGB: "0"
  property string gpuName: "Parsing..." // Initial placeholder

  // History arrays for graphs
  property var gpuTempHistory: []
  property var gpuCoreUtilHistory: []
  property var gpuMemPercentHistory: []
  property int tempHistoryLength: 30
  property int utilHistoryLength: 30
  property int memHistoryLength: 30

  Timer {
    interval: 250
    running: true
    repeat: true
    onTriggered: gpuProcess.running = true
  }

Process {
  id: gpuProcess
  property string lastGpuName: "" // Cache the GPU name

  command: [
    "nvidia-smi",
    "--query-gpu=name,memory.used,memory.total,utilization.gpu,temperature.gpu",
    "--format=csv,noheader,nounits"
  ]

  stdout: StdioCollector {
    onStreamFinished: {
      let output = this.text.trim()
      if (!output) return

      // For output like "NVIDIA GeForce RTX 5060 Ti, 11462, 16311, 0, 37"
      // The GPU name is everything before the FIRST comma
      let firstCommaIndex = output.indexOf(',')

      if (firstCommaIndex === -1) return // Shouldn't happen but safety check

      let gpuName = output.substring(0, firstCommaIndex).trim()

      // Only update cached name if it changed (optimization)
      if (gpuProcess.lastGpuName !== gpuName) {
        gpuProcess.lastGpuName = gpuName
        root.gpuName = gpuName
      }

      // Parse memory and metrics from the rest (after first comma)
      let dataPart = output.substring(firstCommaIndex + 1).trim()
      let parts = dataPart.split(',')
      if (parts.length >= 4) {
        let used = parseFloat(parts[0])
        let total = parseFloat(parts[1])
        let util = parseFloat(parts[2])
        let temp = parseFloat(parts[3])

        root.gpuTemp = temp
        root.gpuCoreUtil = util
        root.gpuMemPercent = (total > 0) ? (used / total) * 100 : 0
        root.gpuMemUsedGB = (used / 1024).toFixed(2)
        root.gpuMemTotalGB = (total / 1024).toFixed(2)

        root.gpuAvailable = true

        // --- ADD HISTORY TRACKING ---
        root.gpuTempHistory.push(temp)
        root.gpuCoreUtilHistory.push(util)
        root.gpuMemPercentHistory.push(root.gpuMemPercent)

        // Limit history size
        if (root.gpuTempHistory.length > tempHistoryLength) {
          root.gpuTempHistory.shift()
        }
        if (root.gpuCoreUtilHistory.length > utilHistoryLength) {
          root.gpuCoreUtilHistory.shift()
        }
        if (root.gpuMemPercentHistory.length > memHistoryLength) {
          root.gpuMemPercentHistory.shift()
        }
        // ------------------------------

      } else {
        root.gpuAvailable = false
      }
    }
  }

  stderr: StdioCollector {}

  onExited: (code) => {
    if (code !== 0) {
      root.gpuAvailable = false
      root.gpuName = "Unavailable" // Better than showing placeholder
    }
  }
}

  IpcHandler {
    target: "plugin:nvidia-gpu-monitor"
    function setMessage(message: string) {
      if (pluginApi && message) {
        // Update the plugin settings object
        pluginApi.pluginSettings.message = message;

        // Save to disk
        pluginApi.saveSettings();

        // Show confirmation
        ToastService.showNotice("Message updated to: " + message);
      }
    }
    function toggle() {
      if (pluginApi) {
        pluginApi.withCurrentScreen(screen => {
          pluginApi.openPanel(screen);
        });
      }
    }
  }
}