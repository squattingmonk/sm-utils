require 'rake/clean'

task :default => :erf

desc 'Build importable ERF'
task :erf do
  system('nwn-erf -c -f sm_utils.erf src/*.nss')
end

desc 'Generate tagfile'
task :tags do
  system('ctags -f src/tags -h .ncs --language-force=c src/*.nss')
end

CLOBBER.include('src/tags', '*.erf')
