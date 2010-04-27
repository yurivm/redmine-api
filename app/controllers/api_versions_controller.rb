class ApiVersionsController < ApiController
  unloadable
  
  before_filter :find_project, :only => :index

  def index
     respond_to do |format|
        format.html {

        render :xml => @project.versions.to_xml
        }
        format.xml {

        render :xml => @project.versions.to_xml
        }
        format.json {

         render :json => @project.versions.to_json
      }
      end
  end

end
