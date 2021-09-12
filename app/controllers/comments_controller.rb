class CommentsController < ApplicationController
    
    def create
        @post = Post.find(params[:post_id])
        @comment = Comment.new(comment_params)         
        @comment.user_id = current_user.id
        @comment.post_id = @post.id
        @comment_item = @comment.post
        if @comment.save
           @comment_item.create_notification_comment!(current_user, @comment.id)
        redirect_to post_path(post)
        end
    end

    def destroy
        Comment.find_by(id: params[:id], post_id: params[:post_id]).destroy
        redirect_to post_path(params[:post_id]), success: '削除に成功しました！'        
    end

    private
    def comment_params
        params.require(:comment).permit(:content, :user_id, :post_id)
    end
end
