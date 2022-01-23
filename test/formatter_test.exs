defmodule Samples.FormatterPluginTest do
  use ExUnit.Case

  test "format all samples" do
    code = """
      samples do
        :name | :country | :city
        "Christian" | "United States" | "New York City"
        "Peter" | "Austria" | "Vienna"
      end

        samples do
          :name | :country | :city
          "Christian" | "United States" | "New York City"
          "Peter" | "Austria" | "Vienna"
        end
    """

    assert Samples.FormatterPlugin.format(code, []) == """
           samples do
             :name       | :country        | :city
             "Christian" | "United States" | "New York City"
             "Peter"     | "Austria"       | "Vienna"
           end

           samples do
             :name       | :country        | :city
             "Christian" | "United States" | "New York City"
             "Peter"     | "Austria"       | "Vienna"
           end
           """
  end

  test "format samples with :as option" do
    code = """
      users = samples as: User do
        :name | :country | :city
        "Christian" | "United States" | "New York City"
        "Peter" | "Austria" | "Vienna"
      end
    """

    assert Samples.FormatterPlugin.format(code, []) == """
           users =
             samples as: User do
               :name       | :country        | :city
               "Christian" | "United States" | "New York City"
               "Peter"     | "Austria"       | "Vienna"
             end
           """
  end

  test "format empty samples" do
    code = """
      users = samples do
      end

      users = samples do

      end
    """

    assert Samples.FormatterPlugin.format(code, []) == """
           users =
             samples do
             end

           users =
             samples do
             end
           """
  end

  test "keep formating after empty samples" do
    code = """
    users =
      samples do
      end

    samples do
      User | :name | :country | :city
      user1 | "Christian" | country | "New York City"
    end
    """

    assert Samples.FormatterPlugin.format(code, []) == """
           users =
             samples do
             end

           samples do
             User  | :name       | :country | :city
             user1 | "Christian" | country  | "New York City"
           end
           """
  end

  test "align columns with numbers to the right" do
    code = """
    samples do
      :id | :name | :currency | :language | :population | :inflation
      1 | "Brazil" | "Real (BRL)" | "Portuguese" | 204451000 | 7.70
      3 | "Austria" | "Euro (EUR)" | "German" | 8623073 | 2.45
      1234 | "Sweden" | "Swedish krona (SEK)" | "Swedish" | 9801616 | 3.60
    end
    """

    assert Samples.FormatterPlugin.format(code, []) == """
           samples do
              :id | :name     | :currency             | :language    | :population | :inflation
                1 | "Brazil"  | "Real (BRL)"          | "Portuguese" | 204_451_000 |       7.70
                3 | "Austria" | "Euro (EUR)"          | "German"     |   8_623_073 |       2.45
             1234 | "Sweden"  | "Swedish krona (SEK)" | "Swedish"    |   9_801_616 |       3.60
           end
           """
  end
end
