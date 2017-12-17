require 'sqlite3'

module Selection
  def find(*ids)
    if ids.length == 1
      find_one(ids.first)
    else
      if validate_id(ids)
        rows = connection.execute <<-SQL
          SELECT #{columns.join ","} FROM #{table}
          WHERE id IN (#{ids.join ","});
        SQL

        rows_to_array(rows)
      else
        nil
      end
    end
  end

  def find_one(id)
    if validate_id(id)
      row = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id = #{id};
      SQL

      init_object_from_row(row)
    else
      nil
    end
  end

  def find_by(attribute, value)
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    init_object_from_row(row)
  end

  def find_each(options={})
    if block_given?
      find_in_batches(options) do |records|
        records.each { |record| yield record }
      end
    else
      enum_for :find_each, options do
        options[:start] ? where(table[primary_key].gteq(options[:start])).size : size
      end
    end
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{options['batch_size']};
    SQL

    init_object_from_row(row)
  end

  def find_in_batches(options={})
    if assert_valid_keys(options)
      start = options["start"]
      batch_size = options["batch_size"]

      row = batch_query(start, batch_size)
      records = rows_to_array(row)

      while records.any?
        records_size = records.size
        start = start + batch_size + 1

        yield records
        break if records_size < batch_size

        row = batch_query(start, batch_size)
        records = rows_to_array(row)
      end
    end
  end

  def method_missing(method, *args, &block)
    if method.to_s == /^find_by_(.*)$/ && columns.include?(method.to_s)
      find_by(method.to_s, args.first)
    else
      puts "The column #{method.to_s} does not exist."
      return
    end
  end

  def take(num=1)
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table};
    SQL

    rows_to_array(rows)
  end

  private
  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  def rows_to_array(rows)
    rows.map { |row| new(Hash[columns.zip(row)]) }
  end

  def validate_id(*ids)
    ids.each do |id|
      if id < 0 || id.to_i != id
        puts "Invalid id: #{id}."
        false
      end
    end
    true
  end

  def assert_valid_keys(options={})
    options.has_key?("start") && options.has_key?("batch_size")
  end

  def batch_query(start, batch_size)
    connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{batch_size}
      OFFSET #{start};
    SQL
  end

end
