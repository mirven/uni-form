module UniForm #:nodoc:
  module UniFormHelper
    [:form_for, :fields_for, :form_remote_for, :remote_form_for].each do |meth|
      src = <<-end_src
        def uni_#{meth}(object_name, *args, &proc)
          options = args.extract_options!
          html_options = options.has_key?(:html) ? options[:html] : {}
          if html_options.has_key?(:class) 
            html_options[:class] << ' uniForm'
          else
            html_options[:class] = 'uniForm'
          end
          options.update(:html => html_options)
          options.update(:builder => UniFormBuilder)
          #{meth}(object_name, *(args << options), &proc)
        end
      end_src
      module_eval src, __FILE__, __LINE__
    end
        

    # Returns a label tag that points to a specified attribute (identified by +method+) on an object assigned to a template
    # (identified by +object+).  Additional options on the input tag can be passed as a hash with +options+.  An alternate
    # text label can be passed as a 'text' key to +options+.
    # Example (call, result).
    #   label_for('post', 'category')
    #     <label for="post_category">Category</label>
    # 
    #   label_for('post', 'category', 'text' => 'This Category')
    #     <label for="post_category">This Category</label>
    def label_for(object_name, method, options = {})
      # puts "----text: " + options[:text] if options[:text]
      # puts "----del: " + options.delete(:text) if options[:text]
      # puts "---or:" + ((options.delete('text') || method.to_s.humanize)
      label = options[:text] ? options[:text] : method.to_s.humanize
      options.delete(:text)
      ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object)).to_label_tag2(label, options)
      # ActionView::Helpers::InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_label_tag2(options[:text] ? options.delete('text') : method.to_s.humanize, options)
    end

    # Creates a label tag.
    #   label_tag('post_title', 'Title')
    #     <label for="post_title">Title</label>
   # def label_tag(name, text, options = {})
   #   content_tag('label', text, { 'for' => name }.merge(options.stringify_keys))
   # end
  end

  module LabeledInstanceTag #:nodoc:
    # def to_label_tag(options = {})
    def to_label_tag2(text = nil, options = {})
      options = options.stringify_keys
      add_default_name_and_id(options)
      options.delete('name')
      options['for'] = options.delete('id')
      # content_tag 'label', (options.delete('required') ? "<em>*</em> " : "") + ((options.delete('text') || @method_name.humanize)), options
      content_tag 'label', (options.delete('required') ? "<em>*</em> ".html_safe : "") + text, options
    end
  end

  module FormBuilderMethods #:nodoc:
    def label_for(method, options = {})
      @template.label_for(@object_name, method, options.merge(:object => @object))
    end
  end

  class UniFormBuilder < ActionView::Helpers::FormBuilder #:nodoc:
    (%w(date_select) + ActionView::Helpers::FormHelper.instance_methods - %w(label_for hidden_field form_for fields_for)).each do |selector|
      
        field_classname =
          case selector
            when "text_field" then "textInput"
            when "password_field" then "textInput"
            when "file_upload" then "fileUpload"
            else ""
          end
          
        label_classname =
          case selector
            when "check_box", "radio_button" then "inlineLabel"
            else ""
          end
          
          
        src = <<-end_src
          def #{selector}(method, options = {})
            RAILS_DEFAULT_LOGGER.debug options.to_yaml
            
            label_options = {}
            label_classname = "#{label_classname}"
            label_options.update(:class => label_classname) if not label_classname.blank?
            
            if options.has_key?(:class) 
              field_classnames = [ '#{field_classname}', options[:class] ].join(" ")
              RAILS_DEFAULT_LOGGER.debug options[:class]
            else
              field_classnames = '#{field_classname}'
            end
            
            render_field(method, options, super(method, clean_options(options.merge(:class => field_classnames))), label_options)            
          end
        end_src
        class_eval src, __FILE__, __LINE__
    end
    
    def submit(value = "Save changes", options = {})
      options.stringify_keys!
      if disable_with = options.delete("disable_with")
        options["onclick"] = "this.disabled=true;this.value='#{disable_with}';this.form.submit();#{options["onclick"]}"
      end

      @template.content_tag :div, 
        @template.content_tag(:button, value, { "type" => "submit", "name" => "commit", :class => "submitButton primaryAction"}.update(options.stringify_keys)), 
        :class => "buttonHolder"
    end
    
    # renders multiple checkboxes, one per field, inside an organized list
    def check_boxes(methods, options)

      ctrl_group do
        divContent = ""
        divContent << @template.content_tag('p', options[:label], :class => 'label') if options[:label]
        
        checkboxes = []
        methods.collect do |m| 
          checkboxes << @template.content_tag(:li, @template.content_tag(:label, "#{check_box(m[0], :supress_label => true)} #{m[1]}".html_safe))
        end
        
        divContent << @template.content_tag(:ul, checkboxes.join.html_safe, :class => "blockLabels")
        divContent << @template.content_tag('p', options[:hint], :class => 'formHint') if options[:hint]

        divContent.html_safe
      end
    end
    
    def radio_button(method, tag_value, options = {})
      render_field(method, options, super(method, tag_value, options))
    end
    
    def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
      render_field(method, options, super(method, collection, value_method, text_method, options, html_options.merge(:class => "selectInput")))
    end    
    
    def select(method, choices, options = {}, html_options = {})
      render_field(method, options, super(method, choices, options, html_options))
    end
    
    def country_select(method, priority_countries = nil, options = {}, html_options = {})
      render_field(method, options, super(method, priority_countries, options, html_options))
    end
    
    def time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
      render_field(method, options, super(method, priority_zones, options, html_options))
    end
    
    def hidden_field(method, options={})
      super
    end
    
    def fieldset(*args, &proc)
      raise ArgumentError, "Missing block" unless block_given?
      options = args.last.is_a?(Hash) ? args.pop : {}
      
      #classname = options[:type] == "inline" ? "inlineLabels" : "blockLabels"  
      
      content =  @template.capture(&proc)
      content = @template.content_tag(:legend, options[:legend]) + content if options.has_key? :legend
      
      classname = options[:class]
      classname = "" if classname.nil?
      classname << " " << (options[:type] == ("inline" || :inline) ? "inlineLabels" : "blockLabels")

      options.delete(:legend)
      options.delete(:type)
      
      @template.content_tag(:fieldset, content, options.merge({ :class => classname.strip }))
      
    end

    def ctrl_group(&proc)
      raise ArgumentError, "Missing block" unless block_given?
      
      @ctrl_group = true
      content = @template.capture(&proc)
      @template.concat(@template.content_tag(:div, content, :class => "ctrlHolder"))      
      @ctrl_group = nil
    end
    
    def error_messages(options={})
      obj = @object || @template.instance_variable_get("@#{@object_name}")
      count = obj.errors.count
      unless count.zero?
        html = {}
        [:id, :class].each do |key|
          if options.include?(key)
            value = options[key]
            html[key] = value unless value.blank?
          else
            html[key] = 'errorMsg'
          end
        end
        header_message = "Ooops!"
        error_messages = obj.errors.full_messages.map {|msg| @template.content_tag(:li, msg) }
        @template.content_tag(:div,
          @template.content_tag(options[:header_tag] || :h3, header_message) <<
            @template.content_tag(:ol, error_messages),
          html
        )
      else
        ''
      end
    end
    
    def info_message(options={})
      sym = options[:sym] || :uni_message
      @template.flash[sym] ? @template.content_tag(:h3, @template.flash[sym], :id => "OKMsg") : ''
    end
    
    def messages
       error_messages + info_message
    end
    
    
