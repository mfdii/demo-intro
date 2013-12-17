
template "/var/lib/tomcat6/webapps/ROOT/index.html" do
  source "index.html.erb"
  owner "tomcat6"
  group "tomcat6"
  mode 00644
end
