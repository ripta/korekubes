#!/usr/bin/env ruby

# This file generates korekube.json, and is intended to document the evolution
# of the configuration.
AWS_INSTANCE_TYPE  = 't2.micro'
AWS_REGION         = 'us-west-2'
COREOS_VERSION     = '717.3.0'
KUBERNETES_VERSION = '0.21.1'
OUTPUT_FILE        = 'korekube.json'

require 'json'

require_relative 'lib/coreos_images'
require_relative 'lib/packer_template'

user_vars = {
  aws_access_key:    env_var('aws_access_key'),
  aws_secret_key:    env_var('aws_secret_key'),
  aws_region:        AWS_REGION,
  aws_ami_id:        coreos_ami(version: COREOS_VERSION, region: AWS_REGION),
  aws_instance_type: 't2.micro',
  coreos_version:    "v#{COREOS_VERSION}",
  image_name:        "korekube (coreos-v#{COREOS_VERSION} kubernetes-v#{KUBERNETES_VERSION}) at {{timestamp}}",
  kubernetes_url:    "https://bintray.com/artifact/download/ripta/generic/kubernetes-v#{KUBERNETES_VERSION}-1.0.tar.gz",
  kubernetes_version:"v#{KUBERNETES_VERSION}"
}

ami_builder = {
  type:          'amazon-ebs',
  access_key:    user_var('aws_access_key'),
  secret_key:    user_var('aws_secret_key'),
  region:        user_var('aws_region'),
  source_ami:    user_var('aws_ami_id'),
  instance_type: user_var('aws_instance_type'),
  ssh_username:  'core',
  ami_name:      user_var('image_name'),
  vpc_id:        user_var('vpc_id'),
  subnet_id:     user_var('subnet_id')
}

main_config = {
  variables: user_vars,
  builders:  [ami_builder],
  'post-processors' => ['vagrant'],
  provisioners: [
    {
      type:    'shell',
      scripts: [
        'remote-scripts/kubernetes.sh'
      ]
    }
  ]
}

File.open(OUTPUT_FILE, 'w') do |f|
  f.puts JSON.pretty_generate(main_config)
end

STDERR.puts "Generated #{OUTPUT_FILE}"
