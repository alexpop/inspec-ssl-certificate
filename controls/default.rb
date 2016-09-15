# encoding: utf-8

title 'Sample use of the ssl_certificate resource'

control 'CHECK port with implicit' do
  impact 0.9
  title 'Verify SSL certificate, a few different ways'
  # defaults to port: 443 and target hostname
  describe ssl_certificate do
    it { should_not be_trusted }
  end
  # defaults to target hostname
  describe ssl_certificate(port: 443) do
    it { should_not be_trusted }
  end
  # defaults to port: 443
  describe ssl_certificate(host: '192.168.56.40', timeout: 5) do
    it { should_not be_trusted }
  end
end

control 'CHECK github.com' do
  impact 0.7
  # title overrides skip_message in cli format
  title 'Verify github.com`s SSL certificate'
  end_of_the_world = Time.parse('2020-02-20 20:20:20 UTC')
  # Uses the custom ssl_certificate InSpec resource from ../libraries/
  describe ssl_certificate(host: 'github.com', port: 443) do
    it { should exist }
    it { should be_trusted }
    its('ssl_error') { should eq nil }
    its('signature_algorithm') { should eq 'sha256WithRSAEncryption' }
    its('key_algorithm') { should eq 'RSA' }
    its('key_size') { should be >= 2048 }
    its('hash_algorithm') { should cmp /SHA(256|384|512)/ }
    #its('hash_size') { should be >= 256 }
    its('expiration_days') { should be >= 30 }
    its('expiration') { should be < end_of_the_world }
  end
end

control 'CHECK bla.badssl.com:44333' do
  impact 0.9
  title 'Verify SSL certificate for bad port'
  describe ssl_certificate(host: 'bla.badssl.com', port: 44333, timeout: 5) do
    it { should exist }
  end
end

control 'CHECK cert at path' do
  impact 0.9
  title 'Verify SSL certificate from a path'
  describe ssl_certificate(path: '/etc/httpd/ssl/cert.crt') do
    it { should exist }
    its('key_size') { should be >= 2048 }
  end
end

control 'CHECK sha1-2016.badssl.com' do
  impact 0.9
  title 'Verify an sha1 SSL certificate'
  # Uses the custom ssl_certificate InSpec resource from ../libraries/
  describe ssl_certificate(host: 'sha1-2016.badssl.com', port: 443) do
    it { should exist }
    its('hash_algorithm') { should cmp 'SHA256' }
    its('key_size') { should be >= 2048 }
  end
end

control 'CHECK wrong.host.badssl.com' do
  impact 0.9
  title 'Verify untrusted SSL certificate'
  describe ssl_certificate(host: 'wrong.host.badssl.com') do
    it { should be_trusted }
    its('ssl_error') { should eq nil }
    its('hash_algorithm') { should eq 'SHA256' }
  end
end

control 'CHECK expired.badssl.com' do
  impact 1.0
  title 'Verify an expired SSL certificate'
  describe ssl_certificate(host: 'expired.badssl.com') do
    it { should exist }
    it { should be_trusted }
    its('ssl_error') { should eq nil }
    its('expiration_days') { should be < 0 }
  end
end

control 'CHECK dh1024.badssl.com' do
  impact 0.9
  title 'Verify 1024 bit SSL certificate'
  # Uses the custom ssl_certificate InSpec resource from ../libraries/
  describe ssl_certificate(host: 'dh1024.badssl.com') do
    it { should exist }
    its('key_size') { should be >= 2048 }
  end
end
