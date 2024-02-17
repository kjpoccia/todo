require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: "todos")
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)

    tuple = result.first

    list_id = tuple["id"].to_i
    todos = find_todos_for_list(list_id)
    { id: list_id, name: tuple["name"], todos: todos }
  end

  def all_lists
    sql = "SELECT * FROM lists"
    result = query(sql)

    result.map do |tuple|
      list_id = tuple["id"]
      todos = find_todos_for_list(list_id)

      {id: list_id, name: tuple["name"], todos: todos}
    end
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    query(sql, list_name)
  end

  def delete_list(id)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, id)
  end

  def update_list_name(id, name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    query(sql, name, id)
  end

  def create_new_todo(id, text)
    sql = "INSERT INTO todos (name, list_id) VALUES ($1, $2)"
    query(sql, text, id)
  end

  def delete_todo(id, todo_id)
    sql = "DELETE FROM todos WHERE list_id = $1 AND id = $2"
    query(sql, id, todo_id)
  end

  def update_todo_status(id, todo_id, status)
    sql = "UPDATE todos SET completed = $1 WHERE list_id = $2 AND id = $3"
    query(sql, status, id, todo_id)
  end

  def mark_all_complete(id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, id)
  end

  def success(message)
    # @session[:success] = message
  end

  def error(message)
    # @session[:error] = message
  end

  private

  def find_todos_for_list(list_id)
    todo_sql = "SELECT * FROM todos WHERE list_id = $1"
    todo_result = query(todo_sql, list_id)

    todo_result.map do |todo_tuple|
      { id: todo_tuple["id"].to_i, 
        name: todo_tuple["name"], 
        completed: todo_tuple["completed"] == "t"
      }
    end
  end

end