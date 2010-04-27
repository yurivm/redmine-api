class ApiActivitiesController < ApiController
  unloadable
  #find a project before its issues
  before_filter :find_project, :only => :index

  def index
      respond_to do |format|
        format.html {

        render :xml => @project.activities.to_xml
        }
        format.xml {

        render :xml => @project.activities.to_xml
        }
        format.json {

         render :json => @project.activities.to_json
      }
      end
  end

end
