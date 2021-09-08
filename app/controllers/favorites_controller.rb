class FavoritesController < ApplicationController

    # フォローアンフォロー処理 
    def create
        # params[:user_id]これはリンクから送られてきたuser_idをparamsで受け取っている
        # そして受け取った値をモデルのメソッドに受け渡している
        current_user.follow(params[:user_id])
            redirect_to request.referer
    end

    def destroy
        current_user.unfollow(params[:user_id])
        redirect_to request.referer
    end

    # フォローフォロワー一覧処理
    def followings
        
    end

    def followers
    end

end
