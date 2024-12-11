# Set default repository to avoid errors with linked_events.
RequestContext.in_global_repo do
  
  start_time = Time.now
  $stderr.puts "=============================================="
  $stderr.puts "resave_agents start: #{start_time}"
  $stderr.puts "=============================================="

  # inspired by https://gist.githubusercontent.com/cfitz/0a2347ee24f13bf9bba2282f6e45fc36/raw/3278174da1c55b8b9187b690bd7dd66f45c133e5/fix_sort_names.rb
  [AgentPerson, AgentCorporateEntity, AgentFamily].each do |agent_class|
    $stderr.puts "Updating ... #{agent_class}  (total: #{agent_class.all.length})"
    # inspired by https://github.com/archivesspace/archivesspace/blob/f912cc42a6607fb0cc4e089cba6f7e97575680ce/backend/app/model/mixins/agent_name_dates.rb
    agent_class.all.each do |agent_obj|
      if agent_class.to_s == "AgentPerson"
        name_class = NamePerson
        agent_names = name_class.where(:agent_person_id => agent_obj.id, :sort_name_auto_generate => 1)
        processor = SortNameProcessor::Person
      elsif agent_class.to_s == "AgentCorporateEntity"
        name_class = NameCorporateEntity
        agent_names = name_class.where(:agent_corporate_entity_id => agent_obj.id, :sort_name_auto_generate => 1)
        processor = SortNameProcessor::CorporateEntity
      elsif agent_class.to_s == "AgentFamily"
        name_class = NameFamily
        agent_names = name_class.where(:agent_family_id => agent_obj.id, :sort_name_auto_generate => 1)
        processor = SortNameProcessor::Family
      end

      # only update names that have sort_name_auto_generate
	    agent_names.each do |name_obj|
        name_json = name_class.to_jsonmodel(name_obj.id)
        if name_obj.is_display_name == 1
          extras = agent_class.to_jsonmodel(agent_obj)
        else
          extras = {}
        end
        sort_name_updated = processor.process(name_json, extras)
        name_obj.update(sort_name: sort_name_updated, system_mtime: Time.now)    
        $stderr.puts "#{Time.now} - #{agent_class} ##{agent_obj.id}, #{name_class} ##{name_obj.id}: #{name_json["sort_name"]} ==> #{sort_name_updated}"
      end

    end
  end

  end_time = Time.now
  $stderr.puts "================================================="
  $stderr.puts "resave_agents complete: #{end_time} "
  $stderr.puts "duration: #{end_time - start_time}"
  $stderr.puts "================================================="

end