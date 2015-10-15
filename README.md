# ExSamples

Initializes lists and/or variables using tabular data written in Elixir.

ExSamples helps you to describe data with same type in a more **compact** and **readable** way. Specially useful when defining sample data (e.g. for tests). Here is an example:

```Elixir
countries = samples do
  :id | :name           | :currency                    | :language    | :population
   1  | "Brazil"        | "Real (BRL)"                 | "Portuguese" | 204_451_000
   2  | "United States" | "United States Dollar (USD)" | "English"    | 321_605_012
   3  | "Austria"       | "Euro (EUR)"                 | "German"     |   8_623_073
   4  | "Sweden"        | "Swedish krona (SEK)"        | "Swedish"    |   9_801_616
end

```

```
iex> countries |> Enum.at(1)
%{currency: "United States Dollar (USD)", id: 2, language: "English",
  name: "United States", population: 321605012}
```
> Disclaimer: This is a very experimental library. The main goal of this first version is to define the table format(s) and minimum functionality.

## Install

Add ExSamples as a dependency in your `mix.exs` file.

```elixir
def deps do
  [ { :ex_samples, "~> 0.0.1" } ]
end
```

Run `mix deps.get`.

## Usage

```Elixir
import ExSamples

users = samples do
  :name       | :country        | :city           | :admin
  "Christian" | "United States" | "New York City" | false
  "Peter"     | "Germany"       | "Berlin"        | true
  "José"      | "Brazil"        | "São Paulo"     | false
  "Ingrid"    | "Austria"       | "Salzburg"      | false
  "Lucas"     | "Brazil"        | "Fortaleza"     | true      
end

for %{name: name, country: country, city: city} <- users, country == "Brazil" do
  {name, city}
end

# [{"José", "São Paulo"}, {"Lucas", "Fortaleza"}]
```

As you can see, after macro expansion you get a regular list. You can use `for` comprehensions for mapping and filtering your data just like with any other Enumerable.

By default `samples` initializes a list of maps. But you can also define structs and keyword lists.

### Initializing structs

```Elixir
import ExSamples

defmodule Country do
  defstruct [:id, :name, :currency, :language, :population]
end

countries = samples as: Country do
  :id | :name           | :currency                    | :language    | :population
   1  | "Brazil"        | "Real (BRL)"                 | "Portuguese" | 204_451_000
   2  | "United States" | "United States Dollar (USD)" | "English"    | 321_605_012    
end
```

### Initializing keyword lists

```Elixir
countries = samples as: [] do
  :id | :name           | :currency             | :language    | :population
   3  | "Austria"       | "Euro (EUR)"          | "German"     |   8_623_073        
   4  | "Sweden"        | "Swedish krona (SEK)" | "Swedish"    |   9_801_616
end
```

### Assigning variables as structs

```Elixir

defmodule Country do
  defstruct [:name, :currency, :language]
end

defmodule User do
  defstruct [:id, :name, :country, :admin, :last_login]
end

samples do
  Country  | :name           | :currency                    | :language
  country1 | "Brazil"        | "Real (BRL)"                 | "Portuguese"
  country2 | "United States" | "United States Dollar (USD)" | "English"
  country3 | "Austria"       | "Euro (EUR)"                 | "German"
end

samples do
  User  | :id | :name       | :country | :admin | :last_login
  user1 |  16 | "Lucas"     | country1 | false  | {2015, 10, 08}
  user2 | 327 | "Ingrid"    | country3 | true   | {2014, 09, 12}
  user3 |  34 | "Christian" | country2 | false  | {2015, 01, 24}
end

```

```
iex> IO.puts "Name: #{user1.name}, Country: #{user1.country.name}"
Name: Lucas, Country: Brazil
```

### Assigning variables as maps

```Elixir
samples do
   %{}  | :name       | :country        | :city
  user1 | "Christian" | "United States" | "New York City"
  user2 | "Ingrid"    | "Austria"       | "Salzburg"
end
```

### Assigning variables as keyword lists

```Elixir
samples do
    []  | :name       | :country        | :city
  user1 | "Christian" | "United States" | "New York City"
  user2 | "Ingrid"    | "Austria"       | "Salzburg"
end

```

## Other examples (WIP)

```Elixir
  truth_table = samples do
     :a   |  :b   | :and  |  :or  | :xor
    true  | true  | true  | true  | false
    true  | false | false | true  | true
    false | true  | false | true  | true
    false | false | false | false | false
  end

```

##License
(The MIT License)

Copyright (c) 2015 Marlus Saraiva

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
