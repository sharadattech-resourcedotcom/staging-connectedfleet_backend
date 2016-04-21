class AppVersion < ActiveRecord::Base
	belongs_to :company
	validates_presence_of :company_id, :version_name, :version_code, :comment, :file_path

	def self.create(version, file_name)
		puts version
		v = AppVersion.new
		v.company_id = version[:company_id].to_i
		v.version_code = version[:version_code]
		v.version_name = version[:version_name]
		v.comment = version[:comment]
		v.file_path = 'apps/'+file_name
		v.internal_group = version[:internal_group]
		if v.valid?
			v.save!
		end
		return v
	end
end
