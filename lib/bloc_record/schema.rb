require 'sqlite3'
require 'pg'
require 'bloc_record/utility'

module Schema
  def table
    BlocRecord::Utility.underscore(name)
  end

  def schema
    @schema = {}
    connection.table_info(table) do |col|
      @schema[col["name"]] = col["type"]
    end
    @schema
  end

  def columns
    schema.keys
  end

  def attributes
    columns - ["id"]
  end

  def count
    connection.execute("SELECT COUNT(*) FROM #{table}")[0][0]
  end
end
