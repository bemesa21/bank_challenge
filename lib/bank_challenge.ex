defmodule BankChallenge do
  def accounts_scanning() do
    "lib/1.txt"
    |> read_accounts()
    |> transform_accounts()
    |> Enum.map(&Enum.join/1)
    |> save_report()
  end

  def accounts_validation() do
    "lib/3.txt"
    |> read_accounts()
    |> transform_accounts()
    |> validate_accounts()
    |> save_report()
  end

  def read_accounts(file) do
    File.stream!(file)
    |> Stream.map(fn line -> String.trim_trailing(line, "\n") end)
    |> Stream.map(fn line -> String.split(line, ~r/.{3}/, include_captures: true, trim: true) end)
    |> Stream.chunk_by(& &1 == [])
    |> Stream.map(&Enum.zip/1)
    |> Enum.filter(& &1 != [])
  end
  def transform_accounts(accounts) do
    Enum.map(accounts, &transform_account_to_numbers/1)
  end

  def transform_account_to_numbers(account_simbols) do
    account_simbols
    |> Enum.map(&to_integer/1)
  end

  def validate_accounts(accounts) do
    Enum.map(accounts, &account_status/1)
  end

  def account_status(account) do
    case checksum(account) do
      -1 -> "#{Enum.join(account)} ILL"
      0 -> "#{Enum.join(account)} OK"
      _ -> "#{Enum.join(account)} ERR"
    end
  end

  def checksum(account) do
    account
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce_while(0, fn {x, idx}, acc ->
      if is_integer(x), do: {:cont, acc + x*idx},
      else: {:halt, -1} end)
    |> rem(11)
  end

  def save_report(results) do
    content = Enum.join(results, "\n")
    File.write("lib/report.txt", content)
  end

  def to_integer(number) do
    case number do
      {" _ ",
       "| |",
       "|_|"} -> 0

      {"   ",
       " | ",
       " | "} -> 1

      {" _ ",
       " _|",
       "|_ "} -> 2

      {" _ ",
       " _|",
       " _|"} -> 3

      {"   ",
       "|_|",
       "  |"} -> 4

      {" _ ",
       "|_ ",
       " _|"} -> 5

      {" _ ",
       "|_ ",
       "|_|"} -> 6

      {" _ ",
       "  |",
       "  |"} -> 7

      {" _ ",
       "|_|",
       "|_|"} -> 8

      {" _ ",
       "|_|",
       " _|"} -> 9

       _ -> "?"

    end
  end
end
