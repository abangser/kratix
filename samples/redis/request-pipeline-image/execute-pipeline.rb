#!/usr/bin/env ruby

require 'yaml'

request = YAML.load_file('/input/object.yaml')
instance = YAML.load_file('/tmp/transfer/redis-instance.yaml')

instance_name = request.dig('spec', 'name') || raise('spec.name cannot be empty')
instance['metadata']['name'] = instance_name

password = request.dig('spec', 'password')

unless password.nil?
  require 'base64'
  authSecret = "#{instance_name}-auth-password"
  instance['spec']['auth'] = { 'secretPath' => authSecret }

  File.open('/output/secret.yaml', 'w') do |f|
    YAML.dump({
      'apiVersion' => 'v1',
      'kind' => 'Secret',
      'metadata' => {'name' => authSecret},
      'type' => 'Opaque',
      'data' => { authSecret => Base64.encode64(password).strip },
    }, f)
  end
end

File.open('/output/instance.yaml', 'w') do |f|
  YAML.dump(instance, f)
end
