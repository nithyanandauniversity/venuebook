Sequel::Model.plugin(:schema)
Sequel::Model.plugin(:json_serializer)
Sequel::Model.raise_on_save_failure = false # Do not throw exceptions on failure
Sequel::Model.db = case Padrino.env
  when :development then Sequel.connect("mysql2://root:@127.0.0.1/venuebook_development", :loggers => [logger], :encoding => "utf8")
  when :production  then Sequel.connect("mysql2://root:1122334Meonly@127.0.0.1/venuebook_production",  :loggers => [logger], :encoding => "utf8", :max_connections => 100)
  when :staging		then Sequel.connect("mysql2://root:1122334Meonly@127.0.0.1/venuebook_staging",  :loggers => [logger], :encoding => "utf8", :max_connections => 100)
  when :test        then Sequel.connect("mysql2://root:@127.0.0.1/venuebook_test",        :loggers => [logger], :encoding => "utf8")
end
Sequel::Model.db.extension(:pagination)
