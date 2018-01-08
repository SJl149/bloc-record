module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def take
      ids = self.map(&:id)
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT 1;
      SQL

      init_object_from_row(row)
    end

    def where(*args)
      if args.count > 1
        expression = args.shift
        params = args
      else
        case args.first
        when String
          expression = args.first
        when Hash
          expression_hash = BlocRecord::Utility.convert_keys(args.first)
          expression = expression_hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
        end
      end

      sql = <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE #{expression};
      SQL

      rows = connection.execute(sql, params)
      rows_to_array(rows)
    end

    def not(args)
      experession = args.shift
      params = args
      ids = self.map(&:id)
      self.any? ? self.first.class.where(ids, args) : false
    end

    private
    def init_object_from_row(row)
      if row
        data = Hash[columns.zip(row)]
        new(data)
      end
    end

    def rows_to_array(rows)
      collection = BlocRecord::Collection.new
      rows.each { |row| collection << new(Hash[columns.zip(row)]) }
      collection
    end

  end
end
