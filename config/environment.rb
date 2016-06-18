# Load the rails application
require File.expand_path('../application', __FILE__)

ENV['RAILS_ENV'] = 'production'
#ENV['RAILS_ENV'] = 'development'
ENV['GEM_PATH'] = '/home/euteajudo/.gems'

# Initialize the rails application
GraficaArichComBr::Application.initialize!
