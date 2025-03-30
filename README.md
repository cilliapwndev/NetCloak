# NetCloak

NetCloak is a terminal-based user interface (TUI) wrapper for OpenVPN, providing a seamless and intuitive way to manage and monitor your VPN connections. Designed for efficiency, NetCloak enables users to select, connect, and monitor OpenVPN tunnels in real time with an interactive interface inspired by btop++.

## Features

- **TUI-Based VPN Management**: Easily select and start OpenVPN configurations from a simple terminal interface.
- **Real-Time Monitoring**: Track VPN connection status, latency, and tunnel uptime dynamically.
- **Interactive Controls**:
  - **[R]** Reconnect
  - **[D]** Disconnect
  - **[Q]** Quit
- **Latency Visualization**: Displays latency trends in a bar graph format for quick insights.
- **Minimal Dependencies**: Runs using Curses and OpenVPN, keeping the setup lightweight.
- **Future Proxy Support**: Proxy chains functionality will be added in future updates.

## Installation

### Prerequisites

Ensure you have the following installed on your system:

- **OpenVPN**
- **Ruby** (latest version recommended)
- **Curses** gem for Ruby

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

### Setup

```sh
# Clone the repository
git clone https://github.com/cilliapwndev/NetCloak.git
cd netcloak

# Install dependencies
gem install curses
```

## Usage

1. **Navigate to your OpenVPN configuration directory**
   ```sh
   cd /path/to/ovpn/configs
   ```
2. **Run NetCloak**
   ```sh
   ruby netcloak.rb
   ```
3. **Select an OpenVPN configuration file**
4. **Monitor VPN performance**
5. **Use interactive keys to manage the connection**

## Demo

<img src="https://i.imgur.com/UvHNBof.gif"/>

## Roadmap

- Add support for WireGuard integration
- Improve UI with additional statistics
- Implement configuration profiles for quick VPN switching
- Enhance security features with automatic kill-switch
- In the future, NetCloak will be available as a Ruby gem for easier installation and updates.
- Future updates will include proxy chains support.

## Contributing

We welcome contributions! Feel free to open issues or submit pull requests to improve NetCloak.

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

---

**Stay anonymous, stay secure with NetCloak.**

