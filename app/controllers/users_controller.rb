class UsersController < ApplicationController
    before_action :authenticate_user!
    
    def friends
        @friends = User.all
    end
    
    def show
    end
    
    def edit
        @user = User.find(params[:id])
        #カレントユーザーでなければ編集画面には飛べない
        unless @user == current_user
            redirect_to root_path
        end
    end

    def update
        @user = User.find(params[:id])
        if @user.update(user_params)
           redirect_to root_path, success: 'アップデートに成功しました！' 
        else
            flash.now[:alert] ="必要項目を記入してください。"
            render :edit
        end
    end
    
    private
    def user_params
        params.require(:user).permit(:nickname, :profile_image, :height, :weight, :gender, :introduction)
    end
end