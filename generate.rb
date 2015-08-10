#!/usr/bin/env ruby

# This file generates the packer JSON file, and is intended to document the
# evolution of the configuration. Base configuration changes should be made in
# `config/generate.json`, whereas structural changes should be made here.

require 'json'

require_relative 'lib/meta_config'
require_relative 'lib/coreos_images'
require_relative 'lib/packer_template'

meta = MetaConfig.new(JSON.parse(File.read('config/generate.json')))

user_vars = {
  aws_access_key:    env_var('aws_access_key'),
  aws_secret_key:    env_var('aws_secret_key'),
  aws_region:        meta.aws.region,
  aws_ami_id:        coreos_ami(version: meta.coreos.version, region: meta.aws.region),
  aws_instance_type: 't2.micro',
  coreos_version:    "v#{meta.coreos.version}",
  image_name:        "korekube (coreos-v#{meta.coreos.version} kubernetes-v#{meta.kubernetes.version}) at {{timestamp}}",
  kubernetes_url:    "https://bintray.com/artifact/download/ripta/generic/kubernetes-v#{meta.kubernetes.version}-1.0.tar.gz",
  kubernetes_version:"v#{meta.kubernetes.version}"
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
  iso_url:           "http://#{meta.coreos.channel}.release.core-os.net/amd64-usr/#{meta.coreos.version}/coreos_production_iso_image.iso",
  iso_checksum:      meta.coreos.iso_check.checksum,
  iso_checksum_type: meta.coreos.iso_check.type,
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
    "coreos-install -d /dev/sda -C #{meta.coreos.channel} -V #{meta.coreos.version} -b http://{{ .HTTPIP }}:{{ .HTTPPort }}/coreos/#{meta.coreos.channel} -c bootstrap.yml<enter>",
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
        "COREOS_VERSION=#{meta.coreos.version}",
        "KUBERNETES_VERSION=#{meta.kubernetes.version}"
      ]
    }
  ],
  'post-processors' => [
    {
      type: 'vagrant',
      output: "./build/coreos-#{meta.coreos.version}-{{.Provider}}.box",
      vagrantfile_template: 'vagrant/Vagrantfile.tmpl',
      include: [
        'vagrant/base_mac.rb',
        'vagrant/change_host_name.rb',
        'vagrant/configure_networks.rb'
      ]
    }
  ]
}

File.open(meta.output_file, 'w') do |f|
  f.puts JSON.pretty_generate(main_config)
end

STDERR.puts "Generated #{meta.output_file}"
system "md5 -q #{meta.output_file}"

