defmodule ExValidTest do
  use ExUnit.Case
  doctest ExValid

  use ExValid
  alias Validate.{Valid, Invalid}
  import Quark.Curry, only: [curry: 1]

  defmodule User do
    defstruct email: nil, name: nil
  end

  test "map2 validation empty struct" do
    map2 = fn fa, fb, f -> of(%Valid{}, f) |> ap(fa) |> ap(fb) end |> curry

    validate_email = fn user ->
      if user.email, do: Valid.new(user.email), else: Invalid.new("Email missing.")
    end

    validate_name = fn user ->
      if user.name, do: Valid.new(user.name), else: Invalid.new("Name missing.")
    end

    user = %User{}
    f = fn email, name -> %User{email: email, name: name} end |> curry

    result = map2.(validate_email.(user)).(validate_name.(user)).(f)
    assert result == %Invalid{invalid: ["Email missing.", "Name missing."]}
  end

  test "map2 validation empty name" do
    map2 = fn fa, fb, f -> of(%Valid{}, f) |> ap(fa) |> ap(fb) end |> curry

    validate_email = fn user ->
      if user.email, do: Valid.new(user.email), else: Invalid.new("Email missing.")
    end

    validate_name = fn user ->
      if user.name, do: Valid.new(user.name), else: Invalid.new("Name missing.")
    end

    user = %User{email: "x@y.z"}
    f = fn email, name -> %User{email: email, name: name} end |> curry

    result = map2.(validate_email.(user)).(validate_name.(user)).(f)
    assert result == %Invalid{invalid: ["Name missing."]}
  end

  test "map2 validation empty email" do
    map2 = fn fa, fb, f -> of(%Valid{}, f) |> ap(fa) |> ap(fb) end |> curry

    validate_email = fn user ->
      if user.email, do: Valid.new(user.email), else: Invalid.new("Email missing.")
    end

    validate_name = fn user ->
      if user.name, do: Valid.new(user.name), else: Invalid.new("Name missing.")
    end

    user = %User{name: "A.B. Sea"}
    f = fn email, name -> %User{email: email, name: name} end |> curry

    result = map2.(validate_email.(user)).(validate_name.(user)).(f)
    assert result == %Invalid{invalid: ["Email missing."]}
  end

  test "map2 validation valid" do
    map2 = fn fa, fb, f -> of(%Valid{}, f) |> ap(fa) |> ap(fb) end |> curry

    validate_email = fn user ->
      if user.email, do: Valid.new(user.email), else: Invalid.new("Email missing.")
    end

    validate_name = fn user ->
      if user.name, do: Valid.new(user.name), else: Invalid.new("Name missing.")
    end

    user = %User{name: "A.B. Sea", email: "x@y.z"}
    f = fn email, name -> %User{email: email, name: name} end |> curry

    result = map2.(validate_email.(user)).(validate_name.(user)).(f)
    assert result == %Valid{valid: %User{name: "A.B. Sea", email: "x@y.z"}}
  end
end
