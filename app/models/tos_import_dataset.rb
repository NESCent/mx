class TosImportDataset < ActiveRecord::Base
  belongs_to :proj
  belongs_to :people, :class_name => "Person"
  
  attr_accessor :uploaded_file
  attr_protected :filename, :filepath
  attr_reader :status
  attr_accessible :uploaded_file, :status
    
  before_save :handle_uploaded_file
  after_save :clear_uploaded_file
  before_destroy :delete_filesystem_file
  
  private
  
  def handle_uploaded_file
    unless uploaded_file.blank?
      self.filename = base_part_of(uploaded_file.original_filename)
      output_path = Rails.root.join('public','uploads', uploaded_file.original_filename)
      File.open(output_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end
      self.filepath = output_path.to_s
    end
  end
  
  def clear_uploaded_file
    self.uploaded_file = nil
    return true
  end
  
  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/,'')
  end

  def delete_filesystem_file
      File.delete(filepath)
  end
  
end
