#!/usr/bin/env ruby

# This file generates korekube.json, and is intended to document the evolution
# of the configuration.
AWS_INSTANCE_TYPE  = 't2.micro'
AWS_REGION         = 'us-west-2'
COREOS_VERSION     = '717.3.0'
COREOS_ISO_CHECK   = {
  checksum: '39074d0233c48ca199b987a0944fdda2',
  type:     'md5'
}
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

vmware_builder = {
  type:              'vmware-iso',
  iso_url:           "http://stable.release.core-os.net/amd64-usr/#{COREOS_VERSION}/coreos_production_iso_image.iso",
  iso_checksum:      COREOS_ISO_CHECK.fetch(:checksum, ''),
  iso_checksum_type: COREOS_ISO_CHECK.fetch(:type, 'none'),
  ssh_username:      'core',
  ssh_port:          22,
  ssh_key_path:      'keys/coreos',
  ssh_wait_timeout:  '8m',
  http_directory:    'bootstrap',
  vmx_data: {
    memsize: '1024',
    numvcpus: '1'
  },
  boot_wait:         '15s',
  boot_command: [
    'sudo -i<enter>',
    'systemctl stop sshd.socket<enter>',
    'wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.yml<enter>',
    'coreos-install -d /dev/sda -C stable -c bootstrap.yml<enter>',
    'reboot<enter>'
  ],
  shutdown_command:  'sudo shutdown -P now',
  skip_compaction:   false
}

main_config = {
  variables: user_vars,
  builders:  [
    ami_builder,
    vmware_builder
  ],
  provisioners: [
    {
      type: 'file',
      source: 'services',
      destination: '/tmp'
    },
    {
      type: 'shell',
      pause_before: '15s',
      scripts: [
        'remote-scripts/kubernetes.sh',
        'remote-scripts/services.sh'
      ],
      environment_vars: [
        "COREOS_VERSION=#{COREOS_VERSION}",
        "KUBERNETES_VERSION=#{KUBERNETES_VERSION}"
      ]
    }
  ],
  'post-processors' => [
    {
      type: 'vagrant',
      output: "./build/coreos-#{COREOS_VERSION}-{{.Provider}}.box",
      vagrantfile_template: 'vagrant/Vagrantfile.tmpl',
      include: [
        'vagrant/base_mac.rb',
        'vagrant/change_host_name.rb',
        'vagrant/configure_networks.rb'
      ]
    }
  ]
}

File.open(OUTPUT_FILE, 'w') do |f|
  f.puts JSON.pretty_generate(main_config)
end

STDERR.puts "Generated #{OUTPUT_FILE}"
system "md5 -q #{OUTPUT_FILE}"

