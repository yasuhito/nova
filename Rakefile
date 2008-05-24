require 'rake/clean'


FileList[ '*.cpp' ].each do | each |
  executable = each.sub( /\.cpp$/, '' )

  CLEAN << executable

  rule executable => [ proc do | task_name | each end ] do | t |
    sh "g++ #{ t.source } -o #{ t.name }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
