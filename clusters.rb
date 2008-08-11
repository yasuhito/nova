class Clusters
  def self.all
    [ :kyushu, :hiro, :kyoto, :kobe, :suzuk, :imade, :chiba, :mirai, :hongo, :okubo ] # :keio, :pad
  end


  def self.list name
    { 
      :pad => { 
        :cpu_num => 2, # [FIXME]
        :domain => 'titech.hpcc.jp',
        :list => [ 'pad039',
                   'pad040', 'pad041', 'pad042', 'pad043', 'pad044', 'pad045', 'pad046', 'pad047', 'pad048', 'pad049',
                   'pad050', 'pad051', 'pad052', 'pad053', 'pad054', 'pad055', 'pad056', 'pad057', 'pad058', 'pad059',
                   'pad060', 'pad061', 'pad062', 'pad063', 'pad064', 'pad065', 'pad066', 'pad067', 'pad068', 'pad069',
                   'pad070', 'pad071', 'pad072', 'pad073', 'pad074', 'pad075', 'pad076', 'pad077', 'pad078', 'pad079',
                   'pad080', 'pad081', 'pad082', 'pad083', 'pad084', 'pad085', 'pad086', 'pad087', 'pad088', 'pad089',
                   'pad090', 'pad091', 'pad092', 'pad093', 'pad094', 'pad095', 'pad096', 'pad097', 'pad098', 'pad099',
                   'pad100', 'pad101', 'pad102', 'pad103', 'pad104', 'pad105', 'pad106', 'pad107', 'pad108', 'pad109',
                   'pad110', 'pad111', 'pad112', 'pad113', 'pad114', 'pad115', 'pad116', 'pad117', 'pad118', 'pad119',
                   'pad120', 'pad121', 'pad122', 'pad123', 'pad124', 'pad125', 'pad126', 'pad127', 'pad128', 'pad129',
                   'pad130', 'pad131' ]
      },

      :kyushu => { 
        :cpu_num => 8,
        :domain => 'bioinfo.kyushu-u.ac.jp',
        :list => [ 'kyushu000', 'kyushu001', 'kyushu002', 'kyushu003', 'kyushu004', 'kyushu005', 'kyushu006', 'kyushu007', 'kyushu008', 'kyushu009' ]
      },

      :hiro => {
        :cpu_num => 8,
        :domain => 'net.hiroshima-u.ac.jp',
        :list => [ 'hiro000', 'hiro001', 'hiro002', 'hiro003', 'hiro004', 'hiro005', 'hiro006', 'hiro007', 'hiro008', 'hiro009',
                   'hiro010' ]
      },

      :kyoto => { 
        :cpu_num => 2,
        :domain => 'para.media.kyoto-u.ac.jp',
        :list => [ 'kyoto000', 'kyoto001', 'kyoto002', 'kyoto003', 'kyoto004', 'kyoto005', 'kyoto006', 'kyoto007', 'kyoto008', 'kyoto009',
                   'kyoto010', 'kyoto011', 'kyoto012', 'kyoto013', 'kyoto014', 'kyoto015', 'kyoto016', 'kyoto017', 'kyoto018', 'kyoto019',
                   'kyoto020', 'kyoto021', 'kyoto022', 'kyoto023', 'kyoto024', 'kyoto025', 'kyoto026', 'kyoto027', 'kyoto028', 'kyoto029',
                   'kyoto030', 'kyoto031', 'kyoto032', 'kyoto033', 'kyoto034' ]
      },

      :kobe => { 
        :cpu_num => 8,
        :domain => 'intrigger.scitec.kobe-u.ac.jp',
        :list => [ 'kobe000', 'kobe001', 'kobe002', 'kobe003', 'kobe004', 'kobe005', 'kobe006', 'kobe007', 'kobe008', 'kobe009',
                   'kobe010' ]
      },

      :suzuk => { 
        :cpu_num => 2,
        :domain => 'intrigger.titech.ac.jp',
        :list => [ 'suzuk000', 'suzuk001', 'suzuk002', 'suzuk003', 'suzuk004', 'suzuk005', 'suzuk006', 'suzuk007', 'suzuk008', 'suzuk009',
                   'suzuk010', 'suzuk011', 'suzuk012', 'suzuk013', 'suzuk014', 'suzuk015', 'suzuk016', 'suzuk017', 'suzuk018', 'suzuk019',
                   'suzuk020', 'suzuk021', 'suzuk022', 'suzuk023', 'suzuk024', 'suzuk025', 'suzuk026', 'suzuk027', 'suzuk028', 'suzuk029',
                   'suzuk030', 'suzuk031', 'suzuk032', 'suzuk033', 'suzuk034', 'suzuk035' ]
      },

      :keio => {
        :cpu_num => 2, # [FIXME]
        :domain => 'sslab.ics.keio.ac.jp',
        :list => [ 'keio000', 'keio001', 'keio002', 'keio003', 'keio004', 'keio005', 'keio006', 'keio007', 'keio008', 'keio009',
                   'keio010' ]
      },

      :imade => {
        :cpu_num => 2,
        :domain => 'kuis.kyoto-u.ac.jp', 
        :list => [ 'imade000', 'imade001', 'imade002', 'imade003', 'imade004', 'imade005', 'imade006', 'imade007', 'imade008', 'imade009',
                   'imade010', 'imade011', 'imade012', 'imade013', 'imade014', 'imade015', 'imade016', 'imade017', 'imade018', 'imade019',
                   'imade020', 'imade021', 'imade022', 'imade023', 'imade024', 'imade025', 'imade026', 'imade027', 'imade028', 'imade029' ]
      },

      :chiba => { 
        :cpu_num => 2,
        :domain => 'intrigger.nii.ac.jp',
        :list => [ 'chiba100', 'chiba101', 'chiba102', 'chiba103', 'chiba104', 'chiba105', 'chiba106', 'chiba107', 'chiba108', 'chiba109',
                   'chiba110', 'chiba111', 'chiba112', 'chiba113', 'chiba114', 'chiba115', 'chiba116', 'chiba117', 'chiba118', 'chiba119',
                   'chiba120', 'chiba121', 'chiba122', 'chiba123', 'chiba124', 'chiba125', 'chiba126', 'chiba127', 'chiba128', 'chiba129',
                   'chiba130', 'chiba131', 'chiba132', 'chiba133', 'chiba134', 'chiba135', 'chiba136', 'chiba137', 'chiba138', 'chiba139',
                   'chiba140', 'chiba141', 'chiba142', 'chiba143', 'chiba144', 'chiba145', 'chiba146', 'chiba147', 'chiba148', 'chiba149',
                   'chiba150', 'chiba151', 'chiba152', 'chiba153', 'chiba154', 'chiba155', 'chiba156', 'chiba157' ]
      },

      :mirai => {
        :cpu_num => 8,
        :domain => 'intrigger.jp',
        :list => [ 'mirai000', 'mirai001', 'mirai002', 'mirai003', 'mirai004', 'mirai005' ]
      },

      :okubo => {
        :cpu_num => 2,
        :domain => 'yama.info.waseda.ac.jp',
        :list => [ 'okubo000', 'okubo001', 'okubo002', 'okubo003', 'okubo004', 'okubo005', 'okubo006', 'okubo007', 'okubo008', 'okubo009',
                   'okubo010', 'okubo011', 'okubo012', 'okubo013' ]
      },

      :hongo => { 
        :cpu_num => 2,
        :domain => 'logos.ic.i.u-tokyo.ac.jp',
        :list => [ 'hongo100', 'hongo101', 'hongo102', 'hongo103', 'hongo104', 'hongo105', 'hongo106', 'hongo107', 'hongo108', 'hongo109',
                   'hongo110', 'hongo111', 'hongo112', 'hongo113' ]
      }
    }[ name ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
