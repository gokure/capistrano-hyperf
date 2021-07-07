# Capistrano::Hyperf

Deploy Hyperf applications with Capistrano 3.x

## Installation

If managing your Capistrano deploy as a ruby project, add this line to your
application's Gemfile:

```ruby
gem 'capistrano', '~> 3.0.0'
gem 'capistrano-hyperf'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install capistrano-hyperf
```

## Usage

Require the module in your `Capfile`:

```ruby
require 'capistrano/hyperf'
```

### Configuration

The gem makes the following configuration variables available (shown with defaults).

```ruby
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
```

### Tasks

The following tasks are added to your deploy automagically when adding
capistrano/hyperf to your deploy.

```ruby
before 'deploy:starting', 'hyperf:resolve_linked_dirs'
before 'deploy:starting', 'hyperf:resolve_acl_paths'
after  'deploy:starting', 'hyperf:ensure_linked_dirs_exist'
after  'deploy:updating', 'hyperf:ensure_acl_paths_exist'
before 'deploy:updated',  'deploy:set_permissions:acl'
before 'deploy:updated',  'hyperf:upload_dotenv_file'
```

#### Task Descriptions

```ruby
# Determine which folders, if any, to use for linked directories.
invoke 'hyperf:resolve_linked_dirs'

# Determine which paths, if any, to have ACL permissions set.
invoke 'hyperf:resolve_acl_paths'

# Ensure that linked dirs exist.
invoke 'hyperf:ensure_linked_dirs_exist'

# Ensure that ACL paths exist.
invoke 'hyperf:ensure_acl_paths_exist'

# Upload dotenv file for release.
invoke 'hyperf:upload_dotenv_file'

# Execute a provided hyperf command.
# Replace :command_name with the command to execute
invoke 'hyperf:run[:command_name]'

# Run the database migrations.
invoke 'hyperf:migrate'

# Rollback the last database migration.
invoke 'hyperf:migrate_rollback'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gokure/capistrano-hyperf.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
