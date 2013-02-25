class CreateTosImportDatasets < ActiveRecord::Migration
  def self.up
    create_table :tos_import_datasets do |t|
      t.string :filename
      t.string :status
      t.references :proj
      t.references :people

      t.timestamps
    end
  end

  def self.down
    drop_table :tos_import_datasets
  end
end
