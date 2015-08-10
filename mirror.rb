#!/usr/bin/env ruby

require 'fileutils'
require 'json'

config = JSON.parse(File.read('config/mirrors.yml'))

def build_file(config, version, artifact)
  target_dir = config.fetch('target_dir')
  FileUtils.mkdir_p("#{target_dir}/#{version}")
  "#{target_dir}/#{version}/#{artifact}"
end

def build_url(config, version, artifact)
  base_url = config.fetch('base_url')
  "#{base_url}/#{version}/#{artifact}"
end

def compute_sha512_for(file)
  output = `shasum -a 512 #{file}`
  value, name = output.chomp.split(/\s+/, 2)
  value
end

def download(config, version, artifact)
  artifact_file = build_file(config, version, artifact)
  return if File.exist?(artifact_file)

  artifact_url = build_url(config, version, artifact)
  $stderr.puts "#{artifact_url} -> #{artifact_file}"
  system("curl -L -o #{artifact_file} #{artifact_url}")
end

def parse_sig_artifact(sig_artifact_file)
  sigs = {}

  File.open(sig_artifact_file) do |file|
    current_type = nil
    file.each_line do |line|
      if line.match(/^#\s+(\S+)\s+HASH/i)
        current_type = $1.to_s.downcase
      else
        value, name = line.chomp.split(/\s+/, 2)
        sigs[name] ||= {}
        sigs[name][current_type] = value
      end
    end
  end

  sigs
end

def verify!(config, version, artifact, sig_artifact)
  artifact_file = build_file(config, version, artifact)
  sig_artifact_file = build_file(config, version, sig_artifact)

  abort "#{artifact_file} does not exist"     unless File.exist?(artifact_file)
  abort "#{sig_artifact_file} does not exist" unless File.exist?(sig_artifact_file)

  sigs = parse_sig_artifact(sig_artifact_file)
  artifact_sig = compute_sha512_for(artifact_file)

  if sigs.fetch(artifact).fetch('sha512') == artifact_sig
    $stderr.puts "#{artifact_file} verified"
  else
    abort "#{artifact_file} did not pass the signature verification"
  end
end

config.fetch('versions').each_pair do |version, is_active|
  next unless is_active
  config.fetch('artifacts').each do |artifact|
    download(config, version, artifact)

    sig_artifact = "#{artifact}.DIGESTS"
    download(config, version, sig_artifact)

    verify!(config, version, artifact, sig_artifact)
  end
end

