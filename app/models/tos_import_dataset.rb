class TosImportDataset < ActiveRecord::Base
  belongs_to :proj
  belongs_to :people
end
