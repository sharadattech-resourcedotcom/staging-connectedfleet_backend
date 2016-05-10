class CreateDisposalPhotoDir < ActiveRecord::Migration
  def change
    dir = "#{Rails.root}/public/disposal_photos/"
	FileUtils.mkdir_p(dir) unless File.directory?(dir)
  end
end
