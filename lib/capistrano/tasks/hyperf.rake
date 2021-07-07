include Comparable

namespace :load do
  task :defaults do
    # Which roles to consider as hyperf roles
    set :hyperf_roles, :all

    # The hyperf flags to include on bin/hyperf.php commands by default
    set :hyperf_run_flags, ""

    # Which roles to use for running migrations
    set :hyperf_migration_roles, :all

    # The hyperf flags to include on commands when running migrations
    set :hyperf_migration_run_flags, "--force"

    # Whether to upload the dotenv file on deploy
    set :hyperf_upload_dotenv_file_on_deploy, true

    # Which dotenv file to transfer to the server
    set :hyperf_dotenv_file, '.env'

    # The user that the server is running under (used for ACLs)
    set :hyperf_server_user, 'www-data'

    # Ensure the dirs in :linked_dirs exist?
    set :hyperf_ensure_linked_dirs_exist, true

    # Link the directores in hyperf_linked_dirs?
    set :hyperf_set_linked_dirs, true

    # Linked directories for a standard hyperf application
    set :hyperf_linked_dirs, [
      'runtime/logs',
    ]

    # Ensure the paths in :file_permissions_paths exist?
    set :hyperf_ensure_acl_paths_exist, true

    # Set ACLs for the paths in hyperf_acl_paths?
    set :hyperf_set_acl_paths, true

    # Paths that should have ACLs set for a standard hyperf application
    set :hyperf_acl_paths, [
      'runtime/logs',
    ]
  end
end

namespace :hyperf do
  desc 'Determine which folders, if any, to use for linked directories.'
  task :resolve_linked_dirs do
    hyperf_linked_dirs = fetch(:hyperf_linked_dirs)
    if fetch(:hyperf_set_linked_dirs)
      set :linked_dirs, fetch(:linked_dirs, []).push(*hyperf_linked_dirs)
    end
  end

  desc 'Determine which paths, if any, to have ACL permissions set.'
  task :resolve_acl_paths do
    next unless fetch(:hyperf_set_acl_paths)
    hyperf_acl_paths = fetch(:hyperf_acl_paths)
    set :file_permissions_paths, fetch(:file_permissions_paths, [])
      .push(*hyperf_acl_paths)
      .uniq
    set :file_permissions_users, fetch(:file_permissions_users, [])
      .push(fetch(:hyperf_server_user))
      .uniq
  end

  desc 'Ensure that linked dirs exist.'
  task :ensure_linked_dirs_exist do
    next unless fetch(:hyperf_ensure_linked_dirs_exist)

    on roles fetch(:hyperf_roles) do
      fetch(:linked_dirs).each do |path|
        within shared_path do
          execute :mkdir, '-p', path
        end
      end
    end
  end

  desc 'Ensure that ACL paths exist.'
  task :ensure_acl_paths_exist do
    next unless fetch(:hyperf_set_acl_paths) &&
                fetch(:hyperf_ensure_acl_paths_exist)

    on roles fetch(:hyperf_roles) do
      fetch(:file_permissions_paths).each do |path|
        within release_path do
          execute :mkdir, '-p', path
        end
      end
    end
  end

  desc 'Upload dotenv file for release.'
  task :upload_dotenv_file do
    next unless fetch(:hyperf_upload_dotenv_file_on_deploy)

    dotenv_file = fetch(:hyperf_dotenv_file)

    run_locally do
      if dotenv_file.empty? || test("[ ! -e #{dotenv_file} ]")
        raise Capistrano::ValidationError,
              "Must prepare dotenv file [#{dotenv_file}] locally before deploy!"
      end
    end

    on roles fetch(:hyperf_roles) do
      upload! dotenv_file, "#{release_path}/.env"
    end
  end

  desc 'Execute a provided hyperf command.'
  task :run, [:command_name] do |_t, args|
    ask(:cmd, 'list') # Ask only runs if argument is not provided
    command = args[:command_name] || fetch(:cmd)

    on roles fetch(:hyperf_roles) do
      within release_path do
        execute :php,
                "bin/hyperf.php",
                command,
                *args.extras,
                fetch(:hyperf_run_flags)
      end
    end

    # Enable task hyperf to be ran more than once
    Rake::Task['hyperf:run'].reenable
  end

  desc 'Run the database migrations.'
  task :migrate do
    hyperf_roles = fetch(:hyperf_roles)
    hyperf_run_flags = fetch(:hyperf_run_flags)

    set(:hyperf_roles, fetch(:hyperf_migration_roles))
    set(:hyperf_run_flags, fetch(:hyperf_migration_run_flags))

    Rake::Task['hyperf:run'].invoke(:migrate)

    set(:hyperf_roles, hyperf_roles)
    set(:hyperf_run_flags, hyperf_run_flags)
  end

  desc 'Rollback the last database migration.'
  task :migrate_rollback do
    hyperf_roles = fetch(:hyperf_roles)
    hyperf_run_flags = fetch(:hyperf_run_flags)

    set(:hyperf_roles, fetch(:hyperf_migration_roles))
    set(:hyperf_run_flags, fetch(:hyperf_migration_run_flags))

    Rake::Task['hyperf:run'].invoke('migrate:rollback')

    set(:hyperf_roles, hyperf_roles)
    set(:hyperf_run_flags, hyperf_run_flags)
  end

  before 'deploy:starting', 'hyperf:resolve_linked_dirs'
  before 'deploy:starting', 'hyperf:resolve_acl_paths'
  after  'deploy:starting', 'hyperf:ensure_linked_dirs_exist'
  after  'deploy:updating', 'hyperf:ensure_acl_paths_exist'
  before 'deploy:updated',  'deploy:set_permissions:acl'
  before 'deploy:updated',  'hyperf:upload_dotenv_file'
end
