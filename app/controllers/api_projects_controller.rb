class ApiProjectsController < ApiController
  unloadable

  #render projects for the current user
  def index
    @projects = Project.visible.find(:all,:order => 'lft')
    respond_to do |format|
      format.html {

        render :xml => @projects.to_xml
      }
      format.xml {

        render :xml => @projects.to_xml
      }
      format.json {
        render :json => @projects.to_json
      }
    end
  end

end
