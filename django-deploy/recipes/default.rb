node[:django_deploy].each do |path, config|
  deploy path do
    repo config[:repo]
    revision config[:revision],
    user "www-data"
    group "www-data"
    migrate true
    migration_command "python manage.py syncdb --noinput"
    shallow_clone true
    action :deploy
    restart_command "touch #{config[:wsgi_script]}"
    scm_provider Chef::Provider::Git
  end
end
