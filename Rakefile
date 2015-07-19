
task :default => [:build]

desc 'Build AMI on EC2'
task :build => [:validate] do
end

desc 'Validate packer JSON'
task :validate => [:generate] do
  sh "packer validate korekube.json"
end

desc 'Generate packer JSON'
task :generate => ['korekube.json']

file 'korekube.json' => 'generate.rb' do
  sh "./generate.rb"
end
