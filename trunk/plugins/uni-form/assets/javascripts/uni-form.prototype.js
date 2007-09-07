//Prototype script for Uni-Form by Patrick Daether - http://www.ihr-freelancer.de
uniform = {
	settings: {	valid_class    : 'valid',
			   invalid_class  : 'invalid',
			    focused_class  : 'focused',
			    holder_class   : 'ctrlHolder',
			    field_selector : '.uniForm input, .uniForm select, .uniForm textarea'
	},
	// Select form fields and attach them higlighter functionality
	init: function(){
		$$(uniform.settings.field_selector).invoke('observe','focus',uniform.changeFocus);
	},
	// Focus specific control holder
	changeFocus: function(evt){
		$$('.'+uniform.settings.focused_class).invoke('removeClassName',uniform.settings.focused_class);
		$(Event.element(evt)).up('.'+uniform.settings.holder_class).addClassName(uniform.settings.focused_class);
	}
}// Auto set on page load...
Event.observe(window, 'load', uniform.init );