defmodule ImageLib.IdentifyTest do

  alias ImageLib.Identify
  alias ImageLib.Magick.Image

  use ExUnit.Case, async: true

  @fixture Path.join(__DIR__, "../../fixtures/magick/bender.jpg") |> Path.expand

  test ".identify" do
    assert Identify.identify(@fixture) ==
      %Image{
        animated: false,
        dirty: %{},
        ext: ".jpg",
        format: nil,
        frame_count: 1,
        height: 292,
        mime_type: nil,
        operations: [],
        path: @fixture, 
        size: 23465,
        width: 300
      }
  end

end
