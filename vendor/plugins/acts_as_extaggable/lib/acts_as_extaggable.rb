module ActiveRecord
  module Acts
    module Extaggable
      def self.included(base)
        base.extend(ClassMethods)
        base.instance_eval do
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        def taggable?
          false
        end
      end
      
      module ClassMethods
        
        def acts_as_extaggable(args = {})
#          args.flatten! if args
#          args.compact! if args
          class_eval do
            has_many :tao_tags, :as => :tao, :dependent => :destroy
            has_many :tags, :through => :tao_tags
            
            alias_method args[:as], :tao_tags if args[:as]
            
            validates_associated :tao_tags
            
          end
          
          class_eval <<-RUBY
            ################################
            ###########   TAGS   ###########
            ################################
          
            # auxiliary method, add an array of strings as tags to the statement_node
            def add_tags(tags, opts = {})
              self.tao_tags << TaoTag.create_for(tags, opts[:language_id], {:tao_id => self.id, 
                                                                            :tao_type => opts[:tao_type] || self.class.name, 
                                                                            :context_id => opts[:context_id] || opts[:context].id})
            end
          
            #auxiliary method, destroys statement tags contained in an array of strings
            def delete_tags(tags, opts = {})
              tao_tags = opts[:context].nil? ? self.tao_tags : self.tao_tags.in_context(opts[:context])
              tao_tags.each do |tao_tag|
                if tags.include?(tao_tag.tag.value)
                    tao_tag.destroy
                end
              end
            end
          
            def get_tags(context)
              self.tao_tags.in_context(context).map{|tao|tao.tag.value}
            end
          
            def taggable?
              true
            end
          RUBY
        end
      end
    end
  end
end