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
end
