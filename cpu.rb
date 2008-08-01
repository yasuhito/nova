class CPU
  attr_reader :name
  attr_reader :load_avg


  def initialize attr
    @name = attr[ :name ]
    @load_avg = attr[ :load_avg ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
