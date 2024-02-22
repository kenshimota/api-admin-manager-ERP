class UserController < VerifyAuthenticateController
  def index
    @users = User
      .metadata(params[:metadata]) 
      .search(params[:q])
      .page(params[:page])

    includes = @users.first.metadata_fields if @users.length > 0 and params[:metadata]
    render json: @users, include: includes
  end
end
