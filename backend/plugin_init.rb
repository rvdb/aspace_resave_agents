# Set default repository as context for linked_events. Maybe unnecessary, but this solved an error for the ASpace test data 
RequestContext.open(:repo_id => 1) do

  $stderr.puts "====================="
  $stderr.puts "resave_agents: start"
  $stderr.puts "===================="
  [AgentPerson, AgentCorporateEntity, AgentFamily].each do |klass|
    $stderr.puts "Updating ... #{klass}"
    #$stderr.puts "debug 1. klass.all.length: #{klass.all.length}"
    #$stderr.puts "debug 2. klass.all: #{klass.all}"
    #$stderr.puts "debug 2.1. klass.relationship_dependencies: #{klass.relationship_dependencies}"
    klass.all.each do |obj|
      #$stderr.puts "debug 3. Looping over ... #{obj}"
      # get the jsonmodel
      json = klass.to_jsonmodel(obj)
      #$stderr.puts "debug 4. after klass.to_jsonmodel"
      #$stderr.puts "debug 4.1 json (orig): #{json}"
      # now "update" the record with a copy of its json
      obj.update_from_json(json)
      #$stderr.puts "debug 5. after obj.update_from_json"
      #$stderr.puts "debug 5.1 json (updated): #{json}"
      
      # refresh the object and split it out...
      obj.refresh
      #$stderr.puts "debug 6. after obj.refresh"

      # this works to get the updated string, but is probably way too expensive
      #jsonnew = klass.to_jsonmodel(obj)
      #$stderr.puts "#{obj.id} ==> #{jsonnew.title}"

      #$stderr.puts "#{obj}"
      $stderr.puts "#{obj.id} (original name: #{json.title})"

    end
  end
  $stderr.puts "======================="
  $stderr.puts "resave_agents: complete"
  $stderr.puts "======================="

end