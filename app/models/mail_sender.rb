class MailSender

    @host = 'http://connectedfleet.com'

    def self.send_email_about_closed_period(period) 
        template = CompanyEmail.where('company_id = ? AND email_type = ?', period.user.company_id, 'Closed period').take   
        email_text  = template.body(period)
        mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : period.agent_email
            from 'noreply@3reign.com'
             subject  template.desc_subject(period)
             html_part do
                content_type 'text/plain; charset=UTF-8'
                body email_text
             end
        end  

        mail.deliver
    end

    def self.test_email
        mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : "radwas88@gmail.com"
            from 'noreply@3reign.com'
             subject  "To see if this email will be sent"
             html_part do
                content_type 'text/plain; charset=UTF-8'
                body "Just to check this"
             end
        end  

        mail.deliver
    end

    def self.send_email_on_new_month(period)
        mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : period.user.email
           from 'noreply@3reign.com'
           subject  'Reminder to Close Month End Mileage'
           html_part do
              content_type 'text/html; charset=UTF-8'
              body  '<p>Dear All<p>

                    <p>This is a reminder to log your month end mileage and close your month. This must be done by the 5th of this month the latest.</p>
                    <p>Failing this, the system will close your month automatically and use your last known mileage to calculate</p>
                    <p>the relevant payments and submit this to payroll</p>
                    <p>Once you have closed your month, it will be sent to your Regional Manager who will authorise it.</p>
                    <p>If there is any irregularity with your mileage please let your line manager know immediately so they can correct it before the closing date.</p>
                    <p>You will not be able to correct this by yourself. </p>
                    <p>Please visit http://connectedfleet.com to login and review your mileage.</p>
                    <p>If you have any issues closing the month down, please call CLM on 01908219361.</p>'

           end
        end
        if mail.deliver
            puts 'Email sent to ' + period.user.email
        end
    end

    def self.send_email_about_unclosed_period(period)
        # TIP: period.user gives you user object to which 
        # you should send an email. period.user.email give an email
        #  email_text  = 'You have unclosed month (period started on ' + period.start_date.to_s + ').'
        # email_text += 'Please login here <a href=' + (@host).to_s + '/drivers#/' + period.user_id.to_s + '/trips> ADDRESS </a> to close period '
        mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : period.user.email
          #to 'shinga@poczta.fm'
          from 'noreply@3reign.com'
          subject 'Second Reminder to Close Month End Mileage'
          html_part do
            content_type 'text/html; charset=UTF-8'
            body "<p>Dear All</p>" + 
                  "<p>This is your second reminder to log your month end mileage and close your month today – the system indicates this has not been completed yet. Failing this, the system will close your month automatically and use your last known mileage to calculate the relevant payments and submit this to payroll.  You will not get an opportunity to dispute or amend the figures.</p>" + 
                  "<p>Please visit http://connectedfleet.com to login and review your mileage.</p>" + 
                  "<p>Once you have closed your month, it will be sent to your Line Manager who will authorise it. If there is any irregularity with your mileage please let your CLM Internal Account Manager know immediately so it can be corrected before the closing date. You will not be able to correct this by yourself.</p>" + 
                  "<p>If you have any issues closing the month down, please call your Internal Account Manager at CLM on 01908219361.</p>"
          end
        end

        if mail.deliver
            puts 'Email sent to ' + period.user.email
        end
    end

    def self.send_final_reminder(period)
        mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : period.user.email
          from 'noreply@3reign.com'
          subject 'Final Reminder to Close Month End Mileage'
          html_part do
            content_type 'text/html; charset=UTF-8'
            body "<p>Dear All</p>" + 
                  "<p>This is your FINAL REMINDER to log your month end mileage and close your month today – the system indicates this has not been completed yet. Failing this, the system will close your month automatically and use your last known mileage to calculate the relevant payments and submit this to payroll.  You will not get an opportunity to dispute or amend the figures.</p>" + 
                  "<p>Please visit http://connectedfleet.com to login and review your mileage.</p>" + 
                  "<p>Once you have closed your month, it will be sent to your Line Manager who will authorise it. If there is any irregularity with your mileage please let your CLM Internal Account Manager know immediately so it can be corrected before the closing date. You will not be able to correct this by yourself.</p>" + 
                  "<p>If you have any issues closing the month down, please call your Internal Account Manager at CLM on 01908219361.</p>"
          end
        end

        if mail.deliver
            puts 'Email sent to ' + period.user.email
        end
    end

    def self.send_email_about_log_synchronize_failed(logs_list)
    report = ''
    logs_list.each do |log|
       report = report + "<p>Id: "+log.id.to_s+"</p>"+
        "<p>Driver: "+log.user.first_name+" "+log.user.last_name+"</p>"+
        "<p> Date: "+log.created_at.to_s+"</p>"+
        "<p> Input:<br>"+log.input_val+"</p>"+
        "<p> Output:<br>"+log.output_val+"</p><br>"
    end
      mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : 'radwas88@gmail.com'
        from 'noreply@3reign.com'
        subject 'Raport about failed synchronizations'
        html_part do
          content_type 'text/html; charset=UTF-8'
          body report
        end
      end
    mail.deliver
    end

    def self.send_reminder_to_agent(period)
        #period.agent_email = 'radek@appsvisio.com'
        #agent = User.where("email ilike '%"+ period.agent_email + "%'").take
        template = CompanyEmail.where('company_id = ? AND email_type = ?', period.user.company_id, 'Reminder to agents').take   
        email_text  = template.body(period)                
        mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : period.agent_email
            from 'noreply@3reign.com'
             subject  template.desc_subject(period)
             html_part do
                content_type 'text/plain; charset=UTF-8'
                body email_text
             end
        end  
        if mail.deliver
            puts "sends to " +period.agent_email
        end
    end

    def self.send_email_about_approved_period(period)
        email_text  = '<p>Dear ' + period.user.full_name + '</p>' +
                      '<p>This is a short note to advise you that your mileage record has now been approved and will be submitted to payroll.</p>' + 
                      '<p>Kind regards</p>'
                      
        mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : period.user.email
            from 'noreply@3reign.com'
            subject  'Mileage submission approval'
            html_part do
              content_type 'text/html; charset=UTF-8'
              body email_text
            end
        end  

        mail.deliver
    end

    def self.send_email_with_monthly_summary(company,file)

        xls = File.join(Rails.root,'log',file.name + '.xls')

        email_text = "Sending the spreadsheet"
        mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : 'shinga@poczta.fm'

          from 'noreply@3reign.com'
          subject 'spreadsheet'
          body email_text
          add_file (xls)
        end

        # mail.deliver
    end

    def self.send_email_about_automatically_approved(period)
        mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : period.agent_email
            from 'noreply@3reign.com'
            subject 'Outstanding driver mileage submissions requiring authorisation'
            html_part do
             content_type 'text/html; charset=UTF-8'
             body '<p>Dear ' + period.agent_email + '</p>
                   <br/>
                   <br/>
                   <p>The following driver’s month end mileages have not yet been authorised:</p>
                   <br/>
                   <p>' + period.user.full_name + '</p>
                   <p>It is important that these are reviewed and authorised by close of business on the 9th –
                   after which time they will be automatically authorised, passed to payroll and the driver’s salary will be deducted with the relevant amounts.</p>
                   <br/>
                   <p>Please login to ' +
                      (@host).to_s + '/drivers#/' + period.user_id.to_s + '/trips/previousPeriods/' + period.normalized_start_date +
                      'to review the driver\'s mileages</p>
                   <p>If you have any issues authorising these, please call CLM on 01908219361.</p>'

            end
        end    
        # mail.deliver
    end

    def self.send_emails_about_inspection_job_complete(company_id)
        template = CompanyEmail.where("company_id = ? AND email_type = 'Inspection job completed'", company_id).take
        inspections = MobileInspection.company_inspections(company_id, false)
        
        inspections.each do |inspection|
            ready_to_send = true
            #agent = User.where(:id => ManagerDriver.where(:driver_id => inspection.user_id).take.manager_id).take
            inspection.damageItems.each do |damage|
              if damage.file_path.nil? || damage.file_path == ''
                ready_to_send = false
                puts inspection.id
                break
              end
            end
            if !template.nil? && ready_to_send
                receips = []
                if template.recipients != '[CONTACT_EMAIL]'
                  receips = receips + template.recipients.split(/[,;]/)
                end

                if !inspection.customer_email.nil? && inspection.customer_email != ""
                  receips = receips + [inspection.customer_email]
                end
                if receips.length == 0
                    then next
                end

                begin
                    mail = Mail.new do
                        to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : receips
                        from 'noreply@3reign.com'
                        subject template.desc_subject(inspection)
                        content_type "multipart/alternative"
                        part "text/plain" do |p|
                            p.body = template.body(inspection)
                        end
                        attachments['Inspection_'+inspection.id.to_s+'_'+Time.now.strftime('%d-%m-%Y_%H:%M')+'.pdf'] = {
                                      mime_type: 'application/pdf',
                                      content: InspectionsPdf.generate_pdf(MobileInspection.where(:id => inspection.id).take, nil).render,
                                      disposition: "inline"}
                    end
                    if mail.deliver
                        puts "Email sent"
                        inspection.is_sent = true
                        inspection.save
                    end
                rescue => ex
                  puts ex.backtrace
                end
            end
        end
    end

    def self.send_sales_staff_reports
        Company.all.each do |company|
            template = CompanyEmail.where("company_id = ? AND email_type = 'Sales Staff'", company.id).take
            if !template.nil?
                mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : template.recipients.split(/[,;]/)
                    from 'noreply@3reign.com'
                    subject "Sales Staff report - " + Date.today.strftime("%F")
                    html_part do
                        content_type 'text/html; charset=UTF-8'
                        body SalesStaff.email_content(company.id)
                    end
                end

                if mail.deliver
                    puts "Email sent"
                end
            end
        end
    end

    def self.send_upload_confirm(status, file_path, company_name, backtrace = nil)
        receivers = ['kiszewski.marcin@gmail.com', 'radwas88@gmail.com']
        if status 
            email_text  = "Date: " + Time.now.to_s          
            mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : receivers
                from 'noreply@3reign.com'
                 subject  "Uploaded " + company_name + " file."
                 content_type "multipart/alternative"
                 part "text/plain" do |p|
                    p.body = email_text
                end
                attachments[company_name + '.csv'] = {
                              mime_type: 'text/csv',
                              content: File.read(file_path),
                              disposition: "inline"}
            end  
        else
            email_text  = "Date: " + Time.now.to_s + "\n" + "Backtrace: " + backtrace.join("\n")         
            mail = Mail.new do
            to Rails.env != 'production' ? 'kiszewski.marcin+spam@gmail.com' : receivers
                from 'noreply@3reign.com'
                 subject  "Failed upload " + company_name + " file."
                 content_type "multipart/alternative"
                 part "text/plain" do |p|
                    p.body = email_text
                end
                attachments[company_name + '.csv'] = {
                              mime_type: 'text/csv',
                              content: File.read(file_path),
                              disposition: "inline"}
            end  
        end
        mail.deliver
    end
end