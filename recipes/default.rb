cookbook_file '/etc/yum.repos.d/thoughtworks-go.repo' do
  source 'thoughtworks-go.repo'
end


group 'go'

user 'go' do
  supports :manage_home => true
  gid 'go'
end


{ 'java-1.7.0-openjdk-devel' => '1.7.0.85-2.6.1.3.el6_6',
  'go-server' => '15.2.0-2248', 
  'go-agent' => '15.2.0-2248' }.each do |package_name, version|
  package package_name do
    version version
  end
end


['go-server', 'go-agent'].each do |service_name|
  service service_name do
    action [:start, :enable]
  end

  template "/etc/default/#{service_name}" do
    source "#{service_name}.erb" 
    owner 'go'
    group 'go'
    notifies :restart, "service[#{service_name}]"
  end
end

if node['go']['autoregister'] == true 
    # then the pipeline config is taken over by chef. Any manual chnangs will be lost
  template '/etc/go/cruise-config.xml' do
    source 'cruise-config.xml.erb'
    owner 'go'
    group 'go'
    notifies :restart, "service[go-server]"
    action :create 
  end

  directory '/var/lib/go-agent/config' do
    owner 'go'
    group 'go'
  end

  template "/var/lib/go-agent/config/autoregister.properties" do
    source 'autoregister.properties.erb'
    mode '0644'
    group 'go'
    owner 'go'
    notifies :restart, "service[go-agent]"
  end
end
