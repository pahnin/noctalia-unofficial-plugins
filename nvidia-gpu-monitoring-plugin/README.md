# GPU Status Monitor Plugin for Noctalia Shell

A GPU monitoring plugin built for [Noctalia Shell](https://github.com/Noctalia/Noctalia-Shell) on Linux that provides real-time GPU metrics using `nvidia-smi`.

## Prerequisites

- Linux system with NVIDIA GPU
- `nvidia-smi` command available in PATH (install NVIDIA drivers)

## Features

- **Real-time GPU Monitoring**: Polls `nvidia-smi` every 250ms for up-to-date metrics
- **GPU Temperature**: Displays current GPU temperature
- **GPU Utilization**: Shows GPU compute utilization percentage
- **GPU Memory Usage**: Tracks GPU memory usage (used/total)
- **Visual Graphing**: Displays time-series graphs for utilization and memory percentage
- **Color-coded Alerts**: Visual warnings for high GPU temperatures or memory usage
- **Panel Widget**: Integrates seamlessly with Noctalia Shell's panel system
- **Customizable**: Configurable update intervals and display options

## Installation

1. Place this plugin in your Noctalia Shell plugin directory:
   ```bash
   mkdir -p ~/.local/share/Noctalia/plugins
   cp -r plugin-gpu-status ~/.local/share/Noctalia/plugins/
   ```

2. Restart Noctalia Shell:

3. Add the plugin to your Noctalia Shell instance in the plugin manager

## Usage

The plugin appears as a panel in Noctalia Shell showing GPU metrics with visual graphs. You can drag the panel to different positions or make it float as a window.

### Metrics Displayed

- GPU Core Utilization (with graph)
- GPU Memory Usage (with graph)
- Color-coded status indicators:
  - Red: Critical (>90%)
  - Orange: Warning (75-90%)
  - Green: Normal (<75%)

## Panel Configuration

The plugin supports the following panel settings:

- `panelPosition`: Position where the panel appears (right, left, top, bottom)
- `panelDetached`: Whether the panel can be detached as a floating window
- `panelWidth`: Width of the panel
- `panelHeightRatio`: Height as ratio of screen height
- `scale`: UI scaling factor for the plugin

## IPC Commands

The plugin registers the following IPC handlers:

- `gpu-get-status`: Get current GPU status
- `gpu-get-history`: Get historical GPU metrics
- `gpu-toggle-monitoring`: Enable/disable monitoring

## Settings

Access the plugin settings through Noctalia Shell's control center to configure:

- Update interval (default: 250ms)
- Panel position
- Whether to show graphs or only text
- Color scheme

## Troubleshooting

### Issue: "nvidia-smi: command not found"

Make sure you have installed NVIDIA drivers and the `nvidia-smi` command:

```bash
# For Debian/Ubuntu
sudo apt install nvidia-smi

# For Fedora/RHEL
sudo dnf install nvidia-utils
```

### Issue: Panel not showing

1. Verify the plugin is enabled in Noctalia Shell's plugin manager
2. Check the panel position setting
3. Ensure you have a valid NVIDIA GPU connected

### Issue: No data showing

- Ensure NVIDIA drivers are installed and working
- Check that the GPU is properly detected
- Verify `nvidia-smi` returns data when run manually:
  ```bash
  nvidia-smi
  ```

## License

This plugin is released under the MIT License.

## Contributing

Contributions are welcome! Please ensure your pull requests:

1. Include tests for new features
2. Update the README with changes
3. Follow the existing code style
4. Include clear descriptions of any changes

## Credits

- Built for [Noctalia Shell](https://github.com/Noctalia/Noctalia-Shell)
- GPU metrics powered by [nvidia-smi](https://github.com/NVIDIA/nvidia-smi)

## Support

For issues or questions:
- Open an issue on GitHub
- Check the Noctalia Shell documentation
- Report NVIDIA driver issues to NVIDIA support

---

**Note**: This plugin requires an NVIDIA GPU and proper driver installation. It will not work on systems without an NVIDIA GPU or with `nvidia-smi` not available.