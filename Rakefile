$:.unshift "#{here = File.dirname(__FILE__)}/lib"
require 'rake/gempackagetask'
require 'rake/rdoctask'

deps = %w{ rspec }

task(:install_gems) {
  deps.each { |g|
    system "jruby -S gem install #{g}"
  }
}

spec = Gem::Specification.new { |s|
  s.platform = Gem::Platform::RUBY

  s.authors = "Matthew King", "Jason Rush", "Jay Donnell", "Dan Yoder"
  s.email = "self@automatthew.com"
  s.files = Dir["{lib,doc,bin,ext}/**/*"].delete_if {|f|
    /\/rdoc(\/|$)/i.match f
  } + %w(Rakefile)
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = Dir['doc/*'].select(&File.method(:file?))
  s.extensions << 'ext/extconf.rb' if File.exist? 'ext/extconf.rb'
  Dir['bin/*'].map(&File.method(:basename)).map(&s.executables.method(:<<))

  s.name = 'moonstone'
  s.summary = "Moonstone Agile Search Framework"
  deps.each &s.method(:add_dependency)
  s.version = '0.6.0'
}

Rake::GemPackageTask.new(spec) { |pkg|
  pkg.need_tar_bz2 = true
}

task(:uninstall) {
  system "sudo jruby -S gem uninstall -aIx #{spec.name}"
}

task(:install => [:uninstall, :package]) {
  g = "pkg/#{spec.name}-#{spec.version}.gem"
  system "sudo jruby -S gem install --local #{g}"
}

task(:uninstall_no_sudo) {
  system "jruby -S gem uninstall -aIx #{spec.name}"
}

task(:install_no_sudo => [:uninstall_no_sudo, :package]) {
  g = "pkg/#{spec.name}-#{spec.version}.gem"
  system "jruby -S gem install -l #{g}"
}

desc "run some tests"
task :test do
  options = ENV['options']
  files = FileList['test/**/*.rb'].exclude('test/helpers.rb')
  puts cmd = "jruby #{options} -I lib -S spec -c #{  files.join(' ') }"
  system cmd 
end
