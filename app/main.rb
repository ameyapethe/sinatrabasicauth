#!/usr/bin/env ruby

require "json"
require "rubygems"
require "net/ldap"
require "sinatra/base"

# Pages that require login. 
# Anything in this class requires user to have an LDAP account in a group
class Api < Sinatra::Base
  # HTTP basic auth
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    ldap_args = {}
    ldap_args[:host] = "ldap.host.com"
    ldap_args[:base] = "DC=somecorp,DC=com"
    ldap_args[:encryption] = :simple_tls
    ldap_args[:port] = 636
    auth = {}
    auth[:username] = "CN=#{username},OU=Users,DC=somecorp,DC=com"
    auth[:password] = password
    auth[:method] = :simple
    ldap_args[:auth] = auth
    ldap = Net::LDAP.new(ldap_args)
    filter = "(&(objectClass=user)(sAMAccountName=#{username}))"
    result = false
    if ldap.bind
      ldap.search(
        :base => "DC=somecorp,DC=com", :filter => filter
      ) do |object|
        result = object.memberof.include?(
          "CN=some_group,OU=Groups,DC=somecorp,DC=cp,"
        )
      end
    end
    result
  end
  # login view to validate login
  get "/login" do
    "Login successful"
  end
end

# Pages that do not require login
class Public < Sinatra::Base
  get "/*" do
    redirect 'https://google.com'
  end
end
