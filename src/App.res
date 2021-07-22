let s = React.string

@send external focus: Dom.element => unit = "focus"
@val external requestAnimationFrame: (unit => unit) => unit = "requestAnimationFrame"

let cs = arr =>
  arr->Js.Array2.filter(((_, b)) => b)->Js.Array2.map(((c, _)) => c)->Js.Array2.joinWith(" ")

let pluralize = (word, quantity) =>
  switch quantity {
  | 1 => word
  | _ => word ++ "s"
  }

type todoItem = {
  text: string,
  completed: bool,
  id: int,
}

type filter = All | Completed | Active

let useFilter = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.hash {
  | "/active" => Active
  | "/completed" => Completed
  | _ => All
  }
}

let onEnter = (cb, evt: ReactEvent.Keyboard.t) => {
  let enterKeycode = 13
  if ReactEvent.Keyboard.keyCode(evt) == enterKeycode {
    cb()
  }
}

module Header = {
  @react.component
  let make = (~onSubmit) => {
    let (value, setValue) = React.useState(() => "")

    let onInput = (evt: ReactEvent.Form.t) => setValue(_ => ReactEvent.Form.target(evt)["value"])

    let onKeyDown = onEnter(() =>
      if String.trim(value) != "" {
        onSubmit(value)
        setValue(_ => "")
      }
    )

    <header className="header">
      <h1> {s("todos")} </h1>
      <input
        value={value}
        onKeyDown
        onInput
        className="new-todo"
        placeholder="What needs to be done?"
        autoFocus=true
      />
    </header>
  }
}

module Footer = {
  @react.component
  let make = () =>
    <footer className="info">
      <p> {s("Double-click to edit a todo")} </p>
      /* Remove the below line ↓ */
      <p> {s("Template by")} <a href="http://sindresorhus.com"> {s("Sindre Sorhus")} </a> </p>
      /* Change this out with your name and url ↓ */
      <p> {s("Created by")} <a href="http://todomvc.com"> {s("you")} </a> </p>
      <p> {s("Part of")} <a href="http://todomvc.com"> {s("TodoMVC")} </a> </p>
    </footer>
}

@react.component
let default = () => {
  let (todos, setTodos) = React.useState(() => [])
  let filter = useFilter()
  let (editingTodo, setEditingTodo) = React.useState(() => None)

  let onTodoSubmit = text =>
    setTodos(_ => {
      let maxId = todos->Js.Array2.map(todo => todo.id)->Js.Array2.reduce(Js.Math.max_int, -1)
      Js.Array.concat([{text: text, completed: false, id: maxId + 1}], todos)
    })

  let onToggleTodo = (target, _) =>
    setTodos(_ =>
      todos->Js.Array2.map(todo =>
        if target.id != todo.id {
          todo
        } else {
          {...todo, completed: !todo.completed}
        }
      )
    )

  let onRemoveTodo = (target, _) =>
    setTodos(_ => todos->Js.Array2.filter(todo => target.id != todo.id))

  let (completedItems, activeItems) = todos->Belt.Array.partition(todo => todo.completed)

  let allCompleted = switch activeItems {
  | [] => true
  | _ => false
  }

  let onClearCompleted = _ => setTodos(_ => activeItems)

  let onToggleAll = _ =>
    setTodos(_ =>
      todos->Js.Array2.map(todo => {
        ...todo,
        completed: !allCompleted,
      })
    )

  let visibleItems = switch filter {
  | All => todos
  | Completed => completedItems
  | Active => activeItems
  }

  let activeItemsCount = activeItems->Js.Array2.length

  let editingTodoRef = React.useRef(Js.Nullable.null)
  let refCallbackEditInput = (element: Js.nullable<Dom.element>) => {
    editingTodoRef.current = element
  }

  let focusRef = () => {
    switch editingTodoRef.current->Js.Nullable.toOption {
    | None => ()
    | Some(element) => focus(element)
    }
  }

  let onClickedEditTodo = (todo, _) => {
    setEditingTodo(_ => Some(todo.id, todo.text))
    requestAnimationFrame(focusRef)
  }

  let onEditTodo = (evt: ReactEvent.Form.t) =>
    setEditingTodo(_ =>
      editingTodo->Belt.Option.map(((id, _)) => {
        let newValue = ReactEvent.Form.target(evt)["value"]
        (id, newValue)
      })
    )

  let onEditBlur = _ => setEditingTodo(_ => None)

  let onEditKeydown = onEnter(() =>
    switch editingTodo {
    | None => ()
    | Some((id, value)) => {
        setEditingTodo(_ => None)
        setTodos(_ =>
          todos->Js.Array2.map(todo =>
            if todo.id != id {
              todo
            } else {
              {...todo, text: value}
            }
          )
        )
      }
    }
  )

  <>
    <section className="todoapp">
      <Header onSubmit=onTodoSubmit />
      {switch todos {
      | [] => React.null
      | _ =>
        <section className="main">
          <input
            onChange=onToggleAll
            checked=allCompleted
            id="toggle-all"
            className="toggle-all"
            type_="checkbox"
          />
          <label htmlFor="toggle-all"> {s("Mark all as complete")} </label>
          <ul className="todo-list">
            {visibleItems
            ->Js.Array2.map(todo =>
              <li
                key={Belt.Int.toString(todo.id)}
                className={cs([
                  ("completed", todo.completed),
                  (
                    "editing",
                    switch editingTodo {
                    | None => false
                    | Some((id, _)) => todo.id == id
                    },
                  ),
                ])}>
                <div className="view">
                  <input
                    className="toggle"
                    type_="checkbox"
                    checked=todo.completed
                    onChange={onToggleTodo(todo)}
                  />
                  <label onDoubleClick={onClickedEditTodo(todo)}> {s(todo.text)} </label>
                  <button onClick={onRemoveTodo(todo)} className="destroy" />
                </div>
                <input
                  ref=?{switch editingTodo {
                  | Some((id, _)) if todo.id == id =>
                    Some(ReactDOM.Ref.callbackDomRef(refCallbackEditInput))
                  | _ => None
                  }}
                  className="edit"
                  value={switch editingTodo {
                  | Some((id, value)) if todo.id == id => value
                  | _ => todo.text
                  }}
                  onBlur={onEditBlur}
                  onInput={onEditTodo}
                  onKeyDown={onEditKeydown}
                />
              </li>
            )
            ->React.array}
          </ul>
        </section>
      }}
      {switch todos {
      | [] => React.null
      | _ => {
          let viewItem = (~label, ~href, ~to_) =>
            <li> <a className={[("selected", to_ == filter)]->cs} href> {s(label)} </a> </li>

          <footer className="footer">
            <span className="todo-count">
              <strong> {activeItemsCount->React.int} </strong>
              {s(" item"->pluralize(activeItemsCount))}
              {s(" left")}
            </span>
            <ul className="filters">
              {viewItem(~to_=All, ~label="All", ~href="#/")}
              {viewItem(~to_=Active, ~label="Active", ~href="#/active")}
              {viewItem(~to_=Completed, ~label="Completed", ~href="#/completed")}
            </ul>
            {switch completedItems {
            | [] => React.null
            | _ =>
              <button onClick={onClearCompleted} className="clear-completed">
                {s("Clear completed")}
              </button>
            }}
          </footer>
        }
      }}
    </section>
    <Footer />
  </>
}
