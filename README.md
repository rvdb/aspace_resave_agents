# Description
This plugin triggers a bulk resave operation for all agent records in an ArchivesSpace database. This happens at startup, during the backend initialization step. Depending on the database size, it may take a while, but start and end are logged as follows:
* `resave_agents start: [start time]`
* `resave_agents complete: [end time]`

# Steps to resave agents
1. Clone this plugin
1. Include this `aspace_resave_agents` plugin with other  active plugins in the `AppConfig[:plugins]` section of the `config\config.rb` file  
This is **important**, since the resave action needs access to all modifications in the current data model.
1. Start ArchivesSpace
1. Wait until ArchivesSpace has fully restarted  
This is **important**, since the changes are only stored after the backend `plugin_init` step (which triggers the resave operation) has fully completed.
1. (Check results)
1. Stop ArchivesSpace
1. Remove the `aspace_resave_agents` from the `AppConfig[:plugins]` section of the `config\config.rb` file 
1. Restart ArchivesSpace