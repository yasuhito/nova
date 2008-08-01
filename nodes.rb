class Nodes
  # [TODO] SMP
  # [TODO] use ganglia
  def self.list cluster_name
    { 
      :okubo => %w(okubo000 okubo001 okubo002 okubo003 okubo004 okubo005 okubo006 okubo007 okubo008 okubo009 okubo010 okubo012 okubo013),

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
