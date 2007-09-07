require 'fileutils'

here = File.dirname(__FILE__)

namespace :uni_form do
	desc "Upgrades prototype and scriptaculous"
	task :upgrade_prototype => :environment do
		scriptaculous = %w{ scriptaculous.js builder.js effects.js dragdrop.js controls.js slider.js }
		scriptaculous.each { |file| FileUtils.cp("#{here}/../assets/scriptaculous-js-1.7.1_beta3/src/#{file}", "#{RAILS_ROOT}/public/javascripts/") }
		FileUtils.cp("#{here}/../assets/scriptaculous-js-1.7.1_beta3/lib/prototype.js", "#{RAILS_ROOT}/public/javascripts/") 
	end

	desc "Installs uni-form javascript and css"
	task :install_assets => :environment do

		FileUtils.cp("#{here}/../assets/javascripts/uni-form.prototype.js", "#{RAILS_ROOT}/public/javascripts/")
		FileUtils.cp("#{here}/../assets/stylesheets/uni-form.css", "#{RAILS_ROOT}/public/stylesheets/")
		FileUtils.cp("#{here}/../assets/stylesheets/uni-form-generic.css", "#{RAILS_ROOT}/public/stylesheets/")
	end
end



  
