require 'curses'
require 'open3'

require_relative 'netcloak/version'

module NetCloak
  class Error < StandardError; end

class NetCloak
  COLORS = {
    primary: 1,
    success: 2,
    danger: 3,
    warning: 4,
    accent: 5
  }

  def initialize
    @vpn_pid = nil
    @selected_ovpn = nil
    @latencies = []
    @start_time = Time.now
    @running = true
    init_ui
  end

  def init_ui
    Curses.init_screen
    Curses.curs_set(0)  # Hide cursor
    Curses.start_color
    Curses.noecho
    Curses.stdscr.keypad(true)
    Curses.stdscr.nodelay = true
    
    # Initialize color pairs
    Curses.init_pair(COLORS[:primary], Curses::COLOR_CYAN, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS[:success], Curses::COLOR_GREEN, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS[:danger], Curses::COLOR_RED, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS[:warning], Curses::COLOR_YELLOW, Curses::COLOR_BLACK)
    Curses.init_pair(COLORS[:accent], Curses::COLOR_MAGENTA, Curses::COLOR_BLACK)
  end

  def show_connecting_screen
    win = Curses.stdscr
    win.clear
    print_header("Connecting to VPN...")
    
    win.setpos(5, (Curses.cols - 20) / 2)
    win.attron(Curses.color_pair(COLORS[:primary])) do
      win.addstr("Establishing connection")
    end
    
    3.times do |i|
      win.setpos(7, (Curses.cols - 3) / 2)
      win.addstr("#{'.' * (i + 1)}   ")
      win.refresh
      sleep 0.5
    end
  end

  def list_ovpn_files
    files = Dir.glob("*.ovpn")
    if files.empty?
      show_error("No OpenVPN (.ovpn) files found!")
      exit(1)
    end
    files
  end

  def choose_ovpn_file(files)
    menu_win = Curses::Window.new(Curses.lines, Curses.cols, 0, 0)
    menu_win.keypad = true
    
    selection = 0
    top_line = 0
    
    loop do
      # Clear only the menu area (lines 3 to bottom)
      menu_win.setpos(3, 0)
      (3..Curses.lines-1).each { menu_win.addstr(" " * Curses.cols) }
      
      print_header_to_window(menu_win, "Select VPN Configuration")
      
      visible_start = top_line
      visible_end = [top_line + Curses.lines - 8, files.size - 1].min
      
      (visible_start..visible_end).each do |index|
        menu_win.setpos(4 + index - top_line, 4)
        if index == selection
          menu_win.attron(Curses.color_pair(COLORS[:accent]) | Curses::A_BOLD) { menu_win.addstr("> #{files[index]}") }
        else
          menu_win.addstr("  #{files[index]}")
        end
      end

      menu_win.setpos(Curses.lines - 3, 4)
      menu_win.addstr("↑/↓: Select  ENTER: Confirm  Q: Quit")

      menu_win.refresh

      case menu_win.getch
      when Curses::Key::UP 
        if selection > 0
          selection -= 1
          top_line = selection if selection < top_line
        end
      when Curses::Key::DOWN 
        if selection < files.size - 1
          selection += 1
          top_line = selection - (Curses.lines - 8) + 1 if selection >= top_line + (Curses.lines - 8)
        end
      when 10 then return files[selection]  # Enter
      when 'q' then @running = false; return nil
      end
    end
  ensure
    menu_win.close if menu_win
  end

  def print_header_to_window(win, title)
    cols = Curses.cols
    
    win.setpos(1, 0)
    win.attron(Curses.color_pair(COLORS[:primary]) | Curses::A_BOLD) do
      win.addstr(" " * cols)
      win.setpos(1, (cols - title.length) / 2)
      win.addstr(title)
    end
    
    win.setpos(2, 0)
    win.attron(Curses.color_pair(COLORS[:primary])) do
      win.addstr("─" * cols)
    end
  end

  def start_vpn(ovpn_file)
    show_connecting_screen
    
    log_file = "/tmp/openvpn_#{Time.now.to_i}.log"
    @vpn_pid = `sudo openvpn --config #{ovpn_file} > #{log_file} 2>&1 & echo $!`.strip.to_i

    win = Curses.stdscr
    connected = false
    
    30.times do |i|
      break unless @running
      
      win.setpos(9, (Curses.cols - 20) / 2)
      win.addstr("Attempt #{i+1}/30" + " " * 10)
      
      if File.exist?(log_file)
        log_content = File.read(log_file)
        
        if log_content.include?("Initialization Sequence Completed")
          connected = true
          break
        elsif log_content.include?("ERROR")
          show_error("Connection failed! Check #{log_file}")
          return false
        end
        
        last_line = log_content.lines.last.to_s.strip
        win.setpos(11, (Curses.cols - [last_line.length, Curses.cols].min) / 2)
        win.addstr(last_line[0..Curses.cols-1] + " " * 10)
      end
      
      win.refresh
      sleep 1
    end

    if connected
      win.setpos(13, (Curses.cols - 20) / 2)
      win.attron(Curses.color_pair(COLORS[:success])) do
        win.addstr("Connected successfully!")
      end
      win.refresh
      sleep 1
      true
    else
      show_error("Connection timeout after 30 seconds") if @running
      false
    end
  end

  def vpn_connected?
    return false unless @vpn_pid
    system("ps -p #{@vpn_pid} > /dev/null") && 
    (system("ip a show tun0 > /dev/null") || system("ip a show tap0 > /dev/null"))
  end

  def get_latency
    result = `ping -c 1 8.8.8.8 2>&1`
    if result =~ /rtt min\/avg\/max\/mdev = ([\d.]+)\/([\d.]+)\/([\d.]+)\/([\d.]+) ms/
      [$1.to_f, $2.to_f, $3.to_f]
    else
      nil
    end
  rescue
    nil
  end

  def draw_graph(win, data, width, height, y, x)
    valid_data = data.compact.select { |v| v.is_a?(Numeric) }
    return if valid_data.empty?

    max_value = valid_data.max.to_f
    min_value = valid_data.min.to_f
    range = (max_value - min_value) > 0 ? (max_value - min_value) : 1.0

    scaled_data = valid_data.last(width - 4).map do |value|
      ((height - 1) - (((value - min_value) / range) * (height - 1))).to_i
    end

    scaled_data.each_with_index do |y_pos, x_pos|
      next unless y_pos.between?(0, height-1)
      win.setpos(y + height - 1 - y_pos, x + x_pos)
      win.attron(Curses.color_pair(COLORS[:accent])) { win.addstr("▄") }
    end

    win.setpos(y + height, x)
    win.addstr("#{min_value.round}ms")
    win.setpos(y + height, x + width - 5)
    win.addstr("#{max_value.round}ms")
  end

  def print_header(title)
    win = Curses.stdscr
    cols = Curses.cols
    
    win.setpos(1, 0)
    win.attron(Curses.color_pair(COLORS[:primary]) | Curses::A_BOLD) do
      win.addstr(" " * cols)
      win.setpos(1, (cols - title.length) / 2)
      win.addstr(title)
    end
    
    win.setpos(2, 0)
    win.attron(Curses.color_pair(COLORS[:primary])) do
      win.addstr("─" * cols)
    end
  end

  def show_error(message)
    win = Curses.stdscr
    win.setpos(Curses.lines - 2, (Curses.cols - message.length) / 2)
    win.attron(Curses.color_pair(COLORS[:danger]) | Curses::A_BOLD) do
      win.addstr(message)
    end
    win.refresh
    sleep 2
  end

  def show_disconnect_menu
    menu_win = Curses::Window.new(Curses.lines, Curses.cols, 0, 0)
    menu_win.keypad = true
    
    selection = 0
    options = [
      "Reconnect to current config",
      "Choose another VPN config", 
      "Exit application"
    ]
    
    loop do
      # Clear only the menu area (lines 3 to bottom)
      menu_win.setpos(3, 0)
      (3..Curses.lines-1).each { menu_win.addstr(" " * Curses.cols) }
      
      print_header_to_window(menu_win, "VPN Disconnected")
      
      menu_win.setpos(5, 4)
      menu_win.attron(Curses.color_pair(COLORS[:primary])) do
        menu_win.addstr("What would you like to do?")
      end

      options.each_with_index do |option, index|
        menu_win.setpos(7 + index, 4)
        if index == selection
          menu_win.attron(Curses.color_pair(COLORS[:accent]) | Curses::A_BOLD) do
            menu_win.addstr("> #{option}")
          end
        else
          menu_win.addstr("  #{option}")
        end
      end

      menu_win.setpos(11, 4)
      menu_win.addstr("↑/↓: Select  ENTER: Confirm")

      menu_win.refresh

      case menu_win.getch
      when Curses::Key::UP then selection = [selection - 1, 0].max
      when Curses::Key::DOWN then selection = [selection + 1, options.size - 1].min
      when 10 # Enter key
        case selection
        when 0 then return :reconnect_same
        when 1 then return :reconnect_new
        when 2 then return :exit
        end
      when 'q' then return :exit
      end
    end
  ensure
    menu_win.close if menu_win
  end

  def draw_monitor_screen
    win = Curses.stdscr
    
    # Only clear the content area (below header)
    win.setpos(3, 0)
    (3..Curses.lines-1).each { |i| win.addstr(" " * Curses.cols) }
    
    print_header("NetCloak Monitor")
    
    # Connection status
    status = vpn_connected? ? "CONNECTED" : "DISCONNECTED"
    color = vpn_connected? ? COLORS[:success] : COLORS[:danger]
    
    win.setpos(4, 4)
    win.attron(Curses.color_pair(COLORS[:primary])) do
      win.addstr("Status:")
    end
    win.setpos(4, 12)
    win.attron(Curses.color_pair(color) | Curses::A_BOLD) do
      win.addstr(status)
    end

    # Connection info
    elapsed_time = (Time.now - @start_time).round
    latency = get_latency&.then { |_, avg, _| avg }
    
    if latency
      @latencies << latency
      @latencies.shift if @latencies.size > 100
    end

    win.setpos(6, 4)
    win.attron(Curses.color_pair(COLORS[:primary])) do
      win.addstr("Uptime: #{elapsed_time}s")
    end

    win.setpos(7, 4)
    win.addstr("Config: #{@selected_ovpn}")

    # Current latency
    win.setpos(9, 4)
    win.attron(Curses.color_pair(COLORS[:primary])) do
      win.addstr("Current Latency:")
    end

    if latency
      status_color = if latency < 100
                      COLORS[:success]
                    elsif latency < 300
                      COLORS[:warning]
                    else
                      COLORS[:danger]
                    end
      
      win.setpos(9, 22)
      win.attron(Curses.color_pair(status_color) | Curses::A_BOLD) do
        win.addstr("#{latency.round(2)} ms")
      end
    else
      win.setpos(9, 22)
      win.attron(Curses.color_pair(COLORS[:danger])) do
        win.addstr("N/A")
      end
    end

    # Stats
    if !@latencies.empty?
      avg = (@latencies.sum / @latencies.size).round(2)
      min = @latencies.min.round(2)
      max = @latencies.max.round(2)

      win.setpos(11, 4)
      win.attron(Curses.color_pair(COLORS[:primary])) do
        win.addstr("Statistics (last #{@latencies.size} samples):")
      end

      win.setpos(12, 6)
      win.addstr("Avg: #{avg} ms")

      win.setpos(13, 6)
      win.addstr("Min: #{min} ms")

      win.setpos(14, 6)
      win.addstr("Max: #{max} ms")
    end

    # Graph
    if !@latencies.empty?
      win.setpos(16, 4)
      win.attron(Curses.color_pair(COLORS[:primary])) do
        win.addstr("Latency Trend:")
      end

      graph_width = [Curses.cols - 10, 60].min
      draw_graph(win, @latencies, graph_width, 8, 17, 6)
    end

    # Controls
    win.setpos(Curses.lines - 4, 4)
    win.attron(Curses.color_pair(COLORS[:primary])) do
      win.addstr("Controls:")
    end

    win.setpos(Curses.lines - 3, 6)
    win.addstr("[R] Reconnect  [D] Disconnect  [Q] Quit")

    win.refresh
  end

  def monitor_loop
    while @running
      draw_monitor_screen

      case Curses.stdscr.getch
      when 'q', 'Q'
        @running = false
      when 'd', 'D'
        stop_vpn
        action = show_disconnect_menu
        case action
        when :reconnect_same
          if start_vpn(@selected_ovpn)
            @start_time = Time.now
            @latencies.clear
          else
            @running = false
          end
        when :reconnect_new
          ovpn_files = list_ovpn_files
          @selected_ovpn = choose_ovpn_file(ovpn_files)
          if @selected_ovpn && start_vpn(@selected_ovpn)
            @start_time = Time.now
            @latencies.clear
          else
            @running = false
          end
        when :exit
          @running = false
        end
      when 'r', 'R'
        stop_vpn
        if start_vpn(@selected_ovpn)
          @start_time = Time.now
          @latencies.clear
        end
      end

      sleep 0.1
    end
  end

  def stop_vpn
    return unless @vpn_pid
    Process.kill('TERM', @vpn_pid) rescue nil
    @vpn_pid = nil
  end

  def run
    while @running
      ovpn_files = list_ovpn_files
      @selected_ovpn = choose_ovpn_file(ovpn_files)
      
      if @selected_ovpn && start_vpn(@selected_ovpn)
        @start_time = Time.now
        @latencies.clear
        monitor_loop
      end
    end
  rescue => e
    show_error("Error: #{e.message}")
  ensure
    stop_vpn
    Curses.close_screen
    puts "VPN disconnected" if @running
    @running = false
  end
end

end

NetCloak::NetCloak.new.run