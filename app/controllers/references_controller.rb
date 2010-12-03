class ReferencesController < ApplicationController

  before_filter :authenticate_user!, :except => :index

  def index
    params[:q] = '' if params[:commit] == 'clear'
    params[:q].strip! if params[:q]
    @references = Reference.do_search(params[:q], params[:page], params[:commit] == 'review')
  end

  def create
    @reference = new_reference
    save true
  end

  def update
    @reference = get_reference
    save false
  end
  
  def save new
    begin
      Reference.transaction do
        set_authors
        set_journal if @reference.kind_of? ArticleReference
        set_publisher if @reference.kind_of? BookReference
        set_pagination
        save_uploaded_file
        @reference.attributes = params[:reference]
        @reference.save!
        raise ActiveRecord::RecordInvalid unless @reference.errors.empty?
      end
    rescue ActiveRecord::RecordInvalid
      @reference[:id] = nil if new
      @reference.instance_variable_set( :@new_record , new)
    end
    render_json new
  end

  def destroy
    @reference = Reference.find(params[:id])
    if @reference.destroy
      json = {:success => true}
    else
      json = {:success => false, :message => @reference.errors[:base]}.to_json
    end 
    render :json => json
  end

  private
  def set_pagination
    params[:reference][:pagination] =
      case @reference
      when ArticleReference: params[:article_pagination]
      when BookReference: params[:book_pagination]
      else nil
      end
  end

  def set_authors
    @reference.author_names.clear
    authors_data = AuthorName.import_author_names_string params[:reference][:author_names_string]
    params[:reference][:author_names] = authors_data[:author_names]
    params[:reference][:author_names_suffix] = authors_data[:author_names_suffix]
  end

  def set_journal
    params[:reference][:journal] = Journal.import params[:journal_name]
  end

  def set_publisher
    params[:reference][:publisher] = Publisher.import_string params[:publisher_string]
  end

  def render_json new = false
    ActiveSupport.escape_html_entities_in_json = true
    json = {
      :isNew => new,
      :content => render_to_string(:partial => 'reference',
                                   :locals => {:reference => @reference, :css_class => 'reference'}),
                                   :id => @reference.id,
                                   :success => @reference.errors.empty?
    }.to_json
    
    json = '<textarea>' + json + '</textarea>' unless Rails.env.cucumber? 
    render :json => json, :content_type => 'text/html'
  end

  def new_reference
    case params[:selected_tab]
    when 'Article': ArticleReference.new
    when 'Book':    BookReference.new
    when 'Nested':  NestedReference.new
    else            UnknownReference.new
    end
  end

  def get_reference
    selected_tab = params[:selected_tab]
    selected_tab = 'Unknown' if selected_tab == 'Other'
    Reference.find(params[:id]).becomes((selected_tab + 'Reference').constantize)
  end

  def save_uploaded_file
    upload = params['source_file']
    return unless upload

    directory = Rails.root + "public/sources"
    name =  UniqueFilename.get directory, CGI.escape(upload.original_filename)
    path = File.join directory, name
    File.open(path, "wb") { |f| f.write(upload.read) }
    params[:reference][:source_url] = "#{request.host}/sources/#{name}"
  end
end
