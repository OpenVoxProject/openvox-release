require 'open3'

RED = "\033[31m"
GREEN = "\033[32m"
RESET = "\033[0m"

def run_command(cmd, silent: true, print_command: false, report_status: false)
  puts "#{GREEN}Running #{cmd}#{RESET}" if print_command
  output = ''
  Open3.popen2e(cmd) do |_stdin, stdout_stderr, thread|
    stdout_stderr.each do |line|
      puts line unless silent
      output += line
    end
    exitcode = thread.value.exitstatus
    unless exitcode.zero?
      err = "#{RED}Command failed! Command: #{cmd}, Exit code: #{exitcode}"
      # Print details if we were running silent
      err += "\nOutput:\n#{output}" if silent
      err += RESET
      abort err
    end
    puts "#{GREEN}Command finished with status #{exitcode}#{RESET}" if report_status
  end
  output.chomp
end

Dir.glob(File.join('tasks/**/*.rake')).each { |file| load file }

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
