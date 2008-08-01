class Nodes
  # [TODO] SMP
  # [TODO] use ganglia
  def self.list cluster_name
    { 
      # DISABLED imade001
      :imade => %w(imade000 imade002 imade003 imade004 imade005 imade006 imade007 imade008 imade009 imade010 imade011 imade012 imade013 imade014 imade015 imade016 imade017 imade018 imade019 imade020 imade021 imade022 imade023 imade024 imade025 imade026 imade027 imade028 imade029),

      # DISABLED chiba001, chiba007, chiba009, chiba013, chiba121, chiba126, chiba141
      :chiba => %w(chiba000 chiba002 chiba003 chiba004 chiba006 chiba008 chiba010 chiba011 chiba016 chiba017 chiba018 chiba019 chiba020 chiba021 chiba022 chiba023 chiba024 chiba025 chiba026 chiba027 chiba028 chiba029 chiba030 chiba031 chiba055 chiba064 chiba065 chiba066 chiba100 chiba101 chiba102 chiba103 chiba104 chiba105 chiba106 chiba107 chiba108 chiba109 chiba110 chiba111 chiba112 chiba113 chiba114 chiba115 chiba116 chiba117 chiba118 chiba119 chiba120 chiba122 chiba123 chiba124 chiba125 chiba127 chiba128 chiba129 chiba130 chiba131 chiba132 chiba133 chiba134 chiba135 chiba136 chiba137 chiba138 chiba139 chiba140 chiba142 chiba143 chiba144 chiba145 chiba146 chiba147 chiba148 chiba149 chiba150 chiba151 chiba152 chiba153 chiba154 chiba155 chiba156 chiba157),

      :mirai => %w(mirai000 mirai000 mirai000 mirai000 mirai000 mirai000 mirai000 mirai000 mirai001 mirai001 mirai001 mirai001 mirai001 mirai001 mirai001 mirai001 mirai002 mirai002 mirai002 mirai002 mirai002 mirai002 mirai002 mirai002 mirai003 mirai003 mirai003 mirai003 mirai003 mirai003 mirai003 mirai003 mirai004 mirai004 mirai004 mirai004 mirai004 mirai004 mirai004 mirai004 mirai005 mirai005 mirai005 mirai005 mirai005 mirai005 mirai005 mirai005),

      :okubo => %w(okubo000 okubo000 okubo001 okubo001 okubo002 okubo002 okubo003 okubo003 okubo004 okubo004 okubo005 okubo005 okubo006 okubo006 okubo007 okubo007 okubo008 okubo008 okubo009 okubo009 okubo010 okubo010 okubo012 okubo012 okubo013 okubo013),

      # DISABLED: hongo000, hongo033
      :hongo => %w(hongo001 hongo002 hongo003 hongo004 hongo005 hongo006 hongo007 hongo008 hongo009 hongo010 hongo011 hongo012 hongo013 hongo015 hongo017 hongo018 hongo019 hongo020 hongo021 hongo022 hongo023 hongo024 hongo025 hongo026 hongo027 hongo028 hongo029 hongo030 hongo031 hongo032 hongo035 hongo036 hongo037 hongo038 hongo039 hongo040 hongo041 hongo045 hongo046 hongo047 hongo048 hongo050 hongo051 hongo053 hongo057 hongo058 hongo059 hongo062 hongo064 hongo069 hongo100 hongo100 hongo101 hongo101 hongo102 hongo102 hongo103 hongo103 hongo104 hongo104 hongo105 hongo105 hongo106 hongo106 hongo107 hongo107 hongo108 hongo108 hongo109 hongo109 hongo110 hongo110 hongo111 hongo111 hongo112 hongo112 hongo113 hongo113)
    }[ cluster_name ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
