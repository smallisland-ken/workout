module NotificationsHelper
  def notification_form(notification)
    @visitor = notification.visitor
    @comment = nil
    your_item = link_to 'あなたの投稿', user_path(notification), style: "font-weight: bold;"
    @visitor_comment = notification.comment_id
    # notification.actionがfollowかlikeかcommentか
    case notification.action
    when "follow"
      #link_toと同じ
      tag.a(notification.visitor.nickname, href: friend_posts_path(@visitor), style: "font-weight: bold;") + t('notifications.index.followed_you')
    when "like"
      tag.a(notification.visitor.nickname, href: friend_posts_path(@visitor), style: "font-weight: bold;") + t('notifications.index.ga') + tag.a(t('notifications.index.your_comment'), href: post_path(notification.post_id), style: "font-weight: bold;") + t('notifications.index.ni_iine')
    when "comment" then
      #投稿に基づくコメントを取り出してる.content
      @comment = Comment.find_by(id: @visitor_comment)&.content
      tag.a(@visitor.nickname, href: friend_posts_path(@visitor), style: "font-weight: bold;") +  t('notifications.index.ga2') + tag.a(t('notifications.index.your_comment2'), href: post_path(notification.post_id), style: "font-weight: bold;") + t('notifications.index.ni_iine2')
    end
  end
  
  def unread_notifications
    # notificationテーブルでデフォルトでfalseが入っている
    @notifications = current_user.reverse_notifications.where(checked: false)
  end
end
