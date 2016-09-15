class MakeCsvDirectory < ActiveRecord::Migration
  def change
  	dir = "#{Rails.root}/csv/"
	FileUtils.mkdir_p(dir) unless File.directory?(dir)
  end
end
