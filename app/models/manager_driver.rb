class ManagerDriver < ActiveRecord::Base

  belongs_to :manager, :class_name => 'User', :foreign_key => 'manager_id'
  belongs_to :driver, :class_name => 'User', :foreign_key => 'driver_id'

  # Return list of drivers who can be managed
  # by given manager. If manager type is ADMIN
  # return all drivers which are in given company
  def self.manager_drivers(company, manager)
    if manager.role.access_level >= 8
      return User.all_with_permissions(company.id, ["work as driver"])
    else     
      return User.joins(:manager).where('manager_id = ? AND users.active = TRUE', manager.id)
    end
  end

  def self.manager_drivers_ids(company, manager)
    if manager.role.access_level >= 8
      return User.all_with_permissions(company.id, ["work as driver"]).map(&:id)
    else     
      return ManagerDriver.joins(:driver).where('manager_id = ? AND users.active = TRUE', manager.id).pluck(:driver_id)
    end
    return ids
  end

  def self.manager_drivers_hierarchic(company, manager)
       if manager.role.access_level >= 8
        return User.company_drivers(company.id) | User.company_line_managers(company.id)
      else
        drivers_ids = ManagerDriver.ids_in_hierarchy(manager)
        puts drivers_ids
        drivers = User.where("id IN (?) AND active = TRUE", drivers_ids)
        return drivers
      end
  end

  def self.ids_in_hierarchy(manager = nil, drivers_ids = [])
        if !manager.nil?
            drivers_ids = ManagerDriver.where(:manager_id => manager.id).pluck(:driver_id)
            drivers_ids = drivers_ids + ManagerDriver.ids_in_hierarchy(nil, drivers_ids)
        else
            ids = ManagerDriver.where("manager_id IN (?)", drivers_ids).pluck(:driver_id)
            if !ids.empty?
                drivers_ids = ids + ManagerDriver.ids_in_hierarchy(nil, ids)
            end
        end
        return drivers_ids.uniq
    end
  # Get manager for given driver. Return NIL if
  # driver hasn't manager assigned
  def self.driver_manager(driver)
    m = ManagerDriver.where('driver_id = ?', driver.id).take
    m.manager unless m.nil?
  end


  # Change manager for given driver. If that manager
  # is currently assigned to driver do nothing
  def self.change_driver_manager(driver, manager)
    man = self.driver_manager(driver)

    if (man.nil? || man.id != manager.id) && driver.company_id == manager.company_id
      ManagerDriver.create(:driver_id => driver.id, :manager_id => manager.id)
      ManagerDriver.where('driver_id = ? AND manager_id = ?', driver.id, man.id).delete_all unless man.nil?
    end
  end

end