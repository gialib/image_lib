defmodule ImageLib.Identify do
  alias ImageLib.Magick.Image

  def identify(file_path, _opts \\ []) do
    %{size: size} = File.stat! file_path

    {rows_text, 0} = ImageLib.Magick.system_cmd("identify", ["-verbose", file_path])

    [head_row | rows] = rows_text |> String.split("\n")
    [key, _] = head_row |> String.split(": ")
    data =
      rows
      |> List.insert_at(0, key <> ":")
      |> Enum.join("\n")
      |> RelaxYaml.decode!

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
      path: file_path,
      ext: Path.extname(file_path),
      format:      format,
      mime_type:   mime_type,
      width:       width,
      height:      height,
      # animated:    animated,
      # frame_count: frame_count,
      operations:  [],
      dirty:       %{}
    }
  end
end
