require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].execute("pragma table_info('#{table_name}')").map {|row| row["name"]}.compact
  end

  def initialize(options={})
    options.each {|property, value| self.send("#{property}=", value)}
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    self.class.column_names.map {|col_name| "'#{send(col_name)}'" unless send(col_name).nil?}.compact.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end


    def self.find_by(something)
      sql = "SELECT * FROM #{self.table_name} WHERE #{something.keys[0]} LIKE '%#{something.values[0]}%'"
      DB[:conn].execute(sql)
    end

end
