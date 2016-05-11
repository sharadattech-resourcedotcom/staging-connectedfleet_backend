class InspectionsPdf

	def self.generate_pdf(inspection, params)
		font = {:normal => Rails.public_path+'OpenSans-Regular.ttf', :bold => Rails.public_path+'OpenSans-Bold.ttf'}
		logo = "#{Rails.root}/app/assets/images/clm-logosmall.jpg"
		pdf = Prawn::Document.new
    	img_width = 200
    	page_width = 550
    	down = 15
    	clm_down = 0
    	if inspection.user.company_id == 3
    		pdf.image logo, width: 200, height: 105, position: :left
    		clm_down = 120
    	end
    	appointment = inspection.job.appointment if !inspection.job.nil?
    	if !appointment.nil?
	    	address = appointment.postcode if !appointment.postcode.nil?
	    	address = address+"  "+ appointment.city if !appointment.city.nil?
	    	address = address+"  "+ appointment.street if !appointment.street.nil?
	    else
	    	address = inspection.postcode if !inspection.postcode.nil?
	    	address = address+"  "+ inspection.city if !inspection.city.nil?
	    	address = address+"  "+ inspection.address_line_1 if !inspection.address_line_1.nil?
	    	address = address+", "+ inspection.address_line_2 if !inspection.address_line_2.nil?
	    	address = address+" "+ inspection.home_number if !inspection.home_number.nil?
	    end
		pdf.stroke_color "000000"

		pdf.text_box 'Inspection', :size => 20, :at => [pdf.bounds.left, pdf.bounds.top - clm_down], :width => 500, :style => :bold_italic
		pdf.text_box 'Date: ' + inspection[:created_at].strftime('%d/%m/%Y'), :size => 13, :at => [pdf.bounds.left, pdf.bounds.top - 25 - clm_down], :width => 500, :style => :bold_italic

		pdf.move_down 65 + clm_down / 3
		
		pdf.font(font[:bold], :size => 13, :style => :bold_italic) do
			pdf.text_box "Driver:", :at => [0, pdf.cursor], :width => 400
		 	pdf.text_box inspection.driver_full_name, :at => [72, pdf.cursor], :width => 400
		end
		pdf.move_down 20
		if !inspection.customer_name.nil?
			pdf.font(font[:bold], :size => 13, :style => :bold_italic) do
				pdf.text_box "Customer: ", :at => [0, pdf.cursor], :width => 400
			 	pdf.text_box inspection.customer_name, :at => [72, pdf.cursor], :width => 400
			end
			pdf.move_down 20
		end
		if !appointment.nil?
			pdf.font(font[:normal], :size => 13, :style => :bold_italic) do
				pdf.text_box "Appointment: ", :at => [0, pdf.cursor], :width => 400
			end
			pdf.move_down 20
			pdf.font(font[:normal], :size => 12, :style => :bold_italic) do
				pdf.text_box "ID: ", :at => [20, pdf.cursor], :width => 400
			 	pdf.text_box appointment.id.to_s, :at => [72, pdf.cursor], :width => 400
			 	pdf.move_down 20
			 	pdf.text_box "Branch: ", :at => [20, pdf.cursor], :width => 400
			 	pdf.text_box appointment.branch.description, :at => [72, pdf.cursor], :width => 400
			 	pdf.move_down 20
			 	pdf.text_box "Product: ", :at => [20, pdf.cursor], :width => 400
			 	pdf.text_box appointment.product.description, :at => [72, pdf.cursor], :width => 400
			 	pdf.move_down 20
			 	if !address.nil?
				 	pdf.text_box "Address: ", :at => [20, pdf.cursor], :width => 400
				 	pdf.text_box address, :at => [72, pdf.cursor], :width => 400 
					pdf.move_down 20
				end
				if !appointment.claim_number.nil?
					pdf.text_box "Claim number: ", :at => [20, pdf.cursor], :width => 400 
				 	pdf.text_box appointment.claim_number.to_s, :at => [123, pdf.cursor], :width => 400 
				 	pdf.move_down 20
				end
				if !appointment.excess.nil?
				 	pdf.text_box "Excess: ", :at => [20, pdf.cursor], :width => 400 
				 	pdf.text_box appointment.excess.to_s, :at => [77, pdf.cursor], :width => 400
				 	pdf.move_down 20
			 	end
			 	if !appointment.contact_name.nil?
				 	pdf.text_box "Contact name: ", :at => [20, pdf.cursor], :width => 400
				 	pdf.text_box appointment.contact_name.to_s, :at => [123, pdf.cursor], :width => 400 
				 	pdf.move_down 20
				end
				if !appointment.email.nil?
			 		pdf.text_box "Contact email: ", :at => [20, pdf.cursor], :width => 400 
			 		pdf.text_box appointment.email.to_s, :at => [123, pdf.cursor], :width => 400
			 		pdf.move_down 20
			 	end
			end	
		else
			if !address.nil?
			 	pdf.text_box "Address: ", :at => [0, pdf.cursor], :width => 400
			 	pdf.text_box address, :at => [72, pdf.cursor], :width => 400 
				pdf.move_down 10
			end	
		end
		if !inspection.vehicle.nil?
			pdf.move_down 10
			pdf.font(font[:normal], :size => 13, :style => :bold_italic) do
				pdf.text_box "Vehicle: ", :at => [0, pdf.cursor], :width => 400
			 	pdf.text_box inspection.vehicle_info, :at => [70, pdf.cursor], :width => 400
			end
		end
		if !inspection.job_type.nil?
			pdf.move_down 20
			pdf.font(font[:normal], :size => 13, :style => :bold_italic) do
				pdf.text_box "Job type: ", :at => [0, pdf.cursor], :width => 400
			 	pdf.text_box inspection.job_type, :at => [70, pdf.cursor], :width => 400
			end
		end
		if !inspection.ref_number.nil?
			pdf.move_down 20
			pdf.font(font[:normal], :size => 13, :style => :bold_italic) do
				pdf.text_box "REF Number: ", :at => [0, pdf.cursor], :width => 400
			 	pdf.text_box inspection.ref_number, :at => [90, pdf.cursor], :width => 400
			end	
		end		

		if !inspection.notes.nil? && inspection.notes != ''
			pdf.move_down 20
			pdf.font(font[:normal], :size => 13, :style => :bold_italic) do
				pdf.text_box "Notes: ", :at => [0, pdf.cursor], :width => 400
			end
			pdf.font(font[:normal], :size => 13, :style => :italic) do
			 	pdf.text_box inspection.notes, :at => [70, pdf.cursor], :width => 400
			end
			
			pdf.move_down 20*(inspection.notes.length/55)
		end

		if !inspection.mileage.nil? && inspection.mileage != 0
			pdf.move_down 20
			pdf.font(font[:normal], :size => 13, :style => :bold_italic) do
				pdf.text_box "Mileage: ", :at => [0, pdf.cursor], :width => 400
			 	pdf.text_box inspection.mileage.to_s, :at => [70, pdf.cursor], :width => 400
			end			
		end

		pdf.font(font[:normal], :size => 13, :style => :bold_italic) do
			pdf.move_down 20
			pdf.text_box 'Loose items: ', :at => [0, pdf.cursor], :width => 400
		 	pdf.text_box inspection.loose_items, :at => [100, pdf.cursor], :width => 400
		end

		pdf.start_new_page
		pdf.font(font[:normal], :size => 13, :style => :bold_italic) do
				pdf.text_box "Damage items: ", :at => [0, pdf.cursor], :width => 400
		end
		pdf.move_down 35
		inspection.damageItems.each_with_index do |dmg, index|
			begin
				if !dmg.file_path.nil? && File.exist?(Rails.public_path+ 'damages/' +dmg.file_path)
					size_array = FastImage.size(Rails.public_path+ 'damages/' +dmg.file_path)
					ratio = size_array[0].to_f / size_array[1]
					
					if index%2 != 0
						pdf.font(font[:normal], :size => 10) do
							pdf.text_box 'Description: ', :at => [320, pdf.cursor], :width => 100
							pdf.move_down 10
							pdf.text_box dmg.description, :at => [320, pdf.cursor], :width => 200
						end
						pdf.move_down down
						pdf.image Rails.public_path+ 'damages/' +dmg.file_path, :at => [320, pdf.cursor], :width => img_width
						pdf.move_down img_width/ratio + 40
					else
						down = 15
						if pdf.cursor - img_width/ratio < 0
							pdf.start_new_page
						end
						pdf.font(font[:normal], :size => 10) do
							pdf.text_box 'Description: ', :at => [0, pdf.cursor], :width => 100
							pdf.move_down 10
							pdf.text_box dmg.description, :at => [0, pdf.cursor], :width => 200
						end
						down = down * dmg.description.length/35 if dmg.description.length/35 > 0
						pdf.move_down down
						pdf.image Rails.public_path+ 'damages/' +dmg.file_path, :at => [5, pdf.cursor], :width => img_width
						pdf.move_up down + 10
					end
				end
			rescue => ex
				then next
			end
		end

    	return pdf
	end
end