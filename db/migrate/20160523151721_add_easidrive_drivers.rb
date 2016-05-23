class AddEasidriveDrivers < ActiveRecord::Migration
  def change
	horsham =[["168001010", "Richard Haite"],
		["168001029", "Asif Sedric-Jalal"],
		["168001031", "Richard Hellings"],
		["168001046", "Colin Mitchell"],
		["168001051", "Philip Bell"],
		["168001060", "Chrishna Othendee"],
		["168001065", "Roger Seear"],
		["168001069", "Ron Tomsett"],
		["168001075", "Irfan Malik"],
		["168001080", "Hannah Briggs"],
		["168001087", "Francesco Ventimiglia"],
		["168001090", "Leul Mulissa"],
		["168001093", "Richard Godfrey-Cass"]]

	hitchin = [["168001020", "Brian Guntley"],
		["168001021", "Steve Woodward"],
		["168001022", "John Betts"],
		["168001023", "Paul Ulbrich"],
		["168001024", "Alan Bunyan"],
		["168001025", "Colin Hall"],
		["168001026", "Terry White"],
		["168001028", "Garry Swinn"],
		["168001035", "Martin Kelly"],
		["168001037", "Dave Williams"],
		["168001039", "Paul Kew"],
		["168001040", "Gordon Sanger"],
		["168001059", "Dennis Levey"],
		["168001067", "Stewart Jones"],
		["168001076", "Les Chappell"],
		["168001088", "Toni Burgess"]]

bristol = [["168001011", "Allan Roberts"],
["168001012", "Steve White"],
["168001013", "Hilary Seward"],
["168001014", "Steve Pellowe"],
["168001015", "David Harries"],
["168001016", "Pete Streatfield"],
["168001017", "Bruno Douglas"],
["168001018", "Ian Woodhouse"],
["168001047", "Martin Ireland"],
["168001066", "Craig Purnell"],
["168001068", "Stephen Milburn"],
["168001073", "Vicky Dunsby"],
["168001074", "John Hallett"],
["168001083", "Chris  Bees"]]

		horsham.each do |data|
			 u = Hash.new
			 u[:first_name] = data[1].split(" ").first
			 u[:last_name] = data[1].split(" ").last
			 u[:email] = data[1].downcase.gsub(" ","") + "@ed.com"
			 u[:password] = u[:first_name] + "123!!"
			 u[:role_description] = "Driver"
			 user = User.create(u, 34)
			 user.update_attributes(:branch_id => Branch.where("company_id = 34 AND description = 'Horsham'").take.id, :payroll_number => data[0])
		end

		hitchin.each do |data|
			 u = Hash.new
			 u[:first_name] = data[1].split(" ").first
			 u[:last_name] = data[1].split(" ").last
			 u[:email] = data[1].downcase.gsub(" ","") + "@ed.com"
			 u[:password] = u[:first_name] + "123!!"
			 u[:role_description] = "Driver"
			 user = User.create(u, 34)
			 user.update_attributes(:branch_id => Branch.where("company_id = 34 AND description = 'Hitchin'").take.id, :payroll_number => data[0])
		end

		bristol.each do |data|
			 u = Hash.new
			 u[:first_name] = data[1].split(" ").first
			 u[:last_name] = data[1].split(" ").last
			 u[:email] = data[1].downcase.gsub(" ","") + "@ed.com"
			 u[:password] = u[:first_name] + "123!!"
			 u[:role_description] = "Driver"
			 user = User.create(u, 34)
			 user.update_attributes(:branch_id => Branch.where("company_id = 34 AND description = 'Bristol'").take.id, :payroll_number => data[0])
		end
  end
end
