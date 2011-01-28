# Setup DataMapper
db = File.expand_path('~/grapevine.db')
DataMapper.setup(:default, "sqlite://#{db}")
DataMapper.auto_upgrade!
