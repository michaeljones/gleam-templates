# Matcha 🍵

Generate type-safe Gleam modules from text-based template files.

This project provides a Rust program that parses a basic template format and outputs Gleam modules
with 'render' functions that can be imported and called to render the template with different
parameters.

## Status

Matcha is basic but currently feature complete and well tested. If the repository looks inactive it
is because it is stable.

## Recommended Usage

Template languages like Matcha are useful to have in general and are particularly useful for generating unstructured
text. Matcha generates well typed code that avoids issues that some more dynamic templating systems have.

That said, if you're planning to generate structured output, it is sensible to use a better suited approach. For data
formats, this should be serialization and deserialization libraries. For formats like HTML, you would likely be better
using a library like [lustre](https://hexdocs.pm/lustre/lustre/element.html#to_string_tree) or
[nakai](https://hexdocs.pm/nakai/nakai.html#to_string_tree).

## Installation

Download pre-built binaries for the latest release from the
[Releases](https://github.com/michaeljones/matcha/releases) page.

Build from source with:

```
cargo install --path .
```

## Usage

Run:

```
matcha
```

At the root of your project and it will walk your project folder structure and compile any template
files it finds.

Template files should have a `.matcha` extension. Templates are compiled into `.gleam` files that can
be imported like any other regular module. The modules expose a `render` function, that returns a
`String`, and `render_tree` function that returns a `StringTree`.

Some errors, mostly syntax, will be picked up by the Rust code but it is possible to generate
invalid modules and so the Gleam compiler will pick up further errors.


## Syntax

The syntax is inspired by [Jinja](https://jinja.palletsprojects.com/).

### With

You can use `{>` syntax to add `with` statements to declare parameters and their assoicated types
for the template and the generated render function. All parameters must be declared with `with`
statements.

```
{> with greeting as String
{> with name as String

{{ greeting }}, {{ name }}
```

### String Value

You can use `{{ name }}` syntax to insert the value of `name` into the rendered template.

```jinja
{> with name as String
Hello {{ name }}
```

### StringTree Value

You can use `{[ name ]}` syntax to insert a `StringTree` value into the rendered template. This
has the advantage of using
[string_tree.append_tree](https://hexdocs.pm/gleam_stdlib/gleam/string_tree.html#append_tree)
in the rendered template and so it more efficient for inserting content that is already in a
`StringTree`. This can be used to insert content from another template.

```jinja
{> with name as StringTree
{[ name ]}
```

### If

You can use `{% %}` blocks to create an if-statement using the `if`, `else` and `endif` keywords.
The `else` is optional.

```jinja
{> with is_admin as Bool
{% if is_admin %}Admin{% else %}User{% endif %}
```

### For

You can use `{% %}` blocks to create for-loops using the `for`, `in` and `endfor` keywords.

```html+jinja
{> with list as List(String)
<ul>
{% for entry in list %}
    <li>{{ entry }}</li>
{% endfor %}
</ul>
```

Additionally you can use the `as` keyword to associate a type with the items being iterated over.
This is necessary if you're using a complex object.

```html+jinja
{> import organisation.{type Organisation}
{> import membership.{type Member}
{> with org as Organisation
<ul>
{% for user as Member in organisation.members %}
    <li>{{ user.name }}</li>
{% endfor %}
</ul>
```

### Import

You can use the `{>` syntax to add import statements to the template. These are used to import types
to use with the `with` syntax below to help Gleam check variables used in the template.

```
{> import my_user.{type MyUser}
```

### Functions

You can use the `{> fn ... {> endfn` syntax to add a local function to your template:

```
{> fn full_name(second_name: String)
Lucy {{ second_name }}
{> endfn
```

The function always returns a `StringTree` value so you must use `{[ ... ]}` syntax to insert
them into templates. The function body has its last new line trimmed, so the above function called
as `full_name("Gleam")` would result in `Lucy Gleam` and not `\nLucy Gleam\n` or any other
variation. If you want a trailing new line in the output then add an extra blank line before the `{> endfn`.

The function declaration has no impact on the final template as all lines are removed from the
final text.

Like in normal code, functions make it easier to deal with repeated components within your template.

```
{> fn item(name: String)
<li class="px-2 py-1 font-bold">{{ name }}</li>
{> endfn

<ul>
    {[ item(name: "Alice") ]}
    {[ item(name: "Bob") ]}
    {[ item(name: "Cary") ]}
</ul>
```

You can use the `pub` keyword to declare the function as public in which case other modules will be
able to import it from gleam module compiled from the template.

```
{> pub fn user_item(name: String)
<li class="px-2 py-1 font-bold">{{ name }}</li>
{> endfn
```

If a template only includes function declarations and no meaningful template content then matcha
will not add the `render` and `render_tree`. Instead the module will act as a library of
functions where each function body is a template.

## Output

A template like:

```
{> import my_user.{type User}
{> with user_obj as User
Hello{% if user_obj.is_admin %} Admin{% endif %}
```

is compiled to a Gleam module:

```gleam
import gleam/string_tree.{StringTree}
import gleam/list
import my_user.{User}

pub fn render_tree(user_obj user_obj: User) -> StringTree {
  let tree = string_tree.from_string("")
  let tree = string_tree.append(tree, "Hello")
  let tree = case user_obj.is_admin {
    True -> {
      let tree = string_tree.append(tree, " Admin")
      tree
    }
    False -> tree
  }
  let tree = string_tree.append(tree, "
")

  tree
}

pub fn render(user_obj user_obj: User) -> String {
  string_tree.to_string(render_tree(user_obj: user_obj))
}
```

Which you can import and call `render` or `render_tree` on with the appropriate arguments.

## Tests

Rust tests can be run with `cargo test`. They use [insta](http://insta.rs/) for snapshots.

Gleam tests can be run with `cargo run && gleam test`.
