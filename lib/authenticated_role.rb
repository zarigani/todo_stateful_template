# 権限(role)によるアクセス制限を行う
module AuthenticatedRole
  protected
    # ログインしていないことを要求して、ログインしていたらpermission_deniedを処理する
    def not_logged_in_required
      !logged_in? || permission_denied(_("An account is logged in now. Please logout at once."))
    end

    # ログイン中のユーザーが、引数で指定された権限(role)を持っているか判定する
    # - check_administrator_roleから呼び出される
    # - もし新たな権限「system」を追加したとしたら、それをチェックする以下のメソッド定義も必要になる
    #     def check_sytem_role
    #       check_role('system')
    #     end
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

    # リンク元URLを記録する
    # request.env["HTTP_REFERER"]には、リンクをクリックして移動した時のみ記録される
    def store_referer
      session[:refer_to] = request.env["HTTP_REFERER"]
    end

    # request.env["HTTP_REFERER"]に記録されないリンクも記録する（URLを手入力した場合）
    # app/controllers/application.rbで以下のように呼び出して記録する
    #   after_filter :store_last
    def store_last
      if logged_in? && controller_name != 'sessions'
        flash[:last_to] = request.request_uri
      end
    end

    # リンク元URLが記録されていたら、そこへリダイレクト
    # リンク元URLが記録されていない場合は、引数defaultのURLへリダイレクト
    def redirect_to_referer_or_default(default)
      redirect_to(session[:refer_to] || default)
      session[:refer_to] = nil
    end

    # store_lastによって記録されたURLが残っていたら、そこへリダイレクト
    # URLが記録されていない場合は、引数defaultのURLへリダイレクト
    # - permission_deniedから呼び出される
    # - アクセス権がない場合に、無条件にアプリケーションルートURLにリダイレクトするのではなく、
    # - 可能な限り現在のページを再読み込みして警告のメッセージを表示しようとする
    def redirect_last_or_default(default)
      redirect_to(flash[:last_to] || default)
    end
    
    # 他人のURLにアクセスしようとした場合に、自分のURLにリダイレクトさせる
    # [admin(id = 1)が以下のURLにアクセスした場合...]
    #   http://localhost:3000/users/2
    #   リダイレクトして次のURLへ
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