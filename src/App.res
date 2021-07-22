let s = React.string

@react.component
let default = () => {
  <>
    <section className="todoapp">
      <header className="header">
        <h1> {s("todos")} </h1>
        <input className="new-todo" placeholder="What needs to be done?" autoFocus="" />
      </header>
      /* This section should be hidden by default and shown when there are todos */
      <section className="main">
        <input id="toggle-all" className="toggle-all" type_="checkbox" />
        <label htmlFor="toggle-all"> {s("Mark all as complete")} </label>
        <ul className="todo-list">
          /* These are here just to show the structure of the list items */
          /* List items should get the class `editing` when editing and `completed` when marked as completed */
          <li className="completed">
            <div className="view">
              <input className="toggle" type_="checkbox" checked="" />
              <label> {s("Taste JavaScript")} </label>
              <button className="destroy" />
            </div>
            <input className="edit" value="Create a TodoMVC template" />
          </li>
          <li>
            <div className="view">
              <input className="toggle" type_="checkbox" />
              <label> {s("Buy a unicorn")} </label>
              <button className="destroy" />
            </div>
            <input className="edit" value="Rule the web" />
          </li>
        </ul>
      </section>
      /* This footer should be hidden by default and shown when there are todos */
      <footer className="footer">
        /* This should be `0 items left` by default */
        <span className="todo-count"> <strong> {s("0")} </strong> {s("item left")} </span>
        /* Remove this if you don't implement routing */
        <ul className="filters">
          <li> <a className="selected" href="#/"> {s("All")} </a> </li>
          <li> <a href="#/active"> {s("Active")} </a> </li>
          <li> <a href="#/completed"> {s("Completed")} </a> </li>
        </ul>
        /* Hidden if no completed items are left ↓ */
        <button className="clear-completed"> {s("Clear completed")} </button>
      </footer>
    </section>
    <footer className="info">
      <p> {s("Double-click to edit a todo")} </p>
      /* Remove the below line ↓ */
      <p> {s("Template by")} <a href="http://sindresorhus.com"> {s("Sindre Sorhus")} </a> </p>
      /* Change this out with your name and url ↓ */
      <p> {s("Created by")} <a href="http://todomvc.com"> {s("you")} </a> </p>
      <p> {s("Part of")} <a href="http://todomvc.com"> {s("TodoMVC")} </a> </p>
    </footer>
  </>
}
