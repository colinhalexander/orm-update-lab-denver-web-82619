require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade INTEGER
        )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    new_student = Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    student = DB[:conn].execute("SELECT * FROM students WHERE name = ? LIMIT 1", name)
    new_student = student.map { |row| new_from_db(row) }.first
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
          INSERT INTO students (name, grade)
          VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
        UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end