# encoding: utf-8

# stop here for now
return

title 'Sample profile on how to use the ssl_certificate resource'

control 'CHECK github.com' do
  impact 0.7
  title 'Verify github.com`s SSL certificate'
  one_day = Time.parse('2022-02-02 20:20:20 UTC')
  # Uses the custom ssl_certificate InSpec resource from ../libraries/
  describe ssl_certificate(host: 'github.com', port: 443) do
    it { should exist }
    it { should be_trusted }
    its('ssl_error') { should eq nil }
    its('signature_algorithm') { should eq 'sha256WithRSAEncryption' }
    its('hash_algorithm') { should cmp /SHA(256|384|512)/ }
    its('expiration_days') { should be >= 30 }
    its('expiration') { should be < one_day }
  end
end

control 'CHECK wrong.host.badssl.com' do
  impact 0.9
  title 'Verify untrusted SSL certificate'
  describe ssl_certificate(host: 'wrong.host.badssl.com') do
    it { should_not be_trusted }
    its('ssl_error') { should eq "hostname 'wrong.host.badssl.com' does not match the server certificate" }
    its('hash_algorithm') { should eq 'SHA256' }
  end
end

control 'CHECK expired.badssl.com' do
  impact 1.0
  title 'Verify an expired SSL certificate'
  describe ssl_certificate(host: 'expired.badssl.com') do
    it { should exist }
    it { should_not be_trusted }
    its('ssl_error') { should eq "SSL_connect returned=1 errno=0 state=error: certificate verify failed" }
    its('expiration_days') { should be < 0 }
  end
end

control 'CHECK sha1-2016.badssl.com' do
  impact 0.9
  title 'Verify an sha1 SSL certificate'
  describe ssl_certificate(host: 'sha1-2016.badssl.com', port: 443) do
    it { should exist }
    its('hash_algorithm') { should cmp 'SHA1' }
  end
end

control 'CHECK bla.badssl.com:44333' do
  impact 0.9
  title 'Verify SSL certificate for bad port'
  describe ssl_certificate(host: 'bla.badssl.com', port: 44333, timeout: 3) do
    it { should exist }
  end
end

control 'CHECK cert at path' do
  impact 0.9
  title 'Verify SSL certificate from a path'
  describe ssl_certificate(path: '/etc/httpd/ssl/cert.crt') do
    it { should exist }
  end
end

control 'CHECK implicit' do
  impact 0.9
  title 'Verify SSL certificate, a few different ways'
  # defaults to port: 443 and hostname of the target
  describe ssl_certificate do
    it { should_not be_trusted }
  end
  # defaults to the hostname of the target
  describe ssl_certificate(port: 443) do
    it { should_not be_trusted }
  end
  # defaults to port: 443
  describe ssl_certificate(host: '192.168.56.40', timeout: 3) do
    it { should_not be_trusted }
  end
end
