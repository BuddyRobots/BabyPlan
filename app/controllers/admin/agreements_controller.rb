class Admin::AgreementsController < Admin::ApplicationController
  def index
    @agreement = Agreement.first
  end

  def create
  	@agreement = Agreement.first || Agreement.create
    @agreement.title = params[:title]
    @agreement.content = params[:content]
    @agreement.save
    render json: retval_wrapper(nil)
  end
end