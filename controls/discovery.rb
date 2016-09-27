# encoding: utf-8

return

title 'Profile that discovers SSL ports on the target and checks their SSL Certificate'

node_host = command('hostname').stdout.strip

# Get all tcp ports listening on the node
sslports = port.protocols(/tcp/).entries.uniq do |entry|
  entry['port']
end

# Filter out ports that don't respond to any version of SSL
sslports = sslports.find_all do |socket|
  ssl(port: socket.port).enabled?
end

# Check the SSL Certificate for the ramaining ports
sslports.each do |socket|
  control 'SSL Certificate' do
    title "hostname=#{node_host}, port=#{socket.port}, process=#{socket.process.inspect} (#{socket.pid})"
    impact 1.0
    describe ssl_certificate(port: socket.port) do
      it { should exist }
      its('key_size') { should be >= 2048 }
      its('expiration_days') { should be >= 60 }
    end
  end
end
