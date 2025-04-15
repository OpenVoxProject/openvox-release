namespace :vox do
  desc 'Create OpenVox release repo packages'
  task :build do
    ['8', '7'].each { |version| FileUtils.rm_rf("#{__dir__}/openvox#{version}-release") }
    run_command("docker run --rm -v #{__dir__}/..:/code almalinux:9 /bin/sh -c 'yum install -y ruby ruby-devel make gcc-c++ git jq rpm-build;cd /code;bundle install;bundle exec rake build'", silent: false, print_command: true)
  end
end