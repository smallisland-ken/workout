class UsersController < ApplicationController
    before_action :authenticate_user!
    
    def friends
        @friend = User.all
    end
    
    def show
    end
    
    def edit
        @user = User.find(params[:id])
        unless @user == current_user
            redirect_to root_path
        #カレントユーザーでなければ編集画面には飛べない
        end
    end

    def update
        @user = User.find(params[:id])
        if @user.update(user_params)
            flash[:notice] = "登録に成功しました！"
            redirect_to root_path 
        else
            render edit
        end
    end
    
    private
    def user_params
        params.require(:user).permit(:nickname, :profile_image, :height, :weight, :gender, :introduction)
    end
end