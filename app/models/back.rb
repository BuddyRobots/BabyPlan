# encoding: utf-8
class Back

  extend CarrierWave::Mount
  mount_uploader :back, BackUploader

end
