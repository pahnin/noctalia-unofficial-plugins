# Noctalia Unofficial Plugins (pahnin)

***Unofficial*** plugin registry for Noctalia Shell, containing personal and experimental plugins not included in the upstream ecosystem.

## Overview

This repository hosts custom plugins for Noctalia Shell. It is intended as a lightweight, user-maintained registry for plugins that are forked, modified, or independently developed.

The `registry.json` file serves as the central index and is automatically updated as plugins are added or modified.

## Demo
![Video](https://github.com/user-attachments/assets/802bbe58-d193-4148-8750-b6fac874e871)

## Installation

To use plugins from this repository:

1. Open **Noctalia Settings** → **Plugins** → **Sources**
2. Click **Add custom repository**
3. Enter a name (e.g., "Pahnin Plugins")
4. Add the repository URL:

   ```
   https://github.com/pahnin/noctalia-unofficial-plugins
   ```
5. Plugins will appear in the **Available** tab

You can browse and install plugins directly from the plugin manager.

## Available Plugins

### GPU Status Monitor

A real-time GPU monitoring panel for Linux systems using `nvidia-smi`.

**Features:**

* GPU temperature, utilization, and memory tracking
* Live updates (default: 50ms)
* Toggle between time ranges
* Time-series graphs for usage metrics
* Color-coded alerts for thresholds
* Configurable panel layout and scaling

**Requirements:**

* NVIDIA GPU
* `nvidia-smi` available in PATH

---

### Ollama Assistant Panel

A simplified AI assistant panel plugin focused on chat functionality using OpenAI-compatible APIs.

**Features:**

* Supports local and remote AI providers (Ollama, OpenAI-compatible APIs)
* Persistent multi-conversation chat interface
* System prompts and temperature control
* IPC commands for automation and scripting
* Designed as a lightweight alternative to full assistant + translation plugins

**Notes:**

* Does not include translation features
* Does not support Gemini
* Optimized for local inference setups

## Contributing

Contributions are welcome. When submitting changes:

* Ensure plugin manifests are valid
* Update relevant documentation if needed
* Follow existing repository structure

## License

MIT License.
Refer to individual plugin directories for specific licensing details.
