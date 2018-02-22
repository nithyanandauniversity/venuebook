
yaml    = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path('../../secrets.yml', __FILE__))))
secrets = yaml[RACK_ENV.to_s]

SECRET = secrets['secret_key_base']
