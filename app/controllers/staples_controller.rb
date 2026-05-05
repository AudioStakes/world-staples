class StaplesController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @filters = search_filters

    if @query.blank?
      @searched = false
      @results = Staple.includes(:regions, :country_areas, :ingredients, :cooking_methods).order(:name_ja).limit(30)
    else
      @searched = true
      @results = Staples::Search.call(@query, limit: 50, filters: @filters)
    end
  end

  def show
    @staple = Staple.find(params[:id])
  end

  private

  def search_filters
    {
      fermented: fermented_filter,
      region: params[:region].to_s.strip.presence,
      ingredient: params[:ingredient].to_s.strip.presence,
      cooking_method: params[:cooking_method].to_s.strip.presence
    }.compact
  end

  def fermented_filter
    case params[:fermented].to_s
    when "true"
      true
    when "false"
      false
    else
      nil
    end
  end
end
