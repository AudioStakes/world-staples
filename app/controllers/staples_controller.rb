class StaplesController < ApplicationController
  SEARCH_RESULT_PRELOADS = [ :regions, :country_areas, :ingredients, :cooking_methods, :staple_metric ].freeze

  def index
    @query = search_params[:q].to_s.strip
    @filters = search_filters

    load_filter_options

    if @query.blank? && @filters.empty?
      @searched = false
      @results = Staple.order(:name_ja).limit(30)
    else
      @searched = true
      @results = Staples::Search.call(@query, limit: 50, filters: @filters)
      preload_search_result_associations(@results)
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

  def load_filter_options
    @region_options = select_filter_records(Region)
    @ingredient_options = select_filter_records(Ingredient)
    @cooking_method_options = select_filter_records(CookingMethod)
    @price_level_options = StapleMetric.where.not(price_level: [ nil, "" ]).distinct.order(:price_level).pluck(:price_level)
    @satiety_level_options = StapleMetric.where.not(satiety_level: [ nil, "" ]).distinct.order(:satiety_level).pluck(:satiety_level)
    @storage_duration_options = StapleMetric.where.not(storage_duration: [ nil, "" ]).distinct.order(:storage_duration).pluck(:storage_duration)
    @popularity_level_options = StapleMetric.where.not(popularity_level: [ nil, "" ]).distinct.order(:popularity_level).pluck(:popularity_level)
  end

  def select_filter_records(klass)
    ids = klass.where.not(name_en: [ nil, "" ]).order(:name_en).distinct.limit(100).pluck(:id)
    klass.where(id: ids).order(:name_en)
  end

  def search_params
    params.permit(:q, :fermented, :region, :ingredient, :cooking_method, :price_level, :satiety_level, :storage_duration, :popularity_level)
  end

  def search_filters
    {
      fermented: fermented_filter,
      region: search_params[:region].to_s.strip.presence,
      ingredient: search_params[:ingredient].to_s.strip.presence,
      cooking_method: search_params[:cooking_method].to_s.strip.presence,
      price_level: search_params[:price_level].to_s.strip.presence,
      satiety_level: search_params[:satiety_level].to_s.strip.presence,
      storage_duration: search_params[:storage_duration].to_s.strip.presence,
      popularity_level: search_params[:popularity_level].to_s.strip.presence
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

  def preload_search_result_associations(results)
    staples = results.map(&:staple)
    return if staples.empty?

    ActiveRecord::Associations::Preloader.new(records: staples, associations: SEARCH_RESULT_PRELOADS).call
  end
end
