module ApplicationHelper
  def meta_description(text)
    content_for(:meta_description, text)
  end

  def page_title(text)
    content_for(:title, text)
  end

  def section_size(size)
    content_for(:section_class, "is-#{size}")
  end
end
