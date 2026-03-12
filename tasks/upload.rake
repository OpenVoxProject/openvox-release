namespace :vox do
  desc 'Upload repo packages'
  task :upload do |_, args|
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

    ['7','8'].each do |version|
      debs = Dir.glob("openvox#{version}-release/output/**/*.deb")
      rpms = Dir.glob("openvox#{version}-release/output/**/*.rpm")
      
      debs.each { |f| upload(f, "s3://openvox-apt/#{File.basename(f)}") }
      rpms.each { |f| upload(f, "s3://openvox-yum/#{File.basename(f)}") }
    end
  end
end
