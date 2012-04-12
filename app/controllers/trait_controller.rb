# A mockup. 
# Search for 'trait' in layout_helper.rb and navigation helper to see how I configured the tabs. Ultimately we'll write some code that hides the rest of the world (you can select tabs to show in settings at present)
# http://127.0.0.1:3000/projects/12/trait

# There is no Trait model in the database. 

# These actions are specific to the trait-based data-capture workflow
# being developed in conjunection with NESCent projects.

class TraitController < ApplicationController

   # Maps to a splash page?
  def index
  end

 def new
    @otu = Otu.new
    @ce = Ce.new
    #@otu_groups = @proj.otu_groups
  end
  
  def create
    # Called to allow recursive addition of Otus from a TaxonName and its children
    @otu = Otu.new(params[:otu])
    @ce = Ce.new(params[:ce])
    @ce.save
    @otu[:source_ce_id] = @ce.id
    if @otu.save
      notice "Created a new OTU." 
      # @show = ['default'] # see /app/views/shared/layout
      # render :action => :show 
       render :action => :enter_from_ref and return
    else
      notice 'Problem creating the OTU(s)!'
      # @otu_groups = @proj.otu_groups
      render :action => :enter_from_ref and return
    end
  end
  
 # Match these methods to Cory's stories 
 def enter_from_ref
    @otu = Otu.new
    @ce = Ce.new
  end

  def browse_data
  end
  
  

  # Not sure if I need these, put them in for the navigator
  # but if I go with sub-nav can probably remove
  def choose_ref
  end

  def new_ref
  end

  def choose_taxon
  end

  def otus_for_ref
  end

  def enter_species_name
  end

  def enter_population_name
  end
  
  def include_multi_populations
  end


end
