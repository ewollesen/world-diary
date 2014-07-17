# -*- coding: utf-8 -*-
module ApplicationHelper

  def title
    if content_for?(:title)
      content_for(:title) + " : World Diary"
    else
      "World Diary"
    end
  end

  def active_link_class(path)
    current_page?(path) ? "active" : ""
  end

  def bootstrap_flash
    return unless flash.present?

    flash_map = {
      notice: :success,
      success: :success,
      info: :info,
      warning: :warning,
      error: :danger,
      alert: :warning,
    }
    classes = "col-sm-offset-3 col-sm-6 alert alert-dismissable"
    close = content_tag("button", class: "close",
                                  data: {dismiss: "alert"},
                                  type: "button") do
      content_tag("span", "×", "aria-hidden" => "true") +
        content_tag("span", "Close", class: "sr-only")
    end

    divs = flash.map do |(key, value)|
      content_tag("div",
                  close + value,
                  class: classes + " alert-#{flash_map[key.to_sym]}")
    end

    divs.reduce("") do |html, div|
      html += content_tag("div", div, class: "row")
    end.html_safe
  end

  def attachment_icon(subject)
    if subject.attachments.present? &&
       subject.attachments.any? {|a| !a.dm_only? || a.authorized_user?(current_user || User.new)}
      fa_icon("paperclip")
    end
  end

  def context_icon(subject)
    user = current_user || User.new

    if user.dm?
      context_icon_dm(subject)
    else
      context_icon_user(subject, user)
    end
  end

  def locked_icon
    fa_icon("lock", class: "text-muted")
  end

  def unlocked_icon
    content_tag("abbr", title: "You have a veil pass for this subject.") do
      fa_icon("unlock")
    end
  end

  def render_wiki(text)
    renderer = Redcarpet::Render::XHTML.new(with_toc_data: true)
    x = WorldWiki::WikiParser.new.parse(text).render
    y = DmStripper.strip(x, current_user, @subject.authorized_users.include?(current_user))
    render_wiki_toc(text)
    Redcarpet::Markdown.new(renderer).render(y).html_safe
  end

  def render_wiki_toc(text)
    renderer = Redcarpet::Render::HTML_TOC.new
    toc = Redcarpet::Markdown.new(renderer).render(text)
    if toc.present?
      content_for(:sidebar) do
        content_tag("li") do
          content_tag("h4", "Table of Contents") +
            toc.html_safe
        end
      end

        # content_tag("div", class: "panel panel-default") do
        #   content_tag("div", class: "panel-heading") do
        #     content_tag("h4") do
        #       #fa_icon("list-ul") + " " +
        #       "Table of Contents".html_safe
        #     end
        #   end + content_tag("div", toc.html_safe, class: "panel-body")
        # end
      # end
    end
  end

  def attachment_metadata(attachment)
    bits = []

    content_tag("small", :class => "text-muted") do
      if attachment.file_size
        bits << number_to_human_size(attachment.file_size)
      end

      if attachment.content_type
        bits << attachment.content_type
      end

      if attachment.width && attachment.height
        bits << "#{attachment.width}&times;#{attachment.height}"
      end

      bits.join(", ").html_safe
    end
  end

  def attachment_image_overlay(attachment, &block)
    if attachment.dm_only
      attachment_image_overlay_inner(attachment, &block)
    else
      capture {yield}
    end
  end

  def veil_pass_user_ids
    User.pcs.order(:first_name, :last_name).map {|u| [u.name, u.id]}
  end


  private

  def attachment_image_overlay_inner(attachment, &block)
    content_tag(:div, class: "attachment-overlay-dm-only") do
      content_tag(:div, context_icon(attachment), class: "overlay-icons") +
        capture {yield}
    end
  end

  def context_icon_dm(subject)
    html = []
    noun = subject.is_a?(Attachment) ? "attachment" : "subject"

    if subject.dm_only?
      html << fa_icon("lock")
    end
    if subject.authorized_users.present?
      html << content_tag("abbr", title: "Veil passes exist for this #{noun}.", rel: "tooltip") do
        fa_icon("key")
      end
    end

    html.join(" ").html_safe
  end

  def context_icon_user(subject, user)
    noun = subject.is_a?(Attachment) ? "attachment" : "subject"

    if subject.authorized_user?(user)
      content_tag("abbr", rel: "tooltip", title: "You have a veil pass for this #{noun}.") do
        fa_icon("key")
      end
    end
  end

end
