module AuthenticatedRole
  protected
    # ログインしていないことを要求して、ログインしていたらpermission_deniedを処理する
    def not_logged_in_required
      !logged_in? || permission_denied(_("An account is logged in now. Please logout at once."))
    end

    def check_role(role)
      unless logged_in? && @current_user.has_role?(role)
        if logged_in?
          permission_denied(_("You don't have permission to complete that action."))
        else
          store_referer
          access_denied
        end
      end
    end

    # そのユーザーがadministrator権限かどうか確認する
    def check_administrator_role
      check_role('administrator')
    end

    # 権限が認めらずアクセスできない場合の処理
    def permission_denied(message)
      respond_to do |format|
        format.html do
          flash.keep(:notice)
          flash[:error] = message
          redirect_last_or_default(root_path)  
        end
        format.any do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "You don't have permission to complete this action.", :status => '401 Unauthorized'
        end
      end
    end

    # リンクもとURLを記録する
    # request.env["HTTP_REFERER"]には、リンクをクリックして移動した時のみ記録される
    def store_referer
      session[:refer_to] = request.env["HTTP_REFERER"]
    end

    # request.env["HTTP_REFERER"]に記録されないリンクも記録する（URLを手入力した場合）
    # after_filter :store_last で呼び出され、記録する
    def store_last
      if logged_in? && controller_name != 'sessions'
        flash[:last_to] = request.request_uri
      end
    end

    def redirect_to_referer_or_default(default)
      redirect_to(session[:refer_to] || default)
      session[:refer_to] = nil
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.  Set an appropriately modified
    #   after_filter :store_location, :only => [:index, :new, :show, :edit]
    # for any controller you want to be bounce-backable.
    def redirect_last_or_default(default)
      redirect_to(flash[:last_to] || default)
    end
    
    # 他人のURLにアクセスしようとした場合に、自分のURLにリダイレクトさせる
    #   adminが以下のURLにアクセスした場合...
    #   http://localhost:3000/users/2
    #   リダイレクトして以下のURLへ
    #   http://localhost:3000/users/1
    def current_user_required
      return unless current_user
      case
      when params[:user_id] && params[:user_id] != current_user.id.to_s
        redirect_to :user_id => current_user.id
      when params[:id]      && params[:id]      != current_user.id.to_s
        redirect_to :id      => current_user.id
      end
    end
end