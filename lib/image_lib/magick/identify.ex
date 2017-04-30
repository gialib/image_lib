defmodule ImageLib.Identify do
  alias ImageLib.Magick.Image

  def verbose(args), do: verbose(args, [])
  def verbose(file_path, _opts) do
    {rows_text, 0} = ImageLib.Magick.system_cmd("identify", ["-verbose", file_path])

    rows_text |> parse_verbose_data
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
    animated = format == "image/gif"

    %Image{
      animated:    animated,
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

  defp from_char_list(char_list) do
    Enum.join(for <<c::utf8 <- char_list>>, do: <<c::utf8>>)
  end

  @doc """
  解析verbose的数据
  """
  def parse_verbose_data(verbose_data \\ "") do
    [_first_row | rows] =
      verbose_data
      |> from_char_list
      |> String.split("\nImage: ")
      |> List.first
      |> String.split("\n")

    rows
    |> List.insert_at(0, "Image:")
    |> Enum.map(fn(row) ->
      [key | values] = row |> String.split(": ")

      key_trim = key |> String.trim() |> String.trim_trailing(":")

      cond do
        key_trim in ~w(Colormap Histogram) -> nil      # 将不能解析的节点去掉
        Regex.match?(~r"\A[0-9]*\z", key_trim) -> nil
        Enum.any?(values) ->
          ~s(#{key}: "#{values |> Enum.join(": ")}")
        true ->
          ~s(#{key})
      end
    end)
    |> Enum.filter(fn(row) ->
      !!row
    end)
    |> Enum.join("\n")
    |> RelaxYaml.decode!
  end
end
