namespace :vox do
  desc 'Upload .repo/.list files'
  task :upload_repo_files do |t, args|
    abort 'No "build" directory found. Run the vox:build task first.' unless File.directory?('build')
    FileUtils.rm_rf('yum_repo_files')
    FileUtils.mkdir_p('yum_repo_files')
    FileUtils.rm_rf('apt_repo_files')
    FileUtils.mkdir_p('apt_repo_files')

    Dir.chdir('build') do
      Dir.glob('**/*.repo').each do |f|
        os, osver, component, _, _, _ = f.split('/')
        FileUtils.cp(f, "../yum_repo_files/#{component}-#{os}#{osver}.repo")
      end

      Dir.glob('**/*.list').each do |f|
        os, component, _, _, _, _ = f.split('/')
        FileUtils.cp(f, "../apt_repo_files/#{component}-#{os}.list")
      end
    end

    @s3 = "aws s3 --endpoint-url=https://s3.osuosl.org"
    def upload(file, s3path)
      unless ENV['OVERWRITE'] == 'true'
        if system("#{@s3} ls #{s3path} > /dev/null 2>&1")
          puts "#{s3path} already exists. Refusing to overwrite. Run the task with OVERWRITE=true to upload it anyway."
          return
        end
      end
      run_command("#{@s3} cp #{file} #{s3path}", print_command: true, silent: false)
    end

    Dir.glob('yum_repo_files/*.repo').each { |f| upload(f, "s3://openvox-yum/repo_files/#{File.basename(f)}") }
    Dir.glob('apt_repo_files/*.list').each { |f| upload(f, "s3://openvox-apt/list_files/#{File.basename(f)}") }
  end
end