#    # This is a minorly modified version from actionview
#    # actionpack/lib/action_view/helpers/active_record_helper.rb
#    def uni_error_messages_for(*params)
#      options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
#      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
#      count   = objects.inject(0) {|sum, object| sum + object.errors.count }
#      unless count.zero?
#        html = {}
#        [:id, :class].each do |key|
#          if options.include?(key)
#            value = options[key]
#            html[key] = value unless value.blank?
#          else
#            html[key] = 'errorMsg'
#          end
#        end
#        header_message = "Ooops!"
#        error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }
#        content_tag(:div,
#          content_tag(options[:header_tag] || :h3, header_message) <<
#            content_tag(:p, 'There were problems with the following fields:') <<
#            content_tag(:ul, error_messages),
#          html
#        )
#      else
#        ''
#      end
#    end
#    
    
    private
    
    def render_field(method, options, field_tag, base_label_options = {})
      label_options = { :required => options.delete(:required)}
      label_options.update(base_label_options)
      label_options.update(:text => options.delete(:label)) if options.has_key? :label
      
      hint = options.delete :hint
            
      obj = @object || @template.instance_variable_get("@#{@object_name}")
      errors = obj.errors[method]
      
      divContent = errors.blank? ? "" : @template.content_tag('p', errors.class == Array ? errors.first : errors, :class => "errorField")
      
      wrapperClass = 'ctrlHolder'
      wrapperClass << ' col' if options.delete(:column)
      wrapperClass << options.delete(:ctrl_class) if options.has_key? :ctrl_class
      wrapperClass << ' error' if not errors.blank?
      
      divContent << label_for(method, label_options) unless options[:supress_label]
      divContent << field_tag
      divContent << @template.content_tag('p', hint, :class => 'formHint') if not hint.blank?
            
            
      if @ctrl_group.nil?
        @template.content_tag(options[:ctrl_holder_type] || 'div', divContent.html_safe, :class => wrapperClass)
      else
        divContent.html_safe
      end
    end
    
    def clean_options(options)
      options.reject { |key, value| [:required, :label, :hint, :column, :ctrl_class, :supress_label].include?(key) }
    end
    
  end
end
