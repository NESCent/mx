class Public::SearchController < ApplicationController
  layout 'bootstrap'

  # This is useless unless the controller is made public
  # in the project settings
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
    @taxa[:order] = order_taxa
    # Family
    @taxa[:family] = family_taxa_in_order(params[:order_id])
    # Genus
    @taxa[:genus] = genus_taxa_in_family(params[:family_id])
    # we need character groups (traits)
    @trait_groups = [["Trait Group", 0], ["Group 1", 1], ["Group 2", 2]]
    @trait_names = [["Trait Name", 0], ["gametophytic chromosome number (minimum)", 1], ["gametophytic chromosome number (mean)", 2]]
    @trait_values = [["All Values", 0]]
  end
  
  def list_order
    @order_list = order_taxa
    render :json => @order_list
  end
  
  def list_family
    @family_list = family_taxa_in_order(params[:order_id])
    render :json => @family_list
  end
  
  def list_genus
    @genus_list = genus_taxa_in_family(params[:family_id])
    render :json => @genus_list
  end
  
  def do_search
  end

  private
  
  def order_taxa
    return TaxonName.where(:iczn_group => 'order').order(:name)
  end
  
  def family_taxa_in_order(order_id)
    if order_id
      return TaxonName.where(:iczn_group => 'family', :parent_id => order_id).order(:name)
    else
      return TaxonName.where(:iczn_group => 'family').order(:name)
    end
  end
  
  def genus_taxa_in_family(family_id)
    puts "family id: #{family_id}"
    if family_id
      return TaxonName.where(:iczn_group => 'genus', :parent_id => family_id).order(:name)
    else
      return [] # would be too many genus to list without family
    end
  end
  
end
