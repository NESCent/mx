# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# -- RAILS 3 above

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
 inflect.plural /^(ontology_class)$/i, '\1es'
 inflect.plural /^(specimen)$/i, '\1s'
 inflect.singular /^(specimen)s/i, '\1'
 inflect.singular /^(ontology_class)es/i, '\1'
 inflect.plural /^(OntologyClass)$/, '\1es'
 inflect.singular /^(OntologyClass)es/, '\1'

 inflect.irregular 'differentia', 'differentiae'
 inflect.irregular 'clave', 'claves'

 #inflect.irregular 'person', 'people'
 #inflect.uncountable %w( fish sheep )
end
