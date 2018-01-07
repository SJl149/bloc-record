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

  def exec_query(sql_query)
    if BlocRecord.platform == 'pg'
      self.exec(sql_query)
    else
      self.execute(sql_query)
    end
  end

  def exec_query_params(sql_query, params)
    if BlocRecord.platform == 'pg'
      self.exec_params(sql_query, params)
    else
      self.execute(sql_query, params)
    end
  end
end
