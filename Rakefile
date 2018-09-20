require 'bundler/setup'

### Local custom requires
require 'cts/mpx/version'

### Configurables
version = Cts::Mpx::VERSION
name = "cts-mpx"
geminabox_server = "http://ctsgems.corp.theplatform.com"

### Basic Tasks
task default: :rspec
desc "run the rspec suite"

task "rspec" do
  sh 'rspec'
end

desc "bundle"
task :bundle do
  sh "bundle"
end

namespace :gem do
  desc "build #{name}-#{version} of the gem in pkg/"
  task build: [:bundle] do
    sh "gem build #{name}.gemspec"
    mkdir_p "pkg"
    mv "#{name}-#{version}.gem", "pkg"
  end

  desc "install pkg/#{name}-#{version}.gem into the system"
  task install: [:build] do
    sh "gem install pkg/#{name}-#{version}.gem"
  end

  desc "Run rubocop"
  task rubocop: [] do
    sh "rubocop -fs"
  end

  namespace :release do
    desc "tag current version as #{version}"
    task :tag do
      begin
        sh "git tag v#{version}"
      rescue StandardError
        exit 0
      end
    end

    desc "push gem #{name}-#{version} to #{geminabox_server}"
    task gem: ['gem:build'] do
      sh "gem inabox -g #{geminabox_server}"
    end
  end

  desc "tag #{name}-#{version} and release push #{name}-#{version}"
  task release: ['release:gem', 'release:tag']
end
