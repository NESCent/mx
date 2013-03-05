require 'treeofsex_import/validator'

class TosImportController < ApplicationController
  layout 'minimal'
  def import
    # analogous to 'new'
    # requires dataset id
    @dataset = TosUploadDataset.find(params[:dataset_id])
    # just show a form that posts to create
  end

  def create
    # Receives the POST of import
    @import_chrs_messages = []
    @import_datasets_messages = []
    # start importing
    @dataset = TosUploadDataset.find(params[:dataset_id])
    # validated successfully
    parsed_datasets, parsed_chrs = validate_dataset(@dataset)
    
    return if (parsed_chrs.nil? || parsed_datasets.nil?)
    
    import_chrs(parsed_chrs)
    import_datasets(parsed_datasets)
  end

  def show
  end

  def index
  end

  def cancel
  end

  def destroy
  end

  private
  
  def validate_dataset(dataset)
    validator = TreeOfSexImport::Validator.new(dataset.filepath)
    # These still need to be made dynamic
    validator.quantitative_header_start = "chromosome number (female)"
    validator.quantitative_header_end = "c-value"
    validator.qualitative_header_start = "predicted ploidy (1n, 2n, 3n, 4n)"
    validator.qualitative_header_end = "molecular basis (dosage, Y dominant, W dominant)"

    success = validator.validate
    @validator_messages = validator.messages
    if success
      return [validator.datasets, validator.chr_headers]
    else
      flash[:alert]= "Unable to validate dataset"
      return nil
    end
  end

  def import_chrs(chrs)
    # chrs need to be imported into database.
    quant = chrs[:quantitative]
    quant.each do |chr_name|
      # find_or_create_by_name - where is this defined
      # http://api.rubyonrails.org/classes/ActiveRecord/Base.html
      chr = Chr.find_or_create_by_name_and_proj_id(:name => chr_name, 
            :is_continuous => true,
            :proj_id => @proj.id,
            :creator_id => @dataset.people.id,
            :updator_id => @dataset.people.id)
      @import_chrs_messages << "Adding continuous character #{chr_name}"
      chr.save
    end

    qual = chrs[:qualitative]
    qual.each do |chr_hash|
      # each chr is a hash with :raw_header_name, :chr_name, :chr_states
      # see if this project has a character with this name
      chr = Chr.find_or_create_by_name_and_proj_id(:name => chr_hash[:chr_name],
            :is_continuous => false,
            :proj_id => @proj.id,
            :creator_id => @dataset.people.id,
            :updator_id => @dataset.people.id)
      @import_chrs_messages << "Adding categorical character #{chr_hash[:chr_name]}"
      chr.save
      chr_hash[:chr_states].each do |state_name|
        chr_state = ChrState.find_or_create_by_name_and_chr_id(:name => state_name,
                    :state => state_name,
                    :chr_id => chr.id,
                    :creator_id => @dataset.people.id,
                    :updator_id => @dataset.people.id)
        @import_chrs_messages << "Adding state #{state_name} to #{chr_hash[:chr_name]}"
        chr_state.save
      end
    end
  end

  def import_datasets(datasets)
    # datasets is an Array of Hashes
    @import_datasets_messages << "Received #{datasets.size} datasets"
    @duplicates = []
    # taxa
    
    # need to make an otu out of each or detect if it exists
      datasets.each do |d|
        taxon = d[:taxon]
        otu_name = "#{taxon[:genus].capitalize.strip} #{taxon[:species].capitalize.strip}"
        # Find or create an OTU for this row
        #    TAXON_SYMBOLS = [:higher_taxonomic_group, :order, :family, :genus, :species]
        
        # find from parent
        # consider iczn_group
        last_parent = nil
        # Do we need a root taxon for the project or should there be htg in each
        # project
        # 
        if taxon[:higher_taxonomic_group]
          # no root
          # Should use TaxonName.create_new here
          taxon_name = TaxonName.find_or_create_by_name(:name => taxon[:higher_taxonomic_group],
              :iczn_group => "n/a",
              :creator_id => @dataset.people.id,
              :updator_id => @dataset.people.id)
          # These taxon names do not supply parent
          taxon_name.projs << @proj
          taxon_name.save
          last_parent = taxon_name.id
        end
        
        # order
        if taxon[:order]
          taxon_name = TaxonName.find_or_create_by_name_and_iczn_group(:name => taxon[:order],
              :iczn_group => "order",
              :parent_id => last_parent,
              :creator_id => @dataset.people.id,
              :updator_id => @dataset.people.id)
          taxon_name.save
          last_parent = taxon_name.id
        else
          # there is no order
        end
        
        # family
        if taxon[:family]
          taxon_name = TaxonName.find_or_create_by_name_and_iczn_group(:name => taxon[:family],
              :iczn_group => "family",
              :parent_id => last_parent,
              :creator_id => @dataset.people.id,
              :updator_id => @dataset.people.id)
          taxon_name.save
          last_parent = taxon_name.id
        end
        
        # genus
        if taxon[:genus]
          taxon_name = TaxonName.find_or_create_by_name_and_iczn_group(:name => taxon[:genus],
              :iczn_group => "genus",
              :parent_id => last_parent,
              :creator_id => @dataset.people.id,
              :updator_id => @dataset.people.id)
          taxon_name.save
          last_parent = taxon_name.id
        end
        
        # species
        # Validator is not populating author and date into model
        # what about subspecies?
        # can taxonifi help with this?
        if taxon[:species]
          taxon_name = TaxonName.find_or_create_by_name_and_iczn_group(:name => taxon[:species],
              :iczn_group => "species",
#               :author => d[:species_author]
              :parent_id => last_parent,
              :creator_id => @dataset.people.id,
              :updator_id => @dataset.people.id)
          taxon_name.save
          
          # now make an otu
          
          # This is where we check for duplicates
          otu_notes = d[:notes_comments]
          
          # search for duplicates of this OTU name with the same taxon_name_id
          unless Otu.where(:name => otu_name, :taxon_name_id => taxon_name.id).empty?
            @duplicates << { :name => otu_name, :taxon_name_id => taxon_name.id }
            next
          end
          
          otu = Otu.new(:name => otu_name,
                :taxon_name_id => taxon_name.id,
                :notes => otu_notes,
                :creator_id => @dataset.people.id,
                :updator_id => @dataset.people.id)
          otu.save
          # refs
          # codings
          
        end
      end #end of datasets.each
  end

end
