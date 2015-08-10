
task :default => [:build]

desc 'Build all images'
task :build => [:generate] do
  sh "packer build -var 'vpc_id=#{ENV['VPC_ID']}' -var 'subnet_id=#{ENV['SUBNET_ID']}' korekube.json"
end

desc 'Build only vagrant images'
task :build_vagrant => [:generate] do
  sh "packer build -only vmware-iso korekube.json"
end

desc 'Generate packer JSON'
task :generate => ['korekube.json']

file 'korekube.json' => 'generate.rb' do
  sh "./generate.rb"
  sh "packer validate korekube.json"
end
