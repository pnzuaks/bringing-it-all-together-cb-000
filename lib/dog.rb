require "pry"
require "pry-nav"


class Dog
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :breed => "TEXT",
  }

  ATTRIBUTES.keys.each do |key|
    attr_accessor key
  end

  def initialize(name:, breed:, id:nil)
    @id= id
    @name = name
    @breed = breed
  end

  def self.create_table()
    sql = <<-SQL
    CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
  )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table()
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save()
    if self.id
        self.update
      else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
  end

  # def self.create(attributes_hash)
  #   self.new.tap do |d|
  #     attributes_hash.each do |att_name, att_value|
  #       d.send("#{att_name}=", att_value)
  #     end
  #     d.save()
  #   end
  # end
  def self.create(name: name, breed: breed)
  dog = Dog.new(name: name, breed: breed)
  dog.save()
  end

  def self.new_from_db(row)
    new_dog = self.new(row[1], row[2], row[0])
    new_dog
  end

  def self.find_by_id(name)
   sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE name = ?
     LIMIT 1
   SQL

    found = DB[:conn].execute(sql,name)
    new_dog_obj = self.new_from_db(found[0])
    puts new_dog_obj
 end

 def self.find_or_create_by(name:, breed:)
     doggy = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
     if !doggy.empty?
       doggy_data = doggy[0]
       dog = Dog.new(doggy_data[0], doggy_data[1], doggy_data[2])
     else
       dog = self.create(name: name, breed: breed)
     end
     dog
  end

 def update()
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end
end
