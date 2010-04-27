class ApiTimelogController < ApiController
  unloadable
  #evil evil
  skip_before_filter :verify_authenticity_token, :only => :new

  #find a project before its timelogs
  before_filter :find_project_timelog, :only => :new

  #store a new TimeLog record
  def new
    (unauthorized "you cannot modify this issue"; return) if @time_entry && !@time_entry.editable_by?(User.current)
    @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
    @time_entry.attributes = params[:time_entry]

    call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

    if request.post? and @time_entry.save
      #flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html {

        render :xml => @time_entry.to_xml
        }
        format.xml {

        render :xml => @time_entry.to_xml
        }
        format.json {

         render :json => @time_entry.to_json
      }
      end
    else
      render :text => "Could not save your issue. Did you fill all the details? Did you post this form?"
    end
    
  end

  protected

  #find a project and/or issue if you are up to logging time
  def find_project_timelog
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
      #can you access this project?
      allowed = User.current.allowed_to?({:controller => 'issues', :action => 'index'}, @project, :global => true)
      unauthorized "You do not have permissions to access this project" unless allowed
    else
      unauthorized "You have to provide issue_id as a request parameter. For example, issue_id=1234" unless allowed
      return false
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  

end
