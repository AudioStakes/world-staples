module StaplesHelper
  def tag_label(tag)
    return "" if tag.blank?

    candidates = [
      (tag.respond_to?(:name_ja) ? tag.name_ja : nil),
      (tag.respond_to?(:name_en) ? tag.name_en : nil),
      (tag.respond_to?(:keyword) ? tag.keyword : nil),
      (tag.respond_to?(:code) ? tag.code : nil),
      (tag.respond_to?(:name) ? tag.name : nil)
    ]

    candidates.compact_blank.first.to_s
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
