# this is the actual API
# Beware. using ApplicationController as your parent will invoke authentication.
class ApiController < ApplicationController

  unloadable
  #EVIL
  skip_before_filter :check_if_login_required

  #AUTHENTICATE BY KEY AND SHUT UP
  before_filter :key_check
  before_filter :authenticate_by_key

  #find a project before its timelogs
  before_filter :find_project_timelog, :only => :timelog

  def timelog
  end

  protected

  #sanity check for token
  def key_check
    logger.debug "checking authorization key "
    unauthorized "No authorization key provided. Please pass the API token as GET parameter named 'key'. Example: ?key=abcdef" if params[:key].nil?
    logger.debug "token is " + params[:key] unless params[:key].nil?
  end

  # find user by token
  def authenticate_by_key
    @user = User.find_by_api_key(params[:key])
    if (@user.nil?)
        render :text => "Unable to authenticate using key " + params[:key]
    end
    logger.debug "User by token : " + @user.login unless @user.nil?
    # now we can use all the candy from Redmine
    User.current = @user
  end

  def unauthorized(message = nil)
    message = message || "Unauthorized"
    respond_to do |format|
      format.xml { head :unauthorized }
      format.json { head :unauthorized }
      format.html { render :text => message}
    end
  end

  # required by both api_issues and api_activities controllers
  #find a project before you start searching for issues
  def find_project
    if (params[:project_id].blank?)
      # no project ID specified
      unauthorized "You cannot access issues without specifying project ID"
    else
      @project = Project.find(params[:project_id])
      allowed = User.current.allowed_to?({:controller => 'issues', :action => 'index'}, @project, :global => true)
      unauthorized "You do not have permissions to access this project" unless allowed
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end


end