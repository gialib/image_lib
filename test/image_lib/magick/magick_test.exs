defmodule ImageLib.MagickTest do

  alias ImageLib.Magick
  alias ImageLib.Magick.Image

  use ExUnit.Case, async: true

  @fixture Path.join(__DIR__, "../../fixtures/magick/bender.jpg") |> Path.expand
  @fixture_watermark Path.join(__DIR__, "../../fixtures/magick/watermark.png") |> Path.expand
  @fixture_with_space Path.join(__DIR__, "../../fixtures/magick/image with space in name/ben der.jpg") |> Path.expand
  @fixture_animated Path.join(__DIR__, "../../fixtures/magick/bender_anim.gif") |> Path.expand
  @temp_test_directory Path.join(__DIR__, "../../tmp/magick_output") |> Path.expand
  @temp_image_bender Path.join(@temp_test_directory, "bender.jpg") |> Path.expand
  @temp_image_with_space Path.join(@temp_test_directory, "1 1.jpg") |> Path.expand
  @temp_image_animated Path.join(@temp_test_directory, "bender_anim.gif") |> Path.expand

  test ".open" do
    image = Magick.open("./test/fixtures/magick/bender.jpg")
    assert %Image{ext: ".jpg"} = image

    image = Magick.open(@fixture)
    assert %Image{ext: ".jpg"} = image
  end

  test ".convert basic" do
    File.mkdir_p!(@temp_test_directory)

    Magick.convert(
      src: @fixture,
      dist: @temp_image_bender,
      quality: 80,
      resize: "580x580",
      background: "orange",
      gravity: "center",
      extent: "1024x768",  # 注意顺序
    )
  end

  test ".convert path with space" do
    File.mkdir_p!(@temp_test_directory)

    Magick.convert(
      src: @fixture_with_space,
      dist: @temp_image_with_space,
      quality: 80,
      resize: "580x580",
      background: "orange",
      gravity: "center",
      extent: "1024x768",  # 注意顺序
    )
  end

  test ".convert animated" do
    File.mkdir_p!(@temp_test_directory)

    Magick.convert(
      src: @fixture_animated,
      dist: @temp_image_animated,
      quality: 80,
      resize: "580x580",
      background: "orange",
      gravity: "center",
      extent: "1024x768",  # 注意顺序
    )
  end

  test ".convert animated with dist_format is jpg" do
    File.mkdir_p!(@temp_test_directory)

    Magick.convert(
      src: @fixture_animated,
      dist_format: "jpg",
      dist: get_dist_path("bender_anim_from_gif.jpg"),
      strip: true,
      flatten: true,
      quality: 80,
      resize: "580x580",
      background: "orange",
      gravity: "center",
      extent: "1024x768",  # 注意顺序
    )
  end

  test ".convert with watermark" do
    File.mkdir_p!(@temp_test_directory)

    Magick.convert(
      src: @fixture,
      watermark: @fixture_watermark,
      dist: get_dist_path("output_with_watermark.png"),
      quality: 80,
      gravity: "SouthWest",
      geometry: "+10+5",
      composite: true
    )
  end

  test ".convert with text" do
    File.mkdir_p!(@temp_test_directory)

    Magick.convert(
      src: @fixture,
      dist: get_dist_path("output_with_text.png"),
      gravity: "SouthWest",
      draw: ~s(text +4,+4 'hello world测试图片')
    )
  end

  test ".convert with text with color" do
    File.mkdir_p!(@temp_test_directory)

    Magick.convert(
      src: @fixture,
      dist: get_dist_path("output_with_text_with_green_color.png"),
      fill: "#00ff00",
      gravity: "SouthWest",
      draw: ~s(text +4,+4 'hello world测试图片绿色')
    )
  end

  test ".convert with text with color and resize" do
    File.mkdir_p!(@temp_test_directory)

    Magick.convert(
      src: @fixture,
      dist: get_dist_path("output_with_text_with_green_color_520x680.png"),
      fill: "#00ff00",
      gravity: "SouthWest",
      resize: "520x680",
      draw: ~s(text +4,+4 'hello world测试图片绿色')
    )
  end

  defp get_dist_path(file_name) do
    Path.join(@temp_test_directory, file_name) |> Path.expand
  end
end
