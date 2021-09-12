class LikesController < ApplicationController
    def create
        @post = Post.find(params[:post_id])
        like = current_user.likes.new(post_id: @post.id)
        # like = Like.new(user_id: current_user.id, post_id: @post.id)
        like.save
        #通知の作成
        @post.create_notification_by(current_user)
        # byebug
        # respond_to do |format|
        # format.html {redirect_to request.referrer}
        # format.js
        # end
    end
    
    def destroy
        @post = Post.find(params[:post_id])
        like = current_user.likes.find_by(post_id: @post.id)
        like.destroy
    end
end
