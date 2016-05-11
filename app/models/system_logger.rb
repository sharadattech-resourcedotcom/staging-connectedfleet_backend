class SystemLogger < ActiveRecord::Base
  EVENT_TYPES = {'PERIOD_UPDATE' => 'PERIOD_UPDATE', 'PERIOD_CLOSED' => 'PERIOD_CLOSED',
                 'TRIP_UPDATED' => 'TRIP_UPDATED', 'PERIOD_APPROVED' => 'PERIOD_APPROVED',
                 'USER_SIGNED_IN' => 'USER_SIGNED_IN'}
end
