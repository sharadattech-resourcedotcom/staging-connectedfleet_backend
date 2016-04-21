require 'mail'

options = { :address              => "smtp.mandrillapp.com",
            :port                 => 587,
            :domain               => 'smtp.mandrillapp.com',
            :user_name            => 'wojciech.b@appsvisio.com',
            :password             => 'mFvf6b2yBC9YKrh-lOiZjg',
            :authentication       => :plain,
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end