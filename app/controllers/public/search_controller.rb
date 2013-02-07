class Public::SearchController < ApplicationController
  layout 'bootstrap'

  # This is useless unless the controller is made public
  # http://localhost:3000/projects/1/public/search
  
  def index
    search_form
    render 'search_form'
  end

  def search_form
    # set up vars for the search form
    # we need taxonomy
    @taxa = {}
    # filter these through selections or make it ajaxy
    # Higher taxonomic group
    @taxa[:htg] = []
    # Order
    @taxa[:order] = TaxonName.where(:iczn_group => 'order') || []
    # Family
    @taxa[:family] = TaxonName.where(:iczn_group => 'family') || []
    # Genus
    if params[:selected_family].nil?
      @taxa[:genus] = []
    else
      @taxa[:genus] = TaxonName.where(:iczn_group => 'genus', :parent => params[:selected_family]) || []
    end
    # we need character groups (traits)
    @trait_groups = [["Trait Group", 0], ["Group 1", 1], ["Group 2", 2]]
    @trait_names = [["Trait Name", 0], ["gametophytic chromosome number (minimum)", 1], ["gametophytic chromosome number (mean)", 2]]
    @trait_values = [["All Values", 0]]
  end
  
  def do_search
  end
  # also some ajaxy methods for updating the number of results before searching

end
