
yaml        = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path('../../parbook.yml', __FILE__))))
server      = yaml[RACK_ENV.to_s]

PARBOOK_URL = server['url']
