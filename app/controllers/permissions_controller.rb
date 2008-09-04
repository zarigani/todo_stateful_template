class PermissionsController < ApplicationController
   before_filter :check_administrator_role
  
   def index
     @user = User.find(params[:user_id])
     @all_roles = Role.find(:all)
   end
  
   def update
     @user = User.find(params[:user_id])
     @role = Role.find(params[:id])
     if @user.has_role?(@role.name)
       @user.roles.delete(@role)
     else
       @user.roles << @role
     end
     redirect_to :action => 'index'
   end
end