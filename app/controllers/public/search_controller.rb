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
    @taxa[:htg] = [["Higher Taxonomy", 0], ["Angiosperms", 1]]
    # Order
    @taxa[:order] = [["Order", 0]]
    # Family
    @taxa[:family] = [["Family", 0]]
    # Genus
    @taxa[:genus] = [["Genus", 0]]
    # we need character groups (traits)
    @trait_groups = [["Trait Group", 0], ["Group 1", 1], ["Group 2", 2]]
    @trait_names = [["Trait Name", 0], ["gametophytic chromosome number (minimum)", 1], ["gametophytic chromosome number (mean)", 2]]
    @trait_values = [["All Values", 0]]
  end
  
  def do_search
  end
  # also some ajaxy methods for updating the number of results before searching

end
