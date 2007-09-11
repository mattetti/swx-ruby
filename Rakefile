require 'rake'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'


desc 'Run all examples with RCov'
Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

desc 'Verify that spec coverage is 100%'
RCov::VerifyTask.new(:rcov => :examples_with_rcov) do |t|
  t.threshold = 100.0
  t.index_html = './coverage/index.html'
end