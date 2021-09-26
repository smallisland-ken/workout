class FavoritesController < ApplicationController
  before_action :authenticate_user!

  # フォローアンフォロー処理
  def create
    # params[:user_id]これはリンクから送られてきたuser_idをparamsで受け取っている
    # そして受け取った値をモデルのメソッドに受け渡している
    @user = User.find(params[:user_id])
    current_user.follow(params[:user_id])
    @user.create_notification_follow!(current_user)
    redirect_to request.referer
  end

  def destroy
    current_user.unfollow(params[:user_id])
    redirect_to request.referer
  end

  # フォローフォロワー一覧処理
  def followings
    user = User.find(params[:user_id])
    @users = user.followings
  end

  def followers
    user = User.find(params[:user_id])
    @users = user.followers
  end
end
