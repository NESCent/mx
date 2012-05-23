require 'new_relic/agent/method_tracer'
ChrsController.class_eval do
    include NewRelic::Agent::MethodTracer
    add_method_tracer :list
    add_method_tracer :merge_states
end

MxesController.class_eval do
  include NewRelic::Agent::MethodTracer
  add_method_tracer :list
  add_method_tracer :browse
end


ActiveRecord::Base.class_eval do
  include NewRelic::Agent::MethodTracer
  add_method_tracer :find_by_sql,  'Custom/#{self.class.name}/find_by_sql'
end