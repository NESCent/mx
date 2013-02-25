class TosImportController < ApplicationController
  layout 'minimal'
  # before_filter make sure user is logged in and has access to this project
  # Looks like applicationController takes care of login

  def new
    @dataset = TosImportDataset.new
  end

  def create
    @dataset = TosImportDataset.new(params[:dataset])
    if @dataset.save
      flash[:notice] = 'Dataset uploaded successsfully'
      redirect_to(:action => 'list')
    else
      render('new')
    end
  end

  def update
    @dataset = TosImportDataset.find(params[:id])
    if @dataset.update_attributes(params[:dataset])
      flash[:notice] = 'Dataset updated successfully'
      redirect_to(:action => 'show', :id => @dataset.id)
    else
      render('edit')
    end
  end

  def edit
    @dataset = TosImportDataset.find(params[:id])
  end

  def delete
    @dataset = TosImportDataset.find(params[:id])
  end

  def destroy
    # accepts the delete form
    dataset = TosImportDataset.find(params[:id])
    # Need to delete the CSV file here?
    dataset.destroy
    flash[:notice] = 'Dataset destroyed successfully'
    redirect_to(:action => 'index')
  end

  def index
    list
    render('list')
  end
  
  def list
    @datasets = TosImportDataset.order('created_at DESC')
  end

  def show
    @dataset = TosImportDataset.find(params[:id])
  end

end
