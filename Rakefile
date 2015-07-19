
task :default => [:build]

desc 'Build AMI on EC2'
task :build => [:generate] do
end

desc 'Generate packer JSON'
task :generate => ['korekube.json']

file 'korekube.json' => 'generate.rb' do
  sh "./generate.rb"
  sh "packer validate korekube.json"
end
