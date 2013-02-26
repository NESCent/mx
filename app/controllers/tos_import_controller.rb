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
    # start importing
    dataset = TosUploadDataset.find(params[:dataset_id])
    # get the path to the file
    validator = TreeOfSexImport::Validator.new(dataset.filepath)
    if validator.read # will generate a lot of puts console output
      flash[:notice] = "Success, validated #{validator.datasets.size} datasets!"
    else
      flash[:alert]= "Unable to validate dataset"
    end
  end

  def show
  end

  def index
  end

  def cancel
  end

  def destroy
  end

end
