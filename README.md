# InSpec ssl_certificate profile

A library InSpec compliance profile containing an ssl_certificate resource that allows you to validate your SSL Certificates for properties like: key size, hash algorithm, days before expire, existence, trust, etc

The controls you find in the `./controls` directory are sample ones to demonstrate how to use the `ssl_certificate` resource.

## Usage

- Add this to your profile's inspec.yml to ensure a correct inspec version and define the profile dependency:

```yaml
supports:
  - inspec: '~> 1.0'
depends:
  - name: ssl-certificate-profile
    git: https://github.com/alexpop/ssl-certificate-profile
    version: '~> 0.1'
```

- Use the `ssl_certificate` resource in your profiles, the same way you'd use core InSpec resources like file, service, command, etc.

```ruby
# Verify the SSL certificate of a specific host and port
control 'CHECK github.com' do
  impact 0.7
  title 'Verify github.com`s SSL certificate'
  describe ssl_certificate(host: 'github.com', port: 443) do
    it { should exist }
    it { should be_trusted }
    its('ssl_error') { should eq nil }
    its('signature_algorithm') { should eq 'sha256WithRSAEncryption' }
    its('key_algorithm') { should eq 'RSA' }
    its('key_size') { should be >= 2048 }
    its('hash_algorithm') { should cmp /SHA(256|384|512)/ }
    its('expiration_days') { should be >= 30 }
  end
end

# Verify the SSL certificate using a full path
control 'CHECK cert using path' do
  impact 0.9
  title 'Verify SSL certificate from a path'
  describe file('/etc/httpd/ssl/cert.crt') do
    it { should exist }
  end
  describe ssl_certificate(path: '/etc/httpd/ssl/cert.crt') do
    it { should exist }
    its('key_size') { should be >= 2048 }
  end
end

# Verify the SSL certificate of the InSpec target
control 'CHECK github.com' do
  impact 0.7
  title 'Verify target`s SSL certificate'
  describe ssl_certificate(port: 443) do
    it { should exist }
    its('key_size') { should be >= 2048 }
  end
end
```
