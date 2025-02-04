require 'open3'

def run_command(cmd)
  Open3.popen2e(cmd) do |_stdin, stdout_stderr, wait_thr|
    stdout_stderr.each_line { |line| puts line }
    exit_status = wait_thr.value
    unless exit_status.success?
        abort "Command failed with exit status: #{exit_status.exitstatus}"
    end
  end
end

namespace :vox do
  desc 'Create OpenVox release repo packages'
  task :build do
    ['8', '7'].each { |version| FileUtils.rm_rf("#{__dir__}/openvox#{version}-release") }
    run_command("docker run --rm -v #{__dir__}:/code almalinux:9 /bin/sh -c 'yum install -y ruby ruby-devel make gcc-c++ git jq rpm-build;cd /code;bundle install;bundle exec rake build'")
  end

  desc 'Upload repo packages'
  task :upload, [:version] do |_, args|
    args.with_defaults(version: '8')
    version = args[:version]
    debs = Dir.glob("openvox#{version}-release/output/**/*.deb")
    rpms = Dir.glob("openvox#{version}-release/output/**/*.rpm")
    debs.each { |f| run_command("aws s3 --endpoint-url=https://s3.osuosl.org cp #{f} s3://openvox-apt/") }
    rpms.each { |f| run_command("aws s3 --endpoint-url=https://s3.osuosl.org cp #{f} s3://openvox-yum/") }
  end
end

### Puppetlabs stuff ###
# The 'packaging' gem requires these for configuration information.
# See: https://github.com/puppetlabs/build-data
ENV['TEAM'] = 'release'
ENV['PROJECT_ROOT'] = Dir.pwd

require 'packaging'

Pkg::Util::RakeUtils.load_packaging_tasks

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
