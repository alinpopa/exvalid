# ExValid

Collecting errors validation ADT using Witchcraft.

## Installation

```elixir
def deps do
  [
    {:exvalid, "~> 0.2.0"}
  ]
end
```

## Usage

```elixir
use ExValid
alias Validate.{Valid, Invalid}
import Quark.Curry, only: [curry: 1]

defmodule User do
  defstruct email: nil, name: nil
end

# And Elixir doesn't have currying by default, so ...
map2 = fn fa, fb, f -> of(%Valid{}, f) |> ap(fa) |> ap(fb) end |> curry
f = fn email, name -> %User{email: email, name: name} end |> curry

validate_email =
  fn user ->
    if user.email,
      do: Valid.new(user.email),
      else: Invalid.new("Email missing.")
  end

validate_name =
  fn user ->
    if user.name,
      do: Valid.new(user.name),
      else: Invalid.new("Name missing.")
  end

user = %User{}
map2.(validate_email.(user)).(validate_name.(user)).(f)
# => %ExValid.Validate.Invalid{invalid: ["Email missing.", "Name missing."]}

user = %User{email: "x@y.z"}
map2.(validate_email.(user)).(validate_name.(user)).(f)
# => %ExValid.Validate.Invalid{invalid: ["Name missing."]}

user = %User{name: "A.B. Sea"}
map2.(validate_email.(user)).(validate_name.(user)).(f)
# => %ExValid.Validate.Invalid{invalid: ["Email missing."]}

user = %User{name: "A.B. Sea", email: "x@y.z"}
map2.(validate_email.(user)).(validate_name.(user)).(f)
# => %ExValid.Validate.Valid{valid: %User{email: "x@y.z", name: "A.B. Sea"}}
```
