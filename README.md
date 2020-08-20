# SSL Certificate - InSpec Profile

## Description

A library InSpec compliance profile containing an `ssl_certificate` resource that allows you to validate your SSL Certificates for properties like: key size, hash algorithm, days before expire, existence, trust, etc. Unless you specify a path to the certificate file on the node, the `ssl_certificate` resource will retrieve the certificate via an HTTPS request from the machine where InSpec is executed.

The controls you find in the `./controls` directory are sample ones to demonstrate how to use the `ssl_certificate` resource.

## Requirements

* [InSpec](https://github.com/chef/inspec) version 1.0 or above

## Usage

- Add this to your profile's `inspec.yml` to ensure a correct InSpec version and define the profile dependency:

```yaml
depends:
- name: ssl-certificate-profile
  git: https://github.com/alexpop/ssl-certificate-profile
  version: '~> 1.0'
```

### Examples

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
    its('hash_algorithm') { should cmp /SHA(256|384|512)/ }
    its('issuer_organization') { should be_in ['Amazon', 'COMODO CA Limited'] }
    its('expiration_days') { should be > 30 }
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
  end
end

# Verify the SSL certificate of the InSpec target
control 'CHECK github.com' do
  impact 0.7
  title 'Verify target`s SSL certificate'
  describe ssl_certificate(port: 443) do
    it { should exist }
  end
end
```


### `ssl_certificate` resource parameters:

Name | Required | Type | Description
--- | --- | --- | ---
path | no | String | Allows to specify a certificate file on the target node. No HTTPS request will be done so the parameters below are not used if this is defined.
host | no | String | Resolvable hostname or IP for the HTTPS request used to retrieve the SSL Certificate information. Defaults to the InSpec target host if not specified.
port | no | Numeric | Port for the HTTPS request, defaults to 443 if not specified.
timeout | no | Numeric | Number of seconds to wait for the connection to open. The default value is 60 seconds.

Examples of instantiating the resource with a Hash of the above parameters:

```ruby
describe ssl_certificate(version: '2016-06-30', timeout: 3, curl_path: '/usr/bin/curl') do
  it { should exist }
end
# or via the path parameter
describe ssl_certificate(path: '/etc/httpd/ssl/cert.crt') do
  its('expiration_days') { should be >= 30 }
end
```

## License and Author

* Author: Alex Pop [alexpop](https://github.com/alexpop)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
