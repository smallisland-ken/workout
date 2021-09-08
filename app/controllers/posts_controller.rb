class PostsController < ApplicationController
    before_action :authenticate_user!
    
    def new
        @post = Post.new
    end

    def show
    end
    
    def index
        @posts = Post.all
    end

    # 筋トレの記録一覧を表示するためのアクション
    def diary
        @diary = current_user.posts.all
    end

    def create
        @post = current_user.posts.new(post_params)
        tags = params[:post][:tag_id].split(',')
        if @post.save
        @post.save_tags(tags)
        redirect_to root_path, notice: '新規投稿に成功しました！'
        else
            flash.now[:alert] = "必要項目を記入してください。"
            render :new
        end
    end
    
    def edit
        @post = Post.find(params[:id])
        @tags = @post.tags.pluck(:name).join(',')
    end
        
    def update
        @post = Post.find(params[:id])
        tags = params[:post][:tag_id].split(',')
        if @post.update_attributes(post_params)
        @post.update_tags(tags)
        redirect_to diary_posts_path, notice: '更新に成功しました！'
        else
            flash.now[:alert] = "必要項目を記入してください。"
            render :edit
        end
    end
    
    def destroy
    end

    private
    def post_params
        params.require(:post).permit(:user, :date_on, :time_at, :place, :content, :image)
    end        

end
