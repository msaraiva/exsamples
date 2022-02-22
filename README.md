# ExSamples

Initializes lists of maps, structs or keyword lists using tabular data in Elixir.

ExSamples helps you to describe data of the same type in a more **compact** and **readable** way. Specially useful when defining sample data (e.g. for tests). Here is an example:

```elixir
countries =
  samples do
    :id | :name           | :currency                    | :language    | :population
     1  | "Brazil"        | "Real (BRL)"                 | "Portuguese" | 204_451_000
     2  | "United States" | "United States Dollar (USD)" | "English"    | 321_605_012
     3  | "Austria"       | "Euro (EUR)"                 | "German"     |   8_623_073
     4  | "Sweden"        | "Swedish krona (SEK)"        | "Swedish"    |   9_801_616
  end
```

```elixir
iex> IO.inspect(countries)
[
  %{
    currency: "Real (BRL)",
    id: 1,
    language: "Portuguese",
    name: "Brazil",
    population: 204451000
  },
  %{
    currency: "United States Dollar (USD)",
    id: 2,
    language: "English",
    name: "United States",
    population: 321605012
  },
  %{
    currency: "Euro (EUR)",
    id: 3,
    language: "German",
    name: "Austria",
    population: 8623073
  },
  %{
    currency: "Swedish krona (SEK)",
    id: 4,
    language: "Swedish",
    name: "Sweden",
    population: 9801616
  }
]
```

You can see it in action with [livebook](https://livebook.dev/) with [guides/usage.livemd](guides/usage.livemd).

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fmsaraiva%2Fexsamples%2Fblob%2Fmaster%2Fguides%2Fusage.livemd)

## Installation

Add `:exsamples` as a dependency in your `mix.exs` file.

```elixir
def deps do
  [ { :exsamples, "~> 0.1.0" } ]
end
```

## Configure the formatter (only for Elixir >= `v1.13.2`)

Add `Samples.FormatterPlugin` to the list of plugins in your `.formatter.exs`:

```elixir
[
  plugins: [Samples.FormatterPlugin],
  ...
]

```

If you don't configure the formatter, `mix format` will remove all extra spaces you add
to make your tables look nice.

## Usage

```elixir
import ExSamples

samples do
  :name       | :country        | :city           | :admin
  "Christian" | "United States" | "New York City" | false
  "Peter"     | "Germany"       | "Berlin"        | true
  "José"      | "Brazil"        | "São Paulo"     | false
  "Ingrid"    | "Austria"       | "Salzburg"      | false
  "Lucas"     | "Brazil"        | "Fortaleza"     | true
end
```

By default `samples` initializes a list of maps. But you can also define structs and keyword lists.

### Initializing structs

```elixir
import ExSamples

defmodule Country do
  defstruct [:id, :name, :currency, :language, :population]
end

samples as: Country do
  :id | :name           | :currency                    | :language    | :population
   1  | "Brazil"        | "Real (BRL)"                 | "Portuguese" | 204_451_000
   2  | "United States" | "United States Dollar (USD)" | "English"    | 321_605_012
end
```

### Initializing keyword lists

```elixir
samples as: [] do
  :id | :name           | :currency             | :language    | :population
   3  | "Austria"       | "Euro (EUR)"          | "German"     |   8_623_073
   4  | "Sweden"        | "Swedish krona (SEK)" | "Swedish"    |   9_801_616
end
```

### Assigning variables as structs

```elixir

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

```elixir
samples do
   %{}  | :name       | :country        | :city
  user1 | "Christian" | "United States" | "New York City"
  user2 | "Ingrid"    | "Austria"       | "Salzburg"
end
```

### Assigning variables as keyword lists

```elixir
samples do
    []  | :name       | :country        | :city
  user1 | "Christian" | "United States" | "New York City"
  user2 | "Ingrid"    | "Austria"       | "Salzburg"
end

```

##License
(The MIT License)

Copyright (c) 2022 Marlus Saraiva

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
