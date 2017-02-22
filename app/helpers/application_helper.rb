module ApplicationHelper
  def course_back_url(back)
    if back == "setting"
      return "/user_mobile/settings/course"
    elsif back == "favorite"
      return "/user_mobile/settings/favorite"
    else
      return "/user_mobile/courses/list"
    end
  end

  def book_back_url(back)
    if back == "setting"
      return "/user_mobile/settings/book"
    elsif back == "favorite"
      return "/user_mobile/settings/favorite"
    else
      return "/user_mobile/books"
    end
  end
end
