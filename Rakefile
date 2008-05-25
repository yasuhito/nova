require 'rake/clean'


FileList[ '*.cpp' ].each do | each |
  executable = each.sub( /\.cpp$/, '' )

  CLEAN << executable

  file executable => [ each ] do | t |
    sh "g++ -Wall -Wextra #{ each } -o #{ executable } -ltbb"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
