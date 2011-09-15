module Badges
  module ModelAuthorization

    def self.included(base)
      base.extend(ClassMethods)
    end
     
    module ClassMethods
      
      @@authorization_checker=nil
            
      # privilege_required 'some privilege name' => [:all, :save, :create, :update, :destroy, :find]
      # privilege_required ['some privilege name', 'another_privilege'] => [:all, :save, :create, :update, :destroy, :find]
      #other options:
      # :on=>:method_name
      def privilege_required(args={})

        options = {}
        [:on, :user].each{|arg| options[arg] = args[arg]}

        args.each do |priv, action|
          actions = (action.is_a?(Array)) ? action : [action]
          actions.each do |a|
            authorization_checker.add_to_required_privileges(:before_create, priv, options)  if [:all, :save, :create].include?(a)
            authorization_checker.add_to_required_privileges(:before_update, priv, options)  if [:all, :save, :update].include?(a)
            authorization_checker.add_to_required_privileges(:before_destroy, priv, options) if [:all, :destroy].include?(a)
            
            # this is some ugly rails 2.x code to do this
            # removing it until it can be brought up to date.
            # 
            # if [:all, :find].include?(a)
            #   protect_find #only do this if we have to, don't like messing with find operations
            #   authorization_checker.add_to_required_privileges(:before_find, priv, options)
            # end
          end
        end

      end
      
      # if this is the first time called, create new authorization checker
      # and assign it to the different callbacks, like an observer kinda
      def authorization_checker
        if @@authorization_checker.nil?
          @@authorization_checker = AuthorizationChecker.new
          [:before_create, :before_update, :before_destroy].each { |callback| self.send(callback, @@authorization_checker)}
        end
        @@authorization_checker
      end
      
      def has_privilege?(privilege, user=nil)
        user ||= current_user || Anonymous.instance
        user.has_privilege?(privilege)
      end

      def current_user
        Badges.thread_current_user
      end

      protected
      
      # def protect_find
      #   unless (singleton_class.respond_to?(:original_find_every))
      #     singleton_class.send :alias_method, :original_find_every, :find_every
      #     singleton_class.send :alias_method, :original_find_by_sql, :find_by_sql
      # 
      #     singleton_class.class_eval do
      #       define_method("find_every") do |options|
      #         authorization_checker.callback_check_model_privilege(:before_find, self)
      #         original_find_every(options)
      #       end
      # 
      #       define_method("find_by_sql") do |sql|
      #         authorization_checker.callback_check_model_privilege(:before_find, self)
      #         original_find_by_sql(sql)
      #       end
      #     end
      #   end
      # end

    end

    module InstanceMethods
      def current_user
        Badges.thread_current_user
      end
    end

    class AuthorizationChecker
      
      attr_accessor :required_privileges
      attr_accessor :options
      
      def initialize
        @required_privileges = {}
        @options = {}
      end
      
      def add_to_required_privileges(action, priv, opts)
        options[action] = (options[action]||{}).merge(opts)
        required_privileges[action]=((required_privileges[action] || []) << priv).flatten.uniq
      end
            
      def callback_check_model_privilege(callback,record)
        required_privileges[callback].each do |p|
          check_model_privilege(p, record, options[callback])
        end
      end

      def check_model_privilege(privilege, record=self, options={})
        # puts "check_model_privilege: #{options.describe}"
        
        user = if options.has_key?(:user) && !options[:user].nil?
          # puts "check_model_privilege: user: #{options[:user]}"
          record.send(options[:user]) if record.respond_to?(options[:user])
        else
          # puts "check_model_privilege: current user: #{current_user}"
          current_user
        end

        user ||= Anonymous.instance

        authorizable = if options.has_key?(:on) && !options[:on].nil?
          # puts "check_model_privilege: authorizable: on: #{options[:on]}"
          record.send(options[:on]) if record.respond_to?(options[:on])
        else
          # puts "check_model_privilege: authorizable: record: #{record}"
          record
        end

        raise SecurityError.new("authorized #{user.inspect} lacks privilege '#{privilege}'.") unless user.has_privilege?(privilege, record)
        true
      end

      # I know, this ain't dry, I'll generate later perhaps
      def before_create(record)
        callback_check_model_privilege(:before_create, record)
      end

      def before_update(record)
        callback_check_model_privilege(:before_update, record)
      end

      def before_destroy(record)
        callback_check_model_privilege(:before_destroy, record)
      end

      # not really a callback for AR, but is as far as this class is concerned
      def before_find(record)
        callback_check_model_privilege(:before_find, record)
      end
      
      def current_user
        Badges.thread_current_user
      end
      
    end
  end
end