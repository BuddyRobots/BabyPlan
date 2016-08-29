# encoding: utf-8
class Cover

  extend CarrierWave::Mount
  mount_uploader :cover, CoverUploader

end
