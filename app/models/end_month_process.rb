class EndMonthProcess

  def self.current_date
    #return Date.new(2014, 10, 1)
    return Date.today
  end
  
  # Period need to be started in the previous month
  # and has status as unclosed
  #
  # @return bool
  #
  def self.has_closed_period(driver) 
    previous_month = self.current_date - 1.month
    
    return !driver.periods.where(
      "status = ? AND date_part('month', start_date) <= ? AND date_part('year', start_date) <= ?", 
      'opened', previous_month.month, previous_month.year
    ).first.nil?
  end
  
  # on 5th of each month close automatically
  # all unclosed yet periods and send emails
  # to drivers that their mileage has been closed
  #
  # @return bool
  #
  def self.auto_close_drivers_trips
    # if self.current_date.day == 5
    #   previous_month = self.current_date - 1.month
    #
    #   periods = Period.where(
    #   "status <> ? AND date_part('month', start_date) <= ? AND date_part('year', start_date) <= ?",
    #   'closed', previous_month.month, previous_month.year
    #   )
    #
    #   # raise 'TODO: close periods with last trip end_mileage'
    #   periods.each do |p|
    #     t = Trip.joins('INNER JOIN periods ON periods.start_date = trips.period_start_date AND periods.start_date = \'' + p.start_date.iso8601 + '\'').first
    #
    #     unless t.nil?
    #       p.close(t.end_mileage, 'radwas88@gmail.com', 'system')
    #     else
    #       # if no trips in period we close with start period mileage
    #       p.close(p.start_mileage, 'radwas88@gmail.com', 'system')
    #     end
    #   end
    # end
  end
  
  # On 9th of each month send reminder to agents 
  # about unapproved periods 
  def self.send_reminder_to_agents
    if self.current_date.day == 9
       previous_month = self.current_date - 1.month
      puts previous_month
      periods = Period.where(
        "status = ? AND approved = FALSE AND date_part('month', end_date) >= ? AND date_part('year', start_date) >= ? ",
         'closed', previous_month.month, previous_month.year
      )
      #automatically approve not approved periods
      periods.each do |p|
          p.reminder_status = 'agent_reminded'
          p.save
          MailSender.send_reminder_to_agent(p)
      end
    end
  end

  # On the 1st of each month send reminder to drivers
  # about unclosed periods

  def self.send_driver_first_reminder(company_id)
        previous_month = self.current_date-1.month
        previous_month = previous_month.change(day: 20)
        periods = Period.eager_load(:user).where(
            "periods.status <> 'closed' AND DATE(start_date) <= ? AND DATE(start_date) >= ? AND users.company_id = ? AND users.active = TRUE",
             previous_month, previous_month - 1.month, company_id
        )
     
        periods.each do |p|
            if p.user.can("work as driver")
                puts p.user.email + " " + p.start_date.to_s + " " + p.status
                MailSender.send_email_on_new_month(p)
            end
        end
  end

  def self.send_driver_second_reminder(company_id)
      previous_month = self.current_date-1.month
      previous_month = previous_month.change(day: 20)
      periods = Period.eager_load(:user).where(
          "periods.status <> 'closed' AND DATE(start_date) <= ? AND DATE(start_date) >= ? AND users.company_id = ? AND users.active = TRUE",
           previous_month, previous_month - 1.month, company_id
      )
    
      periods.each do |p|
          if p.user.can("work as driver")
              MailSender.send_email_about_unclosed_period(p)
          end
      end
  end

  def self.send_driver_final_reminder(company_id)
      previous_month = self.current_date-1.month
      previous_month = previous_month.change(day: 20)
      periods = Period.eager_load(:user).where(
          "periods.status <> 'closed' AND DATE(start_date) <= ? AND DATE(start_date) >= ? AND users.company_id = ? AND users.active = TRUE",
           previous_month, previous_month - 1.month, company_id
      )
    
      periods.each do |p|
          if p.user.can("work as driver")
              MailSender.send_final_reminder(p)
          end
      end
  end

  
  ### 
  # On 10th of each month we generate summary of periods and send to Payroll 
  #
  # Generate month summary of all periods started in last month. Algorithm:
  #
  # 1) Fetch all periods which belongs to company. Period has user -> user has company
  # 2) Iterate through all periods and produce spreadsheet
  # 3) Send spreadsheet through email (for now to one of ours)
  #
  # @param Company company
  #
  # @return void - result is a spreadsheet generate and save on disk 
  #
  def self.generate_month_summary(company)
    # Spreadsheet should contain following columns
    # Driver fullname, period start date, period end date, period start mileage
    # period end mileage, business mileage, private mileage, total mileage

  #  if self.current_date.day == 10
  #     previous_month = self.current_date - 1.month
  #
  #      #Fetch all the users from the company
  #       users = User.where('company_id = ?', company.id)
  #
  #       if (users.nil?)
  #        raise 'No users associated with company'
  #       end
  #
  # #Fetch all the periods
  #       periods = Period.joins(:user).where('users.company_id = 2')
  #
  # #raise periods.to_json
  #
  #        if (periods.nil?)
  #           raise 'No periods for spreadsheet in end of month process'
  #        end
  #
  # #Create spreadsheet
  #        Spreadsheet.client_encoding = 'UTF-8'
  #        book = Spreadsheet::Workbook.new
  #        sheet1 = book.create_worksheet :name =>  'monthly_summary'
  #
  #        sheet1.row(0).push 'Full name', 'Period start date','Period end date', 'Period start mileage', 'Period end mileage', 'Business mileage', 'Private mileage', 'Total mileage'
  #
  #        iterator = 1
  #        periods.each do |p|
  #        sheet1.row(iterator).push p.user.first_name + ' '+  p.user.last_name, p.start_date.to_s, p.end_date.to_s, p.start_mileage, p.end_mileage, p.overall_mileage[:business] ,p.overall_mileage[:private], p.overall_mileage[:private]+p.overall_mileage[:business]
  #        iterator+=1
  #     end
  #
  #     book.write 'log/' + sheet1.name + '.xls'
  #
  #
  #
  # #Send spreadsheet
  #     MailSender.send_email_with_monthly_summary(company,sheet1)
  #
  #     end
   end
  # End of self.generate_month
  
end