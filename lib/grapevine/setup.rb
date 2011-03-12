# Setup DataMapper
DataMapper.setup(:default, Grapevine::Config.database)
DataMapper.auto_upgrade!
