defmodule ExSamplesTest do
  use ExUnit.Case
  import ExSamples

  defmodule User do
    defstruct name: nil, country: nil, city: nil
  end

  test "initializing a list of maps (default)" do
    users =
      samples do
        :name       | :country        | :city
        "Christian" | "United States" | "New York City"
        "Peter"     | "Austria"       | "Vienna"
      end

    assert users == [
             %{name: "Christian", country: "United States", city: "New York City"},
             %{name: "Peter", country: "Austria", city: "Vienna"}
           ]
  end

  test "initializing a list of structs" do
    users =
      samples as: User do
        :name       | :country        | :city
        "Christian" | "United States" | "New York City"
        "Peter"     | "Austria"       | "Vienna"
      end

    assert users == [
             %User{name: "Christian", country: "United States", city: "New York City"},
             %User{name: "Peter", country: "Austria", city: "Vienna"}
           ]
  end

  test "initializing list of keyword lists" do
    users =
      samples as: [] do
        :name       | :country        | :city
        "Christian" | "United States" | "New York City"
        "Peter"     | "Austria"       | "Vienna"
      end

    assert users == [
             [name: "Christian", country: "United States", city: "New York City"],
             [name: "Peter", country: "Austria", city: "Vienna"]
           ]
  end

  test "initializing variables in the first column as maps" do
    samples do
      %{}   | :name       | :country        | :city
      user1 | "Christian" | "United States" | "New York City"
      user2 | "Peter"     | "Austria"       | "Vienna"
    end

    assert user1 == %{name: "Christian", country: "United States", city: "New York City"}
    assert user2 == %{name: "Peter", country: "Austria", city: "Vienna"}
  end

  test "initializing variables in the first column as structs" do
    samples do
      User  | :name       | :country        | :city
      user1 | "Christian" | "United States" | "New York City"
      user2 | "Peter"     | "Austria"       | "Vienna"
    end

    assert user1 == %User{name: "Christian", country: "United States", city: "New York City"}
    assert user2 == %User{name: "Peter", country: "Austria", city: "Vienna"}
  end

  test "initializing variables in the first column as keyword lists" do
    samples do
      []    | :name       | :country        | :city
      user1 | "Christian" | "United States" | "New York City"
      user2 | "Peter"     | "Austria"       | "Vienna"
    end

    assert user1 == [name: "Christian", country: "United States", city: "New York City"]
    assert user2 == [name: "Peter", country: "Austria", city: "Vienna"]
  end

  test "table with single line" do
    users =
      samples do
        User  | :name       | :country        | :city
        user1 | "Christian" | "United States" | "New York City"
      end

    assert user1 == %User{name: "Christian", country: "United States", city: "New York City"}
    assert users == [user1]
  end

  test "table without body" do
    users =
      samples do
        User | :name | :country | :city
      end

    assert users == []
  end

  test "empty table" do
    users =
      samples do
      end

    assert users == []
  end

  test "with variables as values" do
    country = "United States"

    samples do
      User  | :name       | :country | :city
      user1 | "Christian" | country  | "New York City"
    end

    assert user1 == %User{name: "Christian", country: "United States", city: "New York City"}
  end

  def country do
    "United States"
  end

  test "with functions as values" do
    samples do
      User  | :name       | :country  | :city
      user1 | "Christian" | country() | "New York City"
    end

    assert user1 == %User{name: "Christian", country: "United States", city: "New York City"}
  end

  @country "United States"

  test "with module attributes as values" do
    samples do
      User  | :name       | :country | :city
      user1 | "Christian" | @country | "New York City"
    end

    assert user1 == %User{name: "Christian", country: "United States", city: "New York City"}
  end

  test "with diferent types" do
    samples do
      %{}   | :string       | :integer | :float | :atom | :boolean
      types | "some string" | 42       | 14.33  | :foo  | true
    end

    assert types.string == "some string"
    assert types.integer == 42
    assert types.float == 14.33
    assert types.atom == :foo
    assert types.boolean == true
  end

  test "with diferent compound data types" do
    samples do
      %{}   | :list     | :tuple           | :struct                            | :map
      types | [1, 2, 3] | {2, "foo", :bar} | %User{name: "Joe", city: "London"} | %{foo: "bar"}
    end

    assert types.list == [1, 2, 3]
    assert types.tuple == {2, "foo", :bar}
    assert types.struct == %User{name: "Joe", city: "London", country: nil}
    assert types.map == %{foo: "bar"}
  end

  test "field names as vars" do
    users =
      samples do
        name        | country         | city
        "Christian" | "United States" | "New York City"
        "Peter"     | "Austria"       | "Vienna"
      end

    assert users == [
             %{name: "Christian", country: "United States", city: "New York City"},
             %{name: "Peter", country: "Austria", city: "Vienna"}
           ]
  end
end
