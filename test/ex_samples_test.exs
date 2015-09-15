defmodule ExSamplesTest do
  use ExUnit.Case
  use ExSamples  

  defmodule User do
    defstruct name: nil, country: nil, city: nil, age: nil
  end

  test "initializing structs" do

    result = samples do
      User  | :name       | :country        | :city           | :age
      user1 | "Christian" | "United States" | "New York City" | 27
      user2 | "Peter"     | "Austria"       | "Vienna"        | 32
    end

    assert user1  == %User{name: "Christian", country: "United States", city: "New York City", age: 27}
    assert user2  == %User{name: "Peter", country: "Austria", city: "Vienna", age: 32}
    assert result == [user1, user2]
    
  end

  test "initializing keyword lists" do
    result = samples do
      []    | :name       | :country        | :city           | :age
      user1 | "Christian" | "United States" | "New York City" | 27
      user2 | "Peter"     | "Austria"       | "Vienna"        | 32
    end

    assert user1 == [name: "Christian", country: "United States", city: "New York City", age: 27]
    assert user2 == [name: "Peter", country: "Austria", city: "Vienna", age: 32]
    assert result == [user1, user2]

  end

  test "initializing maps" do

    result = samples do
      %{}   | :name       | :country        | :city           | :age
      user1 | "Christian" | "United States" | "New York City" | 27
      user2 | "Peter"     | "Austria"       | "Vienna"        | 32
    end

    assert user1 == %{name: "Christian", country: "United States", city: "New York City", age: 27}
    assert user2 == %{name: "Peter", country: "Austria", city: "Vienna", age: 32}

  end

  test "without initializing variables" do
      users = samples do
        :name       | :country        | :city           | :age
        "Christian" | "United States" | "New York City" | 27
        "Peter"     | "Austria"       | "Vienna"        | 32
      end

      assert users == [
        %{name: "Christian", country: "United States", city: "New York City", age: 27},
        %{name: "Peter", country: "Austria", city: "Vienna", age: 32}
      ]
  end

  test "table with single line" do

    users = samples do
      User  | :name       | :country        | :city           | :age
      user1 | "Christian" | "United States" | "New York City" | 27
    end

    assert user1 == %User{name: "Christian", country: "United States", city: "New York City", age: 27}
    assert users == [user1]

  end

  test "table without body" do

    users = samples do
      User | :name | :country | :city | :age
    end

    assert users == []

  end

  test "with variables" do

    country = "United States"
    age     = 27
    
    samples do
      User  | :name       | :country | :city           | :age
      user1 | "Christian" | country  | "New York City" | age
    end

    assert user1 == %User{name: "Christian", country: "United States", city: "New York City", age: 27}

  end

  def country do
    "United States"
  end

  test "with functions" do
    
    samples do
      User  | :name       | :country | :city           | :age
      user1 | "Christian" | country  | "New York City" | 27
    end

    assert user1 == %User{name: "Christian", country: "United States", city: "New York City", age: 27}

  end

  @country "United States"

  test "with module attributes" do
    
    samples do
      User  | :name       | :country | :city           | :age
      user1 | "Christian" | @country | "New York City" | 27
    end

    assert user1 == %User{name: "Christian", country: "United States", city: "New York City", age: 27}

  end

  test "with diferent types" do
    
    samples do
      %{}   | :string       | :integer | :float | :atom | :boolean 
      types | "some string" |       42 |  14.33 | :foo  |   true    
    end

    assert types.string  == "some string"
    assert types.integer == 42
    assert types.float   == 14.33
    assert types.atom    == :foo
    assert types.boolean == true

  end

  test "with diferent compound data types" do
    
    samples do
      %{}   | :list   | :tuple           | :struct                     | :map
      types | [1,2,3] | {2, "foo" ,:bar} | %User{name: "Joe", age: 35} | %{foo: "bar"}
    end

    assert types.list   == [1,2,3]
    assert types.tuple  == {2, "foo" ,:bar}
    assert types.struct == %User{name: "Joe", age: 35, country: nil, city: nil}
    assert types.map    == %{foo: "bar"}
    
  end
  
end

