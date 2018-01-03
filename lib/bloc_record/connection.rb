require 'sqlite3'
require 'pg'

module Connection
  def connection
    if BlocRecord.platform == 'pg'
      @connection ||= PG::Connection.new(:dbname => BlocRecord.database_filename)
    else
      @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
    end
  end
end
