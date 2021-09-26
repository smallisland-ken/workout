class PostsController < ApplicationController
  before_action :authenticate_user!
  impressionist :actions => [:show]

  # 新規投稿用
  def new
    @post = Post.new
  end

  # 投稿詳細用
  def show
    @post = Post.find(params[:id])
    @comment = Comment.new
    # コメント用のコード
    @post_comments = @post.comments

    # タグ用のコード
    @tags = @post.tags.pluck(:name).join(',')

    # 閲覧数表示
    impressionist(@post, nil, :unique => ["session_hash"])
  end

  # タイムライン
  def index
    # 新着順に5件まで表示
    @posts = Post.page(params[:page]).per(5).reverse_order
    # プロフィール用のfind
    @profile = User.find(current_user.id)
    # いいねランキング
    @like_ranks = Post.find(Like.group(:post_id).order('count(post_id) desc').limit(3).pluck(:post_id))
  end

  # 友達の投稿一覧
  def friend
    @friend = User.find(params[:id])
    # 特定のユーザーの投稿すべてのデータ
    @friend_post = @friend.posts
  end

  # 筋トレの記録一覧を表示するためのアクション
  def diary
    # タグ用のコード
    @diary = current_user.posts.all
  end

  def create
    @post = current_user.posts.new(post_params)
    tags = params[:post][:tag_id].split(',')
    if @post.save
      @post.save_tags(tags)
      redirect_to root_path, success: '新規投稿に成功しました！'
    else
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
      redirect_to diary_posts_path, success: '更新に成功しました！'
    else
      render :edit
    end
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to posts_path, danger: '削除に成功しました！'
  end

  private

  def post_params
    params.require(:post).permit(:user, :date_on, :time_at, :place, :title, :content, :rate, post_images_images: [])
  end
end
