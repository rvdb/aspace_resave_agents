# Set default repository to avoid errors with linked_events.
RequestContext.in_global_repo do
  
  start_time = Time.now
  $stderr.puts "=============================================="
  $stderr.puts "resave_agents start: #{start_time}"
  $stderr.puts "=============================================="

  # inspired by https://gist.githubusercontent.com/cfitz/0a2347ee24f13bf9bba2282f6e45fc36/raw/3278174da1c55b8b9187b690bd7dd66f45c133e5/fix_sort_names.rb
  [NamePerson, NameCorporateEntity, NameFamily].each do |name_class|
    $stderr.puts "Updating ... #{name_class}  (total: #{name_class.all.length})"
    # inspired by https://github.com/archivesspace/archivesspace/blob/f912cc42a6607fb0cc4e089cba6f7e97575680ce/backend/app/model/mixins/agent_name_dates.rb
    name_class.where(:sort_name_auto_generate => 1).each do |name_obj|
      if name_class.to_s == "NamePerson"
        agent_class = AgentPerson
        agent_id = name_obj.agent_person_id
        processor = SortNameProcessor::Person
      elsif name_class.to_s == "NameCorporateEntity"
        agent_class = AgentCorporateEntity
        agent_id = name_obj.agent_corporate_entity_id
        processor = SortNameProcessor::CorporateEntity
      elsif name_class.to_s == "NameFamily"
        agent_class = AgentFamily
        agent_id = name_obj.agent_family_id
        processor = SortNameProcessor::Family
      end

      # only update names that have sort_name_auto_generate
      name_json = name_class.to_jsonmodel(name_obj)
        if name_obj.is_display_name == 1
          agent_json = agent_class.to_jsonmodel(agent_id)
          extras = agent_json
        else
          extras = {}
        end
        sort_name_updated = processor.process(name_json, extras)
        name_obj.update(sort_name: sort_name_updated, system_mtime: Time.now)    
        $stderr.puts "#{Time.now} - #{agent_class} ##{agent_id}, #{name_class} ##{name_obj.id}: #{name_json["sort_name"]} ==> #{sort_name_updated}"

    end
  end

  end_time = Time.now
  $stderr.puts "================================================="
  $stderr.puts "resave_agents complete: #{end_time} "
  $stderr.puts "duration: #{end_time - start_time}"
  $stderr.puts "================================================="

end