class CreateDisposalPhotos < ActiveRecord::Migration
  def change
    create_table :disposal_photos do |t|
    	t.belongs_to :disposal_inspection
    	t.string :ftp_filename
    	t.string :path
    	t.boolean :sent, :default => false
    end
  end
end
