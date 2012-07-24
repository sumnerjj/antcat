# coding: UTF-8
class CatalogController < ApplicationController
  before_filter :setup_parameters_and_find_taxon

  def setup_parameters_and_find_taxon
    @parameters = HashWithIndifferentAccess.new
    @parameters[:id] = params[:id] if params[:id].present?
    @parameters[:child] = params[:child] if params[:child].present?
    @parameters[:q] = params[:q].strip if params[:q].present?
    @parameters[:st] = params[:st] if params[:st].present?
    @parameters[:id] = Family.first.id if @parameters[:id].blank?
    @taxon = Taxon.find @parameters[:id]

    get_view_options
  end

  def get_view_options
    @showing_tribes = session[:show_tribes] if session[:show_tribes].present?
    @showing_subgenera = session[:show_subgenera] if session[:show_subgenera].present?
  end

  def show
    do_search
    setup_taxon_and_index
    render :show
  end

  def search
    if params[:commit] == 'Clear'
      clear_search
    else
      do_search
      if @search_results.present?
        id = @search_results.first[:id]
        @taxon = Taxon.find id
        @parameters[:id] = id
        @parameters.delete :child
      end
    end
    setup_taxon_and_index
    render :show
  end

  def show_tribes
    @showing_tribes = session[:show_tribes] = true
    redirect_to @parameters.merge action: :show
  end

  def hide_tribes
    session[:show_tribes] = false
    do_search
    if @taxon.kind_of? Tribe
      @taxon = @taxon.subfamily
      @parameters[:id] = @taxon.id
      @parameters.delete :child
    end
    redirect_to @parameters.merge action: :show
  end

  def show_subgenera
    session[:show_subgenera] = true
    redirect_to @parameters.merge action: :show
  end

  def hide_subgenera
    @showing_subgenera = session[:show_subgenera] = false
    redirect_to @parameters.merge action: :show
  end

  def clear_search
    @parameters[:q] = @parameters[:st] = nil
  end

  def translate_search_selector_value_to_english value
    {'m' => 'matching', 'bw' => 'beginning with', 'c' => 'containing'}[value]
  end

  def do_search
    return unless @parameters[:q].present?
    @search_results = Taxon.find_name @parameters[:q], translate_search_selector_value_to_english(@parameters[:st])
    if @search_results.blank?
      @search_results_message = 'No results found'
    else
      @search_results = @search_results.map do |search_result|
        {name: search_result.name.html_name, id: search_result.id}
      end
    end
  end

  def setup_taxon_and_index
    @subfamilies = ::Subfamily.ordered_by_name

    case @taxon

    when Family
      if @parameters[:child] == 'none'
        @subfamily = 'none'
        @genera = Genus.without_subfamily.ordered_by_name
      end

    when Subfamily
      @subfamily = @taxon

      if @showing_tribes
        @tribes = @subfamily.tribes.ordered_by_name
        if @parameters[:child] == 'none'
          @tribe = 'none'
          @genera = @subfamily.genera.ordered_by_name
        end
      else
        @genera = @subfamily.genera.ordered_by_name
      end

    when Tribe
      @tribe = @taxon
      @subfamily = @tribe.subfamily

      @showing_tribes = session[:show_tribes] = true
      @tribes = @tribe.siblings.ordered_by_name
      @genera = @tribe.genera.ordered_by_name

    when Genus
      @genus = @taxon
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      unless @showing_subgenera
        @specieses = @genus.species_group_descendants.ordered_by_name
      else
        @subgenera = @genus.subgenera.ordered_by_name.ordered_by_name
      end

    when Subgenus
      @subgenus = @taxon
      @genus = @subgenus.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      @showing_subgenera = session[:show_subgenera] = true
      @subgenera = @genus.subgenera.ordered_by_name
      setup_genus_parent_columns
      @specieses = @subgenus.species_group_descendants.ordered_by_name

    when Species
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants.ordered_by_name

    when Subspecies
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants.ordered_by_name

    end
  end

  def setup_genus_parent_columns
    if @showing_tribes
      @genera = @genus.siblings.ordered_by_name
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @tribes = @subfamily == 'none' ? nil : @subfamily.tribes.ordered_by_name
    else
      @genera = @subfamily == 'none' ? Genus.without_subfamily.ordered_by_name : @subfamily.genera.ordered_by_name
    end
  end

  def create
    tribe = Tribe.find params[:genus][:tribe]
    genus = Genus.new(
      name: params[:genus][:name],
      status: 'valid',
      tribe: tribe)
    genus.save

    json = {
      isNew: true,
      content: render_to_string(partial: 'catalog/taxon_form', locals: {genus: genus, tribe: tribe}),
      success: genus.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

end
