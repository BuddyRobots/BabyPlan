# encoding: utf-8
class Image

  extend CarrierWave::Mount
  mount_uploader :image, ImageUploader

end
