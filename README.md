# openvox-release

Uses fpm to build openvox-release packages for all the platforms that we support.

See the [doc](./doc) directory for external documentation.

## Local builds

  - bundle install
  - bundle exec rake vox:build

`*.template` files for yum `.repo` and apt `.list` are merged with JSON configuration files from the `source` directory.

This results in an intermediate `build` directory of small trees for fpm to create appropriate `.rpm` and `.deb` files from.

The fpm output files are left in the `output` directory.
