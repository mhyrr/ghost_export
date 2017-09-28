defmodule GhostExport do
  use Application

  def start(_, _) do

    IO.puts "Reading file"
    parse()

    Supervisor.start_link [], strategy: :one_for_one

  end

  def parse do
    {:ok, json} = File.read "ghost.json"

    data = Poison.decode!(json)

    File.mkdir("txt")

    Enum.map( hd(data["db"])["data"]["posts"], fn (post) ->

        slugTime = DateTime.from_iso8601(post["created_at"]) |> elem(1) |> DateTime.to_date |> Date.to_string

        fileName = slugTime <> "-" <> post["slug"] <> ".md"

        IO.puts(slugTime <> "-" <> post["slug"])

        fileContents = Enum.join(
          [
            "---",
            "title: " <> post["title"],
            "date: " <> post["created_at"],
            "path: " <> "/" <> String.trim_trailing(fileName, ".md") <> "/",
            "---",
            "",
            post["markdown"]
          ], "\n"
        )

        File.write("./txt/" <> fileName, fileContents, [:binary])

      end
    )
  end

end
