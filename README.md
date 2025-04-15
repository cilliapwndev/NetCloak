# NetCloak

**NetCloak** is a terminal-based user interface (TUI) wrapper for OpenVPN, providing a seamless and intuitive way to manage and monitor your VPN connections. Designed for efficiency, NetCloak enables users to select, connect, and monitor OpenVPN tunnels in real time with an interactive interface inspired by **btop++**.

Now available as a Ruby gem, NetCloak can be easily installed and run directly from any directory containing your `.ovpn` files.

[![Gem Version](https://badge.fury.io/rb/netcloak.svg)](https://badge.fury.io/rb/netcloak)
[![Downloads](https://img.shields.io/gem/dt/netcloak.svg)](https://rubygems.org/gems/netcloak)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Made with Ruby](https://img.shields.io/badge/Made%20with-Ruby-red.svg)](https://www.ruby-lang.org)
[![OpenVPN Compatible](https://img.shields.io/badge/OpenVPN-Compatible-brightgreen.svg)](https://openvpn.net/)

---

## Features

- **TUI-Based VPN Management**: Easily select and start OpenVPN configurations from a simple terminal interface.
- **Real-Time Monitoring**: Track VPN connection status, latency, and tunnel uptime dynamically.
- **Interactive Controls**:
  - **[R]** Reconnect
  - **[D]** Disconnect
  - **[Q]** Quit
- **Latency Visualization**: Displays latency trends in a bar graph format for quick insights.
- **Minimal Dependencies**: Runs using Curses and OpenVPN, keeping the setup lightweight.
- **Proxy Support (Coming Soon)**: Proxy chains functionality will be added in future updates.

---

## Installation

### Prerequisites

Ensure you have the following installed on your system:

- **OpenVPN**
- **Ruby** (latest version recommended)

### Install OpenVPN

#### Debian-based (Ubuntu, Debian, etc.)
```sh
sudo apt install openvpn -y
```

#### Fedora
```sh
sudo dnf install openvpn -y
```

#### CentOS
```sh
sudo yum install openvpn -y
```

#### Arch Linux
```sh
sudo pacman -S openvpn --noconfirm
```

#### openSUSE
```sh
sudo zypper install openvpn
```

### Install NetCloak via RubyGems

```sh
gem install netcloak
```

---

## Usage

1. **Navigate to the directory containing your OpenVPN configuration files (`.ovpn`)**
   ```sh
   cd /path/to/ovpn/configs
   ```
2. **Run NetCloak**
   ```sh
   netcloak
   ```
3. **Select an OpenVPN configuration file from the list**
4. **Monitor VPN performance and control your connection using hotkeys**

---

## Demo

<img src="https://i.imgur.com/UvHNBof.gif"/>

---

## Roadmap

- Add support for WireGuard integration
- Improve UI with additional statistics
- Implement configuration profiles for quick VPN switching
- Enhance security features with automatic kill-switch
- Extend support for proxy chains

---

## Contributing

We welcome contributions! Feel free to open issues or submit pull requests to improve NetCloak.

---

## License

This program is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License** as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY**; without even the implied warranty of **MERCHANTABILITY** or **FITNESS FOR A PARTICULAR PURPOSE**. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

---

**Stay anonymous, stay secure with NetCloak.**
```

Let me know if you want a version with badges (e.g. gem version, license, etc.) or support for other VPN protocols!
