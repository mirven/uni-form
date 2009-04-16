require 'fileutils'

RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../')

#####################################
# Copy resource files
#####################################

FileUtils.cp( 
  File.join(File.dirname(__FILE__), 'resources', 'public', 'stylesheets', 'uni-form.css'), 
  File.join(RAILS_ROOT, 'public', 'stylesheets'),
  :verbose => true
)

FileUtils.cp( 
  File.join(File.dirname(__FILE__), 'resources', 'public', 'stylesheets', 'uni-form-generic.css'), 
  File.join(RAILS_ROOT, 'public', 'stylesheets'),
  :verbose => true
)

FileUtils.cp(
  File.join(File.dirname(__FILE__), 'resources', 'public', 'javascripts', 'uni-form.prototype.js'),
  File.join(RAILS_ROOT, 'public', 'javascripts'),
  :verbose => true
)

p ''
p '========== Installation of Uni Form is completed =========='
p ''

#####################################
# Show the README text file
#####################################
puts IO.read(File.join(File.dirname(__FILE__), 'README'))

