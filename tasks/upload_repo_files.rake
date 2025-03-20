namespace :vox do
  desc 'Upload .repo/.list files'
  task :upload_repo_files do
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

    Dir.glob('yum_repo_files/*.repo').each { |f| run_command("aws s3 --endpoint-url=https://s3.osuosl.org cp #{f} s3://openvox-yum/repo_files/", silent: false) }
    Dir.glob('apt_repo_files/*.list').each { |f| run_command("aws s3 --endpoint-url=https://s3.osuosl.org cp #{f} s3://openvox-apt/list_files/", silent: false) }
  end
end