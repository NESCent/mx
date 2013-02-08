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
    @taxa[:family] = family_taxa_in_order(@taxa[:order].first)
    # Genus
    @taxa[:genus] = genus_taxa_in_family(@taxa[:family].first)
    # we need character groups (traits)
    @trait_groups = trait_groups
    @trait_names = traits_in_group(@trait_groups.first) #this would only work for the first
    @trait_values = trait_values_for_trait(@trait_names.first)
  end
  
  # are any of these satisfied by the taxon names controller?
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
  
  def list_trait_groups
    @trait_groups = trait_groups
    render :json => @trait_groups
  end
  
  def list_traits
    @traits = traits_in_group(params[:trait_group_id])
    render :json => @traits
  end
  
  def list_trait_values
    @trait_values = trait_values_for_trait(params[:trait_id])
    render :json => @trait_values
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
    if family_id
      return TaxonName.where(:iczn_group => 'genus', :parent_id => family_id).order(:name)
    else
      return [] # would be too many genus to list without family
    end
  end
  
  # traits
  def trait_groups
    return @proj.chr_groups
  end
  
  def traits_in_group(trait_group_id)
    if trait_group_id
      return ChrGroup.find(trait_group_id).chrs
    else
      return []
    end
  end
  
  def trait_values_for_trait(trait_id)
    if trait_id
      trait = Chr.find(trait_id)
      return trait.chr_states
    else
      return []
    end
    
  end

end
