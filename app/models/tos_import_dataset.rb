class TosImportDataset < ActiveRecord::Base
  belongs_to :proj
  belongs_to :people
  
  attr_accessor :filename
  attr_reader :status
  
  validates_presence_of :filename
  
end
