class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.post_id = @post.id
    # 10行目は5行で同じことをしているので実質不要
    @comment_item = @comment.post
    if @comment.save
     @comment_item.create_notification_comment!(current_user, @comment.id)
    end
    # 投稿に紐づくコメントをすべて表示する
    @post_comments = @post.comments
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post_comments = @post.comments
    Comment.find_by(id: params[:id], post_id: params[:post_id]).destroy
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :user_id, :post_id)
  end
end
