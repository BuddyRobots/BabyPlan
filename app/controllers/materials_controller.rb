class MaterialsController < ApplicationController

  def create
    # save the avatar file
    image = Image.new
    image.image = params[:wangEditorH5File]
    filetype = "png"
    image.store_image!
    filepath = image.image.file.file
    logger.info "BBBBBBBBBBBBBBBBBBBBB"
    logger.info filepath.inspect
    logger.info "BBBBBBBBBBBBBBBBBBBBB"
    render text: "/uploads/images/" + filepath.split('/')[-1] and return
  end
end