class AddUnderlyingUploadedFileToDataset < ActiveRecord::Migration
  def self.up
    add_column :tos_import_datasets, :filepath, :string
  end

  def self.down
    remove_column :tos_import_datasets, :filepath
  end
end
