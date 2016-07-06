require 'mail'

options = { :address              => "smtp.office365.com",
            :port                 => 587,
            :domain               => 'smtp.office365.com',
            :user_name            => 'noreply@3reign.com',
            :password             => 'ppr1D3..',
            :authentication       => :login,
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end