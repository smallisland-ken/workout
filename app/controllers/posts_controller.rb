class PostsController < ApplicationController
    before_action :authenticate_user!
    
    def index
        @posts = Post.all
    end

    # 筋トレの記録一覧を表示するためのアクション
    def diary
    end

    def new
        @post = Post.new
    end
    
    def create
        @post = Post.new(post_params)
        if @post.save
        redirect_to roots_path, notice: '新規投稿に成功しました！'
        else
        flash.now[:alert] = "必要項目を記入してください。"
        render :new
        end
    end
    
    def edit
    end
    
    def update
    end
    
    def destroy
    end

    private
    def post_params
        params.require(:post).permit(
        :user, :date_on, :time_at, :place, :content, :image
        )
    end        

end
