defmodule ImageLib.Identify do
  alias ImageLib.Magick.Image

  def verbose(args), do: verbose(args, [])
  def verbose(file_path, _opts) do
    {rows_text, 0} = ImageLib.Magick.system_cmd("identify", ["-verbose", file_path])

    [head_row | rows] = rows_text |> String.split("\n")
    [key, _] = head_row |> String.split(": ")

    rows
    |> List.insert_at(0, key <> ":")
    |> Enum.join("\n")
    |> RelaxYaml.decode!
  end

  def identify(args), do: identify(args, [])
  def identify(file_path, opts) do
    file_path
    |> verbose(opts)
    |> parse_verbose(opts)
  end

  def parse_verbose(args), do: parse_verbose(args, [])
  def parse_verbose(data, _opts) do
    file_path =
      data
      |> Map.get("Image", %{})
      |> Map.get("Artifacts", %{})
      |> Map.get("filename")

    %{size: size} = File.stat! file_path

    [width, height] =
      data
      |> Map.get("Image", %{})
      |> Map.get("Geometry")
      |> String.split("+")
      |> List.first
      |> String.split("x")
      |> Enum.map(fn(value) -> String.to_integer(value) end)

    mime_type = data |> Map.get("Image", %{}) |> Map.get("Mime type")
    format = data |> Map.get("Image", %{}) |> Map.get("Format")

    %Image{
      size:        size,
      path:        file_path,
      ext:         Path.extname(file_path),
      format:      format,
      mime_type:   mime_type,
      width:       width,
      height:      height,
      operations:  [],
      dirty:       %{}
    }
  end

end
