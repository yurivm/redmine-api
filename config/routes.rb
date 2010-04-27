ActionController::Routing::Routes.draw do |map|
  # GET projects
  map.connect 'api/projects', :controller => :api_projects, :action => :index, :conditions => { :method => :get }

  # query both if you like
  # GET issues
  map.connect "api/issues", :controller => :api_issues, :action => :index, :conditions => { :method => :get }
  map.connect "api/issues/:project_id", :controller => :api_issues, :action => :index, :conditions => { :method => :get } 

  # POST a new timelog entry
  map.connect "api/timelog/", :controller => :api_timelog, :action => :new, :conditions => {:method => :post}
  map.connect "api/timelog/:issue_id", :controller => :api_timelog, :action => :new, :conditions => {:method => :post}

  # GET activities for a project
  map.connect "api/activities/:project_id", :controller => :api_activities, :action => :index, :conditions => { :method => :get }

  # GET versions for a project
  map.connect "api/versions/:project_id", :controller => :api_versions, :action => :index, :conditions => {:method => :get}

end