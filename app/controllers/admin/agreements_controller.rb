class Admin::AgreementsController < Admin::ApplicationController
  def index
    @agreement = Agreement.first
  end

  def update
  	@agreement = Agreement.where(id: params[:id]).first
    retval = @agreement.update_agreement(params[:agreement])
    render json: retval_wrapper(retval)
  end
end