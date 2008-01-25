require 'uni_form'

ActionView::Base.send                 :include, MarcusIrven::UniFormHelper
ActionView::Helpers::InstanceTag.send :include, MarcusIrven::LabeledInstanceTag
ActionView::Helpers::FormBuilder.send :include, MarcusIrven::FormBuilderMethods

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag
#  if html_tag =~ /<(input)[^>]+type=["'](radio|checkbox|hidden|label)/
#    html_tag
#  else
#    "<div class=\"error\">#{html_tag}</div>"
#  end
end
