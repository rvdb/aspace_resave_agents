# Set default repository to avoid errors with linked_events.
RequestContext.in_global_repo do

  $stderr.puts "=============================================="
  $stderr.puts "resave_agents start: #{Time.now}"
  $stderr.puts "=============================================="
  [AgentPerson, AgentCorporateEntity, AgentFamily].each do |klass|
    $stderr.puts "Updating ... #{klass}"
    klass.all.each do |obj|
      # get the jsonmodel
      json = klass.to_jsonmodel(obj)

      # now "update" the record with a copy of its json
      obj.update_from_json(json)
      
      # refresh the object and split it out...
      obj.refresh

      $stderr.puts "#{obj.id}: #{json.title} ==> #{klass.to_jsonmodel(obj).title}"

    end
  end
  $stderr.puts "================================================="
  $stderr.puts "resave_agents complete: #{Time.now}"
  $stderr.puts "================================================="

end