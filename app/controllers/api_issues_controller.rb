class ApiIssuesController < ApiController

  unloadable
  #find a project before its issues
  before_filter :find_project, :only => :index

  helper :sort
  include SortHelper

  def index
    build_query
    sort_clear

    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update({'id' => "#{Issue.table_name}.id"}.merge(@query.available_columns.inject({}) {|h, c| h[c.name.to_s] = c.sortable; h}))

    if @query.valid?
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                              :order => sort_clause)
      respond_to do |format|
        format.html {

        render :xml => @issues.to_xml
        }
        format.xml {

        render :xml => @issues.to_xml
        }
        format.json {

         render :json => @issues.to_json
      }
      end
    else
      # Send html if the query is not valid
      render(:template => 'issues/index.rhtml', :layout => !request.xhr?)
    end
  rescue ActiveRecord::RecordNotFound
    render_404

  end


  protected

   #build issue search query
   def build_query
    if !params[:query_id].blank?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = Query.find(params[:query_id], :conditions => cond)
      @query.project = @project
      session[:query] = {:id => @query.id, :project_id => @query.project_id}
      sort_clear
    else
      if params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
        # Give it a name, required to be valid
        @query = Query.new(:name => "_")
        @query.project = @project
        if params[:fields] and params[:fields].is_a? Array
          params[:fields].each do |field|
            @query.add_filter(field, params[:operators][field], params[:values][field])
          end
        else
          @query.available_filters.keys.each do |field|
            @query.add_short_filter(field, params[field]) if params[field]
          end
        end
        @query.group_by = params[:group_by]
        @query.column_names = params[:query] && params[:query][:column_names]
        session[:query] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
      else
        @query = Query.find_by_id(session[:query][:id]) if session[:query][:id]
        @query ||= Query.new(:name => "_", :project => @project, :filters => session[:query][:filters], :group_by => session[:query][:group_by], :column_names => session[:query][:column_names])
        @query.project = @project
      end
    end
   end


end
