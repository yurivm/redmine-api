require 'redmine'

Redmine::Plugin.register :redmine_api do
  name 'Redmine Api plugin'
  author 'Yuri Veremeyenko / PI'
  description 'provides REST-like API for projects and issues'
  version '0.0.1'
end
