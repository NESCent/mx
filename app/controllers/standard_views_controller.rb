class StandardViewsController < ApplicationController
  
  def index
    list
    render :action => 'list'
  end

  def list
    @standard_views = StandardView.by_proj(@proj).page(params[:page]).per(100).order('standard_views.name')
  end

  def show
    id = params[:standard_view][:id] if params[:standard_view]
    id ||= params[:id]
    @standard_view = StandardView.find(id)
  end

  def new
    @standard_view = StandardView.new
  end

  def create
    if !params[:standard_view][:ontology_class_dbref].blank?
      oc = OntologyClass.find(params[:standard_view][:ontology_class_xref])
      if oc.xref.blank?
        errors.add(:ontology_class_xref, 'You must select an ontology class with a xref ID')
        @standard_view = StandardView.new(params[:standard_view])
        render :action => :new and return
      end
      params[:standard_view][:ontology_class_xref] = oc.xref
    end

    @standard_view = StandardView.new(params[:standard_view])
    if @standard_view.save
      flash[:notice] = 'StandardView was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @standard_view = StandardView.find(params[:id])
  end

  def update

   @standard_view = StandardView.find(params[:id])
   @standard_view.ontology_class_xref = params[:xref_bioportal_concept_id] # TODO: Kludge, resolve in model when forms are updated

    if @standard_view.update_attributes(params[:standard_view])
      flash[:notice] = 'StandardView was successfully updated.'
      redirect_to :action => 'show', :id => @standard_view
    else
      render :action => 'edit'
    end
  end

  def destroy
    StandardView.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def auto_complete_for_standard_views
    value = params[:term]
    @standard_views = StandardView.find_for_auto_complete(params.merge(:proj_id => @proj.id)) # TODO: refactor
    render :json => Json::format_for_autocomplete_with_display_name(:entries => @standard_views, :method => params[:method])
  end


  
end
