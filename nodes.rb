class Nodes
  def self.list cluster_name
    { 
      :pad => %w(pad039 pad041 pad043 pad044 pad045 pad046 pad047 pad048 pad049 pad051 pad052 pad053 pad054 pad055 pad056 pad057 pad059 pad060 pad061 pad062 pad064 pad065 pad066 pad067 pad068 pad069 pad071 pad073 pad074 pad075 pad076 pad078 pad079 pad080 pad081 pad082 pad083 pad084 pad086 pad087 pad088 pad091 pad093 pad094 pad095 pad098 pad099 pad100 pad106 pad108 pad111 pad113 pad114 pad119 pad124 pad125 pad126 pad129 pad130 pad131 pad039 pad041 pad043 pad044 pad045 pad046 pad047 pad048 pad049 pad051 pad052 pad053 pad054 pad055 pad056 pad057 pad059 pad060 pad061 pad062 pad064 pad065 pad066 pad067 pad068 pad069 pad071 pad073 pad074 pad075 pad076 pad078 pad079 pad080 pad081 pad082 pad083 pad084 pad086 pad087 pad088 pad091 pad093 pad094 pad095 pad098 pad099 pad100 pad106 pad108 pad111 pad113 pad114 pad119 pad124 pad125 pad126 pad129 pad130 pad131 pad039 pad041 pad043 pad044 pad045 pad046 pad047 pad048 pad049 pad051 pad052 pad053 pad054 pad055 pad056 pad057 pad059 pad060 pad061 pad062 pad064 pad065 pad066 pad067 pad068 pad069 pad071 pad073 pad074 pad075 pad076 pad078 pad079 pad080 pad081 pad082 pad083 pad084 pad086 pad087 pad088 pad091 pad093 pad094 pad095 pad098 pad099 pad100 pad106 pad108 pad111 pad113 pad114 pad119 pad124 pad125 pad126 pad129 pad130 pad131 pad039 pad041 pad043 pad044 pad045 pad046 pad047 pad048 pad049 pad051 pad052 pad053 pad054 pad055 pad056 pad057 pad059 pad060 pad061 pad062 pad064 pad065 pad066 pad067 pad068 pad069 pad071 pad073 pad074 pad075 pad076 pad078 pad079 pad080 pad081 pad082 pad083 pad084 pad086 pad087 pad088 pad091 pad093 pad094 pad095 pad098 pad099 pad100 pad106 pad108 pad111 pad113 pad114 pad119 pad124 pad125 pad126 pad129 pad130 pad131),

      :kyushu => %w(kyushu000 kyushu000 kyushu000 kyushu000 kyushu000 kyushu000 kyushu000 kyushu000 kyushu001 kyushu001 kyushu001 kyushu001 kyushu001 kyushu001 kyushu001 kyushu001 kyushu002 kyushu002 kyushu002 kyushu002 kyushu002 kyushu002 kyushu002 kyushu002 kyushu003 kyushu003 kyushu003 kyushu003 kyushu003 kyushu003 kyushu003 kyushu003 kyushu004 kyushu004 kyushu004 kyushu004 kyushu004 kyushu004 kyushu004 kyushu004 kyushu005 kyushu005 kyushu005 kyushu005 kyushu005 kyushu005 kyushu005 kyushu005 kyushu006 kyushu006 kyushu006 kyushu006 kyushu006 kyushu006 kyushu006 kyushu006 kyushu007 kyushu007 kyushu007 kyushu007 kyushu007 kyushu007 kyushu007 kyushu007 kyushu008 kyushu008 kyushu008 kyushu008 kyushu008 kyushu008 kyushu008 kyushu008 kyushu009 kyushu009 kyushu009 kyushu009 kyushu009 kyushu009 kyushu009 kyushu009),

      # DISABLED 003, 004, 006, 007, 008, 009
      :hiro => %w(hiro000 hiro001 hiro002 hiro005 hiro010 hiro000 hiro001 hiro002 hiro005 hiro010 hiro000 hiro001 hiro002 hiro005 hiro010 hiro000 hiro001 hiro002 hiro005 hiro010 hiro000 hiro001 hiro002 hiro005 hiro010 hiro000 hiro001 hiro002 hiro005 hiro010 hiro000 hiro001 hiro002 hiro005 hiro010 hiro000 hiro001 hiro002 hiro005 hiro010),

      :kyoto => %w(kyoto000 kyoto002 kyoto003 kyoto004 kyoto005 kyoto006 kyoto007 kyoto008 kyoto009 kyoto010 kyoto011 kyoto012 kyoto013 kyoto014 kyoto018 kyoto019 kyoto022 kyoto023 kyoto024 kyoto025 kyoto026 kyoto027 kyoto028 kyoto029 kyoto030 kyoto031 kyoto032 kyoto033 kyoto034 kyoto000 kyoto002 kyoto003 kyoto004 kyoto005 kyoto006 kyoto007 kyoto008 kyoto009 kyoto010 kyoto011 kyoto012 kyoto013 kyoto014 kyoto018 kyoto019 kyoto022 kyoto023 kyoto024 kyoto025 kyoto026 kyoto027 kyoto028 kyoto029 kyoto030 kyoto031 kyoto032 kyoto033 kyoto034),

      :kobe => %w(kobe000 kobe000 kobe000 kobe000 kobe000 kobe000 kobe000 kobe000 kobe001 kobe001 kobe001 kobe001 kobe001 kobe001 kobe001 kobe001 kobe002 kobe002 kobe002 kobe002 kobe002 kobe002 kobe002 kobe002 kobe003 kobe003 kobe003 kobe003 kobe003 kobe003 kobe003 kobe003 kobe004 kobe004 kobe004 kobe004 kobe004 kobe004 kobe004 kobe004 kobe005 kobe005 kobe005 kobe005 kobe005 kobe005 kobe005 kobe005 kobe006 kobe006 kobe006 kobe006 kobe006 kobe006 kobe006 kobe006 kobe007 kobe007 kobe007 kobe007 kobe007 kobe007 kobe007 kobe007 kobe008 kobe008 kobe008 kobe008 kobe008 kobe008 kobe008 kobe008 kobe009 kobe009 kobe009 kobe009 kobe009 kobe009 kobe009 kobe009 kobe010 kobe010 kobe010 kobe010 kobe010 kobe010 kobe010 kobe010),

      :suzuk => %w(suzuk000 suzuk001 suzuk002 suzuk003 suzuk004 suzuk005 suzuk006 suzuk007 suzuk008 suzuk009 suzuk010 suzuk011 suzuk012 suzuk013 suzuk014 suzuk015 suzuk016 suzuk017 suzuk018 suzuk019 suzuk020 suzuk021 suzuk022 suzuk023 suzuk024 suzuk025 suzuk026 suzuk027 suzuk028 suzuk029 suzuk030 suzuk031 suzuk032 suzuk033 suzuk034 suzuk035 suzuk000 suzuk001 suzuk002 suzuk003 suzuk004 suzuk005 suzuk006 suzuk007 suzuk008 suzuk009 suzuk010 suzuk011 suzuk012 suzuk013 suzuk014 suzuk015 suzuk016 suzuk017 suzuk018 suzuk019 suzuk020 suzuk021 suzuk022 suzuk023 suzuk024 suzuk025 suzuk026 suzuk027 suzuk028 suzuk029 suzuk030 suzuk031 suzuk032 suzuk033 suzuk034 suzuk035),

      :keio => %w(keio000 keio000 keio000 keio000 keio000 keio000 keio000 keio000 keio001 keio001 keio001 keio001 keio001 keio001 keio001 keio001 keio002 keio002 keio002 keio002 keio002 keio002 keio002 keio002 keio003 keio003 keio003 keio003 keio003 keio003 keio003 keio003 keio004 keio004 keio004 keio004 keio004 keio004 keio004 keio004 keio005 keio005 keio005 keio005 keio005 keio005 keio005 keio005 keio006 keio006 keio006 keio006 keio006 keio006 keio006 keio006 keio007 keio007 keio007 keio007 keio007 keio007 keio007 keio007 keio008 keio008 keio008 keio008 keio008 keio008 keio008 keio008 keio009 keio009 keio009 keio009 keio009 keio009 keio009 keio009 keio010 keio010 keio010 keio010 keio010 keio010 keio010 keio010),

      :imade => [ 'imade000', 'imade001', 'imade002', 'imade003', 'imade004', 'imade005', 'imade006', 'imade007', 'imade008', 'imade009',
                  'imade010', 'imade011', 'imade012', 'imade013', 'imade014', 'imade015', 'imade016', 'imade017', 'imade018', 'imade019',
                  'imade020', 'imade021', 'imade022', 'imade023', 'imade024', 'imade025', 'imade026', 'imade027', 'imade028', 'imade029' ],

      :chiba => [ 'chiba000', 'chiba001', 'chiba002', 'chiba003', 'chiba004', 'chiba005', 'chiba006', 'chiba007', 'chiba008', 'chiba009',
                  'chiba010', 'chiba011', 'chiba012', 'chiba013', 'chiba014', 'chiba015', 'chiba016', 'chiba017', 'chiba018', 'chiba019',
                  'chiba020', 'chiba021', 'chiba022', 'chiba023', 'chiba024', 'chiba025', 'chiba026', 'chiba027', 'chiba028', 'chiba029',
                  'chiba030', 'chiba031', 'chiba032', 'chiba033', 'chiba034', 'chiba035', 'chiba036', 'chiba037', 'chiba038', 'chiba039',
                  'chiba040', 'chiba041', 'chiba042', 'chiba043', 'chiba044', 'chiba045', 'chiba046', 'chiba047', 'chiba048', 'chiba049',
                  'chiba050', 'chiba051', 'chiba052', 'chiba053', 'chiba054', 'chiba055', 'chiba056', 'chiba057', 'chiba058', 'chiba059',
                  'chiba060', 'chiba061', 'chiba062', 'chiba063', 'chiba064', 'chiba065', 'chiba066', 'chiba067', 'chiba068', 'chiba069',
                  'chiba100', 'chiba101', 'chiba102', 'chiba103', 'chiba104', 'chiba105', 'chiba106', 'chiba107', 'chiba108', 'chiba109',
                  'chiba110', 'chiba111', 'chiba112', 'chiba113', 'chiba114', 'chiba115', 'chiba116', 'chiba117', 'chiba118', 'chiba119',
                  'chiba120', 'chiba121', 'chiba122', 'chiba123', 'chiba124', 'chiba125', 'chiba126', 'chiba127', 'chiba128', 'chiba129',
                  'chiba130', 'chiba131', 'chiba132', 'chiba133', 'chiba134', 'chiba135', 'chiba136', 'chiba137', 'chiba138', 'chiba139',
                  'chiba140', 'chiba141', 'chiba142', 'chiba143', 'chiba144', 'chiba145', 'chiba146', 'chiba147', 'chiba148', 'chiba149',
                  'chiba150', 'chiba151', 'chiba152', 'chiba153', 'chiba154', 'chiba155', 'chiba156', 'chiba157' ],

      :mirai => [ 'mirai000', 'mirai001', 'mirai002', 'mirai003', 'mirai004', 'mirai005' ],

      :okubo => [ 'okubo000', 'okubo001', 'okubo002', 'okubo003', 'okubo004', 'okubo005', 'okubo006', 'okubo007', 'okubo008', 'okubo009',
                  'okubo010', 'okubo011', 'okubo012', 'okubo013' ],

      :hongo => [ 'hongo000', 'hongo001', 'hongo002', 'hongo003', 'hongo004', 'hongo005', 'hongo006', 'hongo007', 'hongo008', 'hongo009',
                  'hongo010', 'hongo011', 'hongo012', 'hongo013', 'hongo014', 'hongo015', 'hongo016', 'hongo017', 'hongo018', 'hongo019',
                  'hongo020', 'hongo021', 'hongo022', 'hongo023', 'hongo024', 'hongo025', 'hongo026', 'hongo027', 'hongo028', 'hongo029',
                  'hongo030', 'hongo031', 'hongo032', 'hongo033', 'hongo034', 'hongo035', 'hongo036', 'hongo037', 'hongo038', 'hongo039',
                  'hongo040', 'hongo041', 'hongo042', 'hongo043', 'hongo044', 'hongo045', 'hongo046', 'hongo047', 'hongo048', 'hongo049',
                  'hongo050', 'hongo051', 'hongo052', 'hongo053', 'hongo054', 'hongo055', 'hongo056', 'hongo057', 'hongo058', 'hongo059',
                  'hongo060', 'hongo061', 'hongo062', 'hongo063', 'hongo064', 'hongo065', 'hongo066', 'hongo067', 'hongo068', 'hongo069',
                  'hongo100', 'hongo101', 'hongo102', 'hongo103', 'hongo104', 'hongo105', 'hongo106', 'hongo107', 'hongo108', 'hongo109',
                  'hongo110', 'hongo111', 'hongo112', 'hongo113' ]
    }[ cluster_name ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
