module Users::SocialModule

  def create_social
    redirect_url = session[:redirect_url] || root_path
    token = params[:token]
    begin
      profile_info = SocialService.instance.get_profile_info(token)

      @user = User.new
      @user.create_profile

      opts ={}
      opts = {:social_identifiers => [SocialIdentifier.new(:identifier => profile_info['identifier'],
                                                          :provider_name => profile_info['providerName'],
                                                          :profile_info => profile_info.to_json )] }


      User.transaction do
        if @user.signup!(opts)
          SocialService.instance.map(profile_info['identifier'], @user.id)
          later_call_with_info(redirect_url, setup_basic_profile_url(@user.perishable_token))
        else
          later_call_with_error(redirect_url, signup_url, @user.social_identifiers.first)
        end
      end
    rescue RpxService::RpxServerException
      redirect_or_render_with_error(redirect_url, "application.remote_error")
    rescue Exception => e
      log_message_error(e, "Error creating user")
    else
      log_message_info("User '#{@user.id}' has been created sucessfully.")
    end
  end

  def add_social
    redirect_url = params[:redirect_url] || settings_path
    later_call_url = params[:later_call]
    token = params[:token]
    begin
      User.transaction do
        profile_info = SocialService.instance.get_profile_info(token)
        social_id = current_user.add_social_identifier( profile_info['identifier'], profile_info['providerName'], profile_info.to_json )
        account_name = I18n.t("users.social_accounts.providers.#{profile_info['providerName'].downcase}")
        if social_id.save
          SocialService.instance.map(profile_info['identifier'], current_user.id)
          if later_call_url
            later_call_with_info(redirect_url,
                                 later_call_url,
                                 "users.social_accounts.connect.success",
                                 :account => account_name)
          else
            redirect_or_render_with_info(redirect_url,
                                         "users.social_accounts.connect.success",
                                         :account => account_name)
          end
        else
          redirect_or_render_with_error(redirect_url,
                                        "users.social_accounts.connect.failed",
                                        :account => account_name)
        end
      end
    rescue RpxService::RpxServerException
      redirect_or_render_with_error(redirect_url, "application.remote_error")
    rescue RpxService::RpxException => e
      log_message_error(e, "Error calling PRX service")
    rescue Exception => e
      log_message_error(e, "Error adding social account to user")
    else
      log_message_info("User '#{current_user.id}' added a new social account successfully.")
    end
  end

  def remove_social
    @provider = params[:provider]
    begin
      User.transaction do
        if social_id = current_user.has_provider?(@provider)
           social_id.destroy
           SocialService.instance.unmap(social_id.identifier,current_user.id)
           redirect_or_render_with_info(settings_path, "users.social_accounts.disconnect.success",
                    :account => I18n.t("users.social_accounts.providers.#{@provider}")) do |page|
             page.replace @provider, :partial => 'users/social_accounts/connect'
           end
        else
          redirect_or_render_with_error(settings_path, "users.social_accounts.disconnect.failed",
                                        :account => I18n.t("users.social_accounts.providers.#{@provider}"))
        end
      end
    rescue RpxService::RpxServerException
      redirect_or_render_with_error(settings_path, "application.remote_error")
    rescue Exception => e
      log_message_error(e, "Error removing social account to user")
    else
      log_message_info("User '#{current_user.id}' removed the '#{@provider}' social account successfully.")
    end
  end

  def setup_basic_profile
    session[:redirect_url] = request.referer
    @user = User.find_by_perishable_token(params[:activation_code], 1.week)
    @profile_info = JSON.parse(@user.social_identifiers.first.profile_info)
    if @user.nil?
      redirect_or_render_with_error(root_path, "users.activation.messages.no_account")
    elsif @user.active?
      redirect_or_render_with_error(root_path, "users.activation.messages.already_active")
    else
      opts = SocialService.instance.load_basic_profile_options(@profile_info) || {}
      opts.each{|k,v|@user.send("#{k}=",v)}
      render_static_new :template => 'users/users/setup_basic_profile' do |format|
        format.js {render :template => 'users/components/users_form',
                          :locals => {:partial => 'users/users/setup_basic_profile',
                                      :css_class => "basic_profile_box"}}
      end
    end
  end

end