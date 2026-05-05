class StaplesController < ApplicationController
  def index
    @query = search_params[:q].to_s.strip
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
    @staple = Staple.includes(
      :ingredients,
      :ingredient_families,
      :forms,
      :shapes,
      :processing_methods,
      :cooking_methods,
      :textures,
      :regions,
      :country_areas,
      :serving_styles,
      :staple_levels,
      :search_keywords,
      :staple_aliases
    ).find(params[:id])
  end

  private

  def search_params
    params.permit(:q, :fermented, :region, :ingredient, :cooking_method)
  end

  def search_filters
    {
      fermented: fermented_filter,
      region: search_params[:region].to_s.strip.presence,
      ingredient: search_params[:ingredient].to_s.strip.presence,
      cooking_method: search_params[:cooking_method].to_s.strip.presence
    }.compact
  end

  def fermented_filter
    case search_params[:fermented].to_s
    when "true"
      true
    when "false"
      false
    end
  end
end
