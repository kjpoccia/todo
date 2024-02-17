class SessionPersistence
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end

  def find_list(id)
    @session[:lists].find{ |list| list[:id] == id }
  end

  def all_lists
    @session[:lists]
  end

  def create_new_list(list_name)
    id = next_element_id(@session[:lists])
    @session[:lists] << { id: id, name: list_name, todos: [] }
  end

  def delete_list(id)
    @session[:lists].reject! { |list| list[:id] == id }
  end

  def update_list_name(id, name)
    list = find_list(id)
    list[:name] = name
  end

  def create_new_todo(id, text)
    list = find_list(id)
    todo_id = next_element_id(list[:todos])
    list[:todos] << { id: todo_id, name: text, completed: false }
  end

  def delete_todo(id, todo_id)
    list = find_list(id)
    list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(id, todo_id, status)
    list = find_list(id)
    todo = list[:todos].find { |todo| todo[:id] == todo_id }
    todo[:completed] = status
  end

  def mark_all_complete(id)
    list = find_list(id)
    list[:todos].each do |todo|
      todo[:completed] = true
    end
  end

  def success(message)
    @session[:success] = message
  end

  def error(message)
    @session[:error] = message
  end

  private

  def next_element_id(elements)
    max = elements.map { |todo| todo[:id] }.max || 0
    max + 1
  end

end