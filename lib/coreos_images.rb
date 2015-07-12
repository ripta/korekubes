
COREOS_AMI_TREE = JSON.parse(File.read('config/ami.json'))
def coreos_ami(version: '717.3.0', region: 'us-east-1')
	COREOS_AMI_TREE['images'].fetch(version).fetch(region)
rescue KeyError
  abort "AMI configuration not found for CoreOS v#{version} in region #{region}"
end
