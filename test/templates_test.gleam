import gleam/string_builder

import gleeunit
import gleeunit/should

import template/identifier
import template/two_identifiers
import template/double_identifier_usage
import template/if_statement
import template/if_else_statement
import template/if_comparison
import template/nested_if_statement
import template/for_loop
import template/for_as_loop
import template/for_loop_from_expression
import template/dot_access
import template/multiline
import template/value_in_for_loop
import template/value_in_if_else
import template/value_expression
import template/quote
import template/builder
import template/builder_expression

import my_user.{User, NamedUser}

pub fn main() {
  gleeunit.main()
}

pub fn identifier_test() {
  identifier.render("Gleam")
  |> should.equal("Hello Gleam, good to meet you\n")

  identifier.render("User")
  |> should.equal("Hello User, good to meet you\n")
}

pub fn two_identifiers_test() {
  two_identifiers.render("Gleam", "good")
  |> should.equal("Hello Gleam, good to meet you\n")

  two_identifiers.render("User", "nice")
  |> should.equal("Hello User, nice to meet you\n")
}

pub fn value_expression_test() {
  value_expression.render("Anna")
  |> should.equal("Hello ANNA, good to meet you\n")
}

pub fn double_identifier_usage_test() {
  double_identifier_usage.render("Double")
  |> should.equal("Double usage, Double usage\n")
}

pub fn builder_block_test() {
  let name_builder = string_builder.from_strings(["Anna", " ", "Bandana"])
  builder.render(name_builder)
  |> should.equal("Hello Anna Bandana, good to meet you\n")
}

pub fn builder_expression_test() {
  builder_expression.render()
  |> should.equal("Hello Anna and Bob, good to meet you\n")
}

pub fn if_statement_test() {
  if_statement.render(True)
  |> should.equal("Hello User\n")

  if_statement.render(False)
  |> should.equal("Hello\n")
}

pub fn if_comparison_test() {
  if_comparison.render([])
  |> should.equal("Hello\n")

  if_comparison.render([User(is_admin: True)])
  |> should.equal("Hello Users\n")
}

pub fn if_else_statement_test() {
  if_else_statement.render(True)
  |> should.equal("Hello User\n")

  if_else_statement.render(False)
  |> should.equal("Hello Unknown\n")
}

pub fn value_in_if_else_test() {
  value_in_if_else.render(greeting: "Hello", is_user: True)
  |> should.equal("Hello User\n")

  value_in_if_else.render(greeting: "Hello", is_user: False)
  |> should.equal("Hello Unknown\n")
}

pub fn nested_if_statement_test() {
  nested_if_statement.render(is_user: True, is_admin: True)
  |> should.equal("Hello Admin\n")

  nested_if_statement.render(is_user: True, is_admin: False)
  |> should.equal("Hello User\n")

  nested_if_statement.render(is_user: False, is_admin: False)
  |> should.equal("Hello\n")
}

pub fn for_loop_test() {
  for_loop.render(["Anna", "Bill", "Christine"])
  |> should.equal("Hello, to Anna and to Bill and to Christine and everyone else\n")

  for_loop.render([])
  |> should.equal("Hello, everyone else\n")
}

pub fn for_as_loop_test() {
  for_as_loop.render(users: [NamedUser("Anna"), NamedUser("Bill")])
  |> should.equal("Hello, to Anna and to Bill and everyone else\n")
}

pub fn for_loop_from_expression_test() {
  for_loop_from_expression.render(users: [NamedUser("Anna"), NamedUser("Bill"), NamedUser("Christine")], limit: 2)
  |> should.equal("Hello, to Anna and to Bill and everyone else\n")
}

pub fn value_in_for_loop_test() {
  value_in_for_loop.render(greeting: "Hello", my_list: ["Anna", "Bill", "Christine"])
  |> should.equal("<h1>My List</h1>
<ul>

    <li>Hello Anna</li>

    <li>Hello Bill</li>

    <li>Hello Christine</li>

</ul>
")
}

pub fn dot_access_test() {
  let user = User(is_admin: True)
  dot_access.render(user)
  |> should.equal("Hello Admin\n")

  let user = User(is_admin: False)
  dot_access.render(user)
  |> should.equal("Hello\n")
}

pub fn multiline_test() {
  multiline.render(["Anna", "Bill", "Christine"])
  |> should.equal("<h1>My List</h1>
<ul>

    <li>Anna</li>

    <li>Bill</li>

    <li>Christine</li>

</ul>
")
}

pub fn quote_test() {
  quote.render(name: "Anna")
  |> should.equal("<div class=\"my-class\">Anna</div>\n")
}
