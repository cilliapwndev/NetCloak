# netcloak.gemspec
Gem::Specification.new do |spec|
    spec.name          = "netcloak"
    spec.version       = "1.0.2"
    spec.authors       = ["Mark Angelo P. Santonil"]
    spec.email         = ["cillia2203@gmail.com"]
  
    spec.summary       = "A CLI tool to monitor and manage OpenVPN connections."
    spec.description   = "NetCloak provides a curses-based interface to manage VPN configurations, monitor latency, and control connections."
    spec.homepage      = "https://github.com/cilliapwndev/NetCloak"
    spec.license       = "GNU v.3"
  
    spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE.txt"]
    spec.bindir        = "bin"
    spec.executables   = ["netcloak"]
    spec.require_paths = ["lib"]
  
    spec.add_dependency "curses", "~> 1.4"
    spec.add_dependency "open3", "~> 0.1"
  
    spec.add_development_dependency "bundler", "~> 2.0"
    spec.add_development_dependency "rake", "~> 13.0"
    spec.add_development_dependency "rspec", "~> 3.0"
  end