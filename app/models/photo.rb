# encoding: utf-8
class Photo

  extend CarrierWave::Mount
  mount_uploader :photo, PhotoUploader

end
