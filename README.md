# InSpec ssl_certificate profile

This is a library InSpec profile. The controls you find in the `./controls` directory are sample ones to demonstrate how to use the `ssl_certificate` resource.

## Usage

- Add this to your profile's inspec.yml to ensure a correct version of InSpec and profile dependency:
```
supports:
  - inspec: '>= 1.0.0'
depends:
  - name: apop/ssl-certificate-profile
```
- Use the `ssl_certificate` resource in your profiles, the same way you'd use core InSpec resources (file, service, directory, command, etc).

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
