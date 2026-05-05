require "uri"

module StaplesHelper
  def tag_label(tag)
    return "" if tag.blank?

    values = [
      (tag.respond_to?(:name_ja) ? tag.name_ja : nil),
      (tag.respond_to?(:name_en) ? tag.name_en : nil),
      (tag.respond_to?(:keyword) ? tag.keyword : nil),
      (tag.respond_to?(:code) ? tag.code : nil),
      (tag.respond_to?(:name) ? tag.name : nil)
    ].compact_blank.uniq

    values.join(" / ")
  end


  def filter_option_label(item)
    tag_label(item).presence || item.name_en.to_s
  end

  def display_tag_label(item)
    tag_label(item).presence || item.name_en.to_s.presence || item.to_s
  end

  def tag_search_path(item)
    case item
    when Region
      staples_path(region: item.name_en)
    when Ingredient
      staples_path(ingredient: item.name_en)
    when CookingMethod
      staples_path(cooking_method: item.name_en)
    end
  end

  def fermented_label(staple)
    staple.fermented ? "Fermented" : "Not fermented"
  end

  def safe_source_url(staple)
    url = staple.source_url.to_s
    return if url.blank?

    uri = URI.parse(url)
    return unless uri.is_a?(URI::HTTP)

    url
  rescue URI::InvalidURIError
    nil
  end
end
