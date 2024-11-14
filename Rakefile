# The 'packaging' gem requires these for configuration information.
# See: https://github.com/puppetlabs/build-data
ENV['TEAM'] = 'release'
ENV['PROJECT_ROOT'] = Dir.pwd

require 'packaging'

Pkg::Util::RakeUtils.load_packaging_tasks

namespace :overlookinfra do
  desc 'Create community release repo packages'
  task :build do
    `docker run --rm -v #{__dir__}:/code almalinux:9 /bin/sh -c 'yum install -y ruby ruby-devel make gcc-c++ git jq rpm-build;cd /code;bundle install;bundle exec rake build'`
  end

  desc 'Upload repo packages'
  task :upload do
    debs = Dir.glob('puppet8-community-release/output/**/*.deb')
    rpms = Dir.glob('puppet8-community-release/output/**/*.rpm')
    debs.each { |f| `aws s3 --endpoint-url=https://s3.osuosl.org cp #{f} s3://puppet-apt/` }
    rpms.each { |f| `aws s3 --endpoint-url=https://s3.osuosl.org cp #{f} s3://puppet-yum/` }
  end
end

desc 'Create packages from release-file definitions'
task :build do
  projects = Dir.glob('source/projects/*.json').map do |json_file_name|
    File.basename(json_file_name, '.json')
  end.join(' ')

  sh "./ci/create-packages #{projects}"
end

desc 'Sign packages'
task :sign do
  Dir.glob('source/projects/*.json').each do |json_file_name|
    project_name = File.basename(json_file_name, '.json')
    Dir.chdir(project_name) do
      Pkg::Util::RakeUtils.invoke_task('pl:jenkins:sign_all', 'output')
    end
  end
end

desc 'Upload packages to builds and Artifactory'
task :ship do
  Dir.glob('source/projects/*.json').each do |json_file_name|
    project_name = File.basename(json_file_name, '.json')
    ENV['PROJECT_OVERRIDE'] = project_name
    Dir.chdir(project_name) do
      Pkg::Util::RakeUtils.invoke_task('pl:jenkins:ship', 'artifacts', 'output')
      Pkg::Util::RakeUtils.invoke_task('pl:jenkins:ship_to_artifactory', 'output')
    end
  end
end

desc 'Clean up build and output directories'
task :clean do
  rm_rf 'build'
  Dir.glob('source/projects/*.json').each do |json_file_name|
    project_name = File.basename(json_file_name, '.json')
    rm_rf project_name
  end
end
