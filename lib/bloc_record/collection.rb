module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def take
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT 1;
      SQL

      init_object_from_row(row)
    end

    def where(*args)
      self.any? ? self.first.class.where(args) : false
    end

    def not(args)
      not_key = args.shift.to_s
      not_value = args
      self.any? ? self.map { |pair| pair.delete_if {|key, value| key == not_key && value == not_value} }.compact : false
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
