# USER ROLES
{ :admin => %w(),
  :editor => %w()
}.each_pair { |role, users| users.each { |user| user.has_role!(role) } }

# TOPIC CATEGORIES
%w(echonomyjam echocracy echo echosocial realprices igf klimaherbsttv).each { |name| Tag.create(:value => name) }


###############
#  ENUM KEYS  #
###############

# LANGUAGES
%w(en de fr pt es).each_with_index do |code, index|
  EnumKey.create(:code => code, :enum_name => "languages", :key => index+1, :description => "language")
end

# LANGUAGE LEVELS
%w(mother_tongue advanced intermediate basic).each_with_index do |code, index|
  EnumKey.create(:code => code, :enum_name => "language_levels", :key => index+1, :description => "language_level")
end

# WEB ADDRESSES
%w(email homepage blog xing linkedin facebook twitter).each_with_index do |code, index|
  EnumKey.create(:code => code, :enum_name => "web_address_types", :key => index+1, :description => "web_address_type")
end
EnumKey.create(:code => 'other', :enum_name => "web_address_types", :key => 99, :description => "web_address_type")

# ORGANISATION TYPES
%w(ngo political scientific trade_union social_business profit_driven_business).each_with_index do |code, index|
  EnumKey.create(:code => code, :enum_name => "organisation_types", :key => index+1, :description => "organisation_type")
end

# TAG CONTEXTS
%w(affection engagement expertise decision_making field_work field_activity topic).each_with_index do |code, index|
  EnumKey.create(:code => code, :enum_name => "tag_contexts", :key => index+1, :description => "tag_context")
end

# VALID CONTEXTS
%w(affection engagement expertise decision_making).each do |code|
  ValidContext.create(:context_id => EnumKey.find_by_code(code).id, :tao_type => 'User' )
end
%w(field_work field_activity).each do |code|
  ValidContext.create(:context => EnumKey.find_by_code(code), :tao_type => 'Organisation' ) #To use when Organisations are set
end
ValidContext.create(:context_id => EnumKey.find_by_code("topic").id, :tao_type => 'StatementNode' )


#################
#  ENUM VALUES  #
#################

# Languages
["English","Englisch","Ingles","Inglês","Inglés"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('en'), :language_id => index+1, :value => value, :context => "")
end
["German","Deutsch","Aleman","Alemão","Alemán"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('de'), :language_id => index+1, :value => value, :context => "")
end
["French","Französisch","Français","Francês","Francés"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('fr'), :language_id => index+1, :value => value, :context => "")
end
["Portuguese","Portugiesisch","Portugais","Português","Portugués"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('pt'), :language_id => index+1, :value => value, :context => "")
end
["Spanish","Spanisch","Espagnol","Espanhol","Español"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('es'), :language_id => index+1, :value => value, :context => "")
end

# Language Levels
["Mother Tongue","Muttersprache","Langue Maternelle","Língua Materna","Lengua Materna"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('mother_tongue'), :language_id => index+1, :value => value, :context=> "")
end
["Advanced","Fortgeschritten","Avancé","Avançado","Avanzado"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('advanced'), :language_id => index+1, :value => value, :context=> "")
end
["Intermediate","Mittelstufe","Intermédiaire","Intermédio","Intermedio"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('intermediate'), :language_id => index+1, :value => value, :context=> "")
end
["Basic","Grundkenntnisse","Basique","Básico","Basico"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('basic'), :language_id => index+1, :value => value, :context=> "")
end

# Web Addresses
EnumKey.languages.length.times do |index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('email'), :language_id => index+1, :value => "E-mail", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('homepage'), :language_id => index+1, :value => "Homepage", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('blog'), :language_id => index+1, :value => "Blog", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('xing'), :language_id => index+1, :value => "Xing", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('linkedin'), :language_id => index+1, :value => "LinkedIn", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('facebook'), :language_id => index+1, :value => "Facebook", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('twitter'), :language_id => index+1, :value => "Twitter", :context=> "")
end
["Other","Andere","Autre","Outro","Otro"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('other'), :language_id => index+1, :value => value, :context=> "")
end

# Organization Types
["NGO","NRO","ONG","ONG","ONG"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('ngo'), :language_id => index+1, :value => value, :context=> "")
end
["Political","Politisch","Politique","Política","Política"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('political'), :language_id => index+1, :value => value, :context=> "")
end
["Scientific","Wissenschaftlich","Scientifique","Científica","Científica"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('scientific'), :language_id => index+1, :value => value, :context=> "")
end
["Trade Union","Gewerkschaft","Syndicat","Sindicato","Sindicato"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('trade_union'), :language_id => index+1, :value => value, :context=> "")
end
["Social Business","Sozialbetrieb","Activité Sociale","Actividade Social","Actividad Social"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('social_business'), :language_id => index+1, :value => value, :context=> "")
end
["Profit-Driven Business","Gewinnorientierte Firma","Firma à but lucratif","Firma com fins lucrativos","Firma de lucro"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('profit_driven_business'), :language_id => index+1, :value => value, :context=> "")
end

# Tag Contexts
["Affection","Betroffenheit","Affection","Afeição","Afecto"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('affection'), :language_id => index+1, :value => value, :context=> "")
end
["Engagement","Engagement","Engagement","Compromisso","Compromisso"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('engagement'), :language_id => index+1, :value => value, :context=> "")
end
["Expertise","Expertise","Expertise","Especialidade","Peritaje"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('expertise'), :language_id => index+1, :value => value, :context=> "")
end
["Decision Making","Entscheidung","Décision","Decisão","Decisión"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('decision_making'), :language_id => index+1, :value => value, :context=> "")
end
["Field of Work","Arbeitsfeld","Domaine de travail","Domínio de Trabalho","Área de Trabajo"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('field_work'), :language_id => index+1, :value => value, :context=> "")
end
["Field of Activity","Betätigungsfeld","Domaine d'activité","Domínio de Actividade","Área de Actividad"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('field_activity'), :language_id => index+1, :value => value, :context=> "")
end
