
yaml        = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path('../../auditbook.yml', __FILE__))))
server      = yaml[RACK_ENV.to_s]

AUDITBOOK_URL = server['url']
