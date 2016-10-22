# encoding: utf-8
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# InSpec profile that discovers SSL ports on target and checks their SSL Certificates
# Author: Alex Pop
# Source from https://github.com/alexpop/ssl-certificate-profile

title 'Profile that discovers SSL ports on the target and checks their SSL Certificate'

INVALID_TARGETS = %w{ 127.0.0.1 0.0.0.0 ::1 :: }

# Array of TCP ports to exclude from SSL checking. For example: [443, 8443]
exclude_ports = []

target_hostname = command('hostname').stdout.strip

# Find all TCP ports on the system, IPv4 and IPv6
# Eliminate duplicate ports for cleaner reporting and faster scans
tcpports = port.protocols(/tcp/).entries.uniq do |entry|
  entry['port']
end

# Sort the array by port number
tcpports = tcpports.sort_by do |entry|
  entry['port']
end

# Make tcpports an array of hashes to be passed to the ssl resource
tcpports = tcpports.map do |tcpport|
  params = { port: tcpport.port }
  # Add a host param if the listening address of the port is a valid/non-localhost IP
  params[:host] = tcpport.address unless INVALID_TARGETS.include?(tcpport.address)
  params[:socket] = tcpport
  params
end

# Filter out ports that don't respond to any version of SSL
sslports = tcpports.find_all do |tcpport|
  !exclude_ports.include?(tcpport[:port]) && ssl(tcpport).enabled?
end

# Troubleshooting control to show InSpec version and list
# discovered tcp ports and the ssl enabled ones. Always succeeds
control 'debugging' do
  title "Inspec::Version=#{Inspec::VERSION}"
  impact 0.0
  describe "tcpports=\n#{tcpports.join("\n")}" do
    it { should_not eq nil }
  end
  describe "sslports=\n#{sslports.join("\n")}" do
    it { should_not eq nil }
  end
end

# Check the SSL Certificate for the ramaining ports
sslports.each do |sslport|
  control 'SSL Certificate' do
    title "hostname=#{sslport[:host] || target_hostname}, port=#{sslport[:port]}, process=#{sslport[:socket].process.inspect} (#{sslport[:socket].pid})"
    impact 1.0
    describe ssl_certificate(sslport) do
      it { should exist }
      its('key_size') { should be >= 2048 }
      its('expiration_days') { should be >= 60 }
    end
  end
end
