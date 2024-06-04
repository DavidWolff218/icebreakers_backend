require 'yaml'

module Psych
  def self.safe_load_with_aliases(yaml, *args, **kwargs)
    safe_load(yaml, *args, aliases: true, **kwargs)
  end
end

Rails.application.config.database_configuration = YAML.safe_load_with_aliases(ERB.new(File.read(Rails.root.join('config/database.yml'))).result) || {}