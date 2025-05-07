require 'open3'

RED = "\033[31m".freeze
GREEN = "\033[32m".freeze
RESET = "\033[0m".freeze

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

desc 'Create packages from release-file definitions'
task :build do
  projects = Dir.glob('source/projects/*.json').map do |json_file_name|
    File.basename(json_file_name, '.json')
  end.join(' ')

  sh "./ci/create-packages #{projects}"
end
