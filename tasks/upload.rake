namespace :vox do
  desc 'Upload repo packages'
  task :upload, [:version] do |_, args|
    args.with_defaults(version: '8')
    version = args[:version]
    debs = Dir.glob("openvox#{version}-release/output/**/*.deb")
    rpms = Dir.glob("openvox#{version}-release/output/**/*.rpm")
    debs.each { |f| run_command("aws s3 --endpoint-url=https://s3.osuosl.org cp #{f} s3://openvox-apt/", silent: false) }
    rpms.each { |f| run_command("aws s3 --endpoint-url=https://s3.osuosl.org cp #{f} s3://openvox-yum/", silent: false) }
  end
end