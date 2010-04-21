module UserExtension::Echo
  def self.included(base)
    base.instance_eval do
      has_many :user_echos
      has_many :echos, :through => :user_echos
      has_many :echoed_statements, :through => :user_echos, :source => :statement
      
      include InstanceMethods
    end
  end

  module InstanceMethods
    # creates a new EchoDetail record with the given options or updates an existing EchoDetail if applicable
    def echo!(echoable, options={})
      ed = user_echos.create_or_update!(options.merge(:echo => echoable.find_or_create_echo))
      # OPTIMIZE: update the counters periodically
      ed.echo.update_counter! ; ed
    end
    
    # states that the +user+ visited the given +echoable+
    def visited!(echoable)
      echo!(echoable, :visited => true)
    end
    
    # states that the +user+ supported the given +echoable+
    def supported!(echoable)
      echo!(echoable, :supported => true)
    end
    
    # returns true if the +user+ has visted the given +echoable+
    def visited?(echoable)
      echoable.user_echos.visited.for_user(self.id).any?
    end
    
    # returns true if the +user+ has supported the given +echoable+
    def supported?(echoable)
      echoable.user_echos.supported.for_user(self.id).any?
    end
  end
end

