# To do list with draggable items

Proof of concept implementation of simple todo list with draggable items.

### Description

This is a simple Elm application allowing to add items to a todo list and reorder them
by dragging them over other items and dropping.

Items are saved in the browser's local storage. Saving and fetching stuff is implemented as separate module to easily replace storage facility with something else.

[Demo on Heroku] (https://elm-todolist-dnd.herokuapp.com)

### Requirements

* Elm 0.17.1-0.18.0

### Development

```
npm run dev
```

Application will be accessible at http://localhost:8080. Code changes will be automatically reloaded.

### Production

```
npm run build
```

Check then the `dist` folder.

### Credits

Fred Yankowski, for [localstorage](https://github.com/fredcy/localstorage)

Peter Morawiec, for [elm-webpack-starter](https://github.com/moarwick/elm-webpack-starter).

### License

MIT