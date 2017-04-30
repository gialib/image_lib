defmodule ImageLib.IdentifyTest do

  alias ImageLib.Identify
  alias ImageLib.Magick.Image

  use ExUnit.Case, async: true

  @fixture Path.join(__DIR__, "../../fixtures/magick/bender.jpg") |> Path.expand

  test ".identify" do
    Identify.verbose("/Users/happy/tmp/upload_test.jpg")

    assert Identify.identify(@fixture) ==
      %Image{
        animated: false,
        dirty: %{},
        ext: ".jpg",
        format: "JPEG (Joint Photographic Experts Group JFIF format)",
        frame_count: 1,
        height: 292,
        mime_type: "image/jpeg",
        operations: [],
        path: @fixture, 
        size: 23465,
        width: 300
      }
  end

end
