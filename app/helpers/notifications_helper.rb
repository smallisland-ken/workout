module NotificationsHelper
  def notification_form(notification)
    @visitor = notification.visitor
    @comment = nil
    your_item = link_to 'あなたの投稿', user_path(notification), style: "font-weight: bold;"
    @visitor_comment = notification.comment_id
    # notification.actionがfollowかlikeかcommentか
    case notification.action
    when "follow"
      tag.a(notification.visitor.nickname, href: friend_posts_path(@visitor), style: "font-weight: bold;") + "があなたをフォローしました"
    when "like"
      tag.a(notification.visitor.nickname, href: friend_posts_path(@visitor), style: "font-weight: bold;") + "が" + tag.a('あなたの投稿', href: post_path(notification.post_id), style: "font-weight: bold;") + "にいいねしました"
    when "comment" then
      @comment = Comment.find_by(id: @visitor_comment)&.content
      tag.a(@visitor.nickname, href: friend_posts_path(@visitor), style: "font-weight: bold;") + "が" + tag.a('あなたの投稿', href: post_path(notification.post_id), style: "font-weight: bold;") + "にコメントしました"
    end
  end

  def unread_notifications
    # notificationテーブルでデフォルトでfalseが入っている
    @notifications = current_user.reverse_notifications.where(checked: false)
  end
end
