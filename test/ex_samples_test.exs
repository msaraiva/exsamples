defmodule ExSamplesTest do
  use ExUnit.Case
  use ExSamples  

  defmodule User do
    defstruct name: nil, country: nil, city: nil, age: nil
  end

  test "initializing structs" do

    result = vars do
      User  | :name       | :country        | :city           | :age
      user1 | "Christian" | "United States" | "New York City" | 27
      user2 | "Peter"     | "Austria"       | "Vienna"        | 32
    end

    assert user1  == %User{name: "Christian", country: "United States", city: "New York City", age: 27}
    assert user2  == %User{name: "Peter", country: "Austria", city: "Vienna", age: 32}
    assert result == [user1, user2]
    
  end

  test "initializing keyword lists" do
    result = vars do
      []    | :name       | :country        | :city           | :age
      user1 | "Christian" | "United States" | "New York City" | 27
      user2 | "Peter"     | "Austria"       | "Vienna"        | 32
    end

    assert user1 == [name: "Christian", country: "United States", city: "New York City", age: 27]
    assert user2 == [name: "Peter", country: "Austria", city: "Vienna", age: 32]
    assert result == [user1, user2]    

  end

  test "initializing maps" do

    vars do
      %{}   | :name       | :country        | :city           | :age
      user1 | "Christian" | "United States" | "New York City" | 27
      user2 | "Peter"     | "Austria"       | "Vienna"        | 32
    end

    assert user1 == %{name: "Christian", country: "United States", city: "New York City", age: 27}
    assert user2 == %{name: "Peter", country: "Austria", city: "Vienna", age: 32}

  end

  test "without initializing variables" do
      users = list_of do
        :name       | :country        | :city           | :age
        "Christian" | "United States" | "New York City" | 27
        "Peter"     | "Austria"       | "Vienna"        | 32
      end

      assert users == [
        %{name: "Christian", country: "United States", city: "New York City", age: 27},
        %{name: "Peter", country: "Austria", city: "Vienna", age: 32}
      ]
  end
  
end

