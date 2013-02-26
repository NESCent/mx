class RenameTosImportDatasetToTosUploadDataset < ActiveRecord::Migration
  def self.up
    rename_table :tos_import_datasets, :tos_upload_datasets
  end

  def self.down
    rename_table :tos_upload_datasets, :tos_import_datasets
  end
end
