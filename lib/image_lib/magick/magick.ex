defmodule ImageLib.Magick do

  alias ImageLib.Magick.Image

  @default_font Path.join(__DIR__, "../../../priv/font/JDJSTE.TTF") |> Path.expand
  @convert_normalized_args [
    :colorspace,    # 颜色空间
    :sample,        # 马赛克
    :charcoal,      # 手绘效果
    :contrast,      # 饱和度
    :blur,          # 模糊
    :"motion-blur", # 运动模糊
    :strip,         # 去掉extif
    :flatten,       # gif图片转jpg有用
    :mosiac,
    :"auto-orient", # 自动方向
    :geometry,
    :composite,     # true/false
    :quality,       # 图片质量
    :resize,        # 重新设置大小
    :flop,          # 水平翻转
    :flip,          # 垂直翻转
    :background,    # 设置背景, 透明色：transparent
    :gravity,       # 坐标系, center, SouthEast, NorthEast
    :extent,        # 画布大小，300x300
    :alpha,         # 设置为透明：Set
    :trim,          # 是否减去白边 true/false,
    :border,        # 边框
    :bordercolor,   # 边框颜色,
    :crop,          # 图片裁剪
    :sharpen,       # 锐化
    :shadow,        # 阴影
    :font,          # 参数为设置文字字体，值为字体文件的路径
    :fill,          # 设置文字颜色
    :pointsize      # 设置字体大小，单位为像素
  ]

  @moduledoc """
  ImageMagic方法库: <https://imagemagick.cn/#!convert.md>
  * 格式转换
  * 尺寸调整
  * 图片旋转、翻转
  * 背景设置
  * 去除白边与边框填充
  * 图片裁剪
  * 图片拼接
  * 图片、文本叠加
  * 滤镜

  url:
  * <http://www.imagemagick.org/Usage/photos/>
  """

  def open(path) do
    path = Path.expand(path)
    unless File.regular?(path), do: raise(File.Error)
    %Image{path: path, ext: Path.extname(path)}
  end

  defdelegate identify(opts \\ []), to: ImageLib.Identify

  @doc """
  图片转换操作
  ```
  opts:
  * src     原图片地址
  * dist    目标图片地址
  * quality  图片质量，大小在 1-100
  ```
  """
  def convert(opts) when is_list(opts) do
    args = []

    args = args |> List.insert_at(-1, Keyword.get(opts, :src, ""))

    # -gravity  设置坐标，
    # -geometry 设置坐标偏移量，+5+6为x轴向内偏移5像素，y轴向内偏移6像素，
    #           需要向外偏移请使用负号，如 -10-20，超出原始图片的部分将会被裁剪
    args =
      if watermark = Keyword.get(opts, :watermark) do
        args |> List.insert_at(-1, "#{watermark}")
      else
        args
      end

    opts =
      if Keyword.get(opts, :draw) do
        opts
        |> Keyword.put(:pointsize, Keyword.get(opts, :pointsize, 12))
        |> Keyword.put(:font, Keyword.get(opts, :font, @default_font))
        |> Keyword.put(:fill, Keyword.get(opts, :fill, "black"))
      else
        opts
      end

    normalized_args =
      opts
      |> Keyword.take(@convert_normalized_args)
      |> Enum.map(fn({key, value}) ->
        normalize_args(key, value, "-")
      end)

    normalized_args_add =
      opts
      |> Keyword.take([
        :repeat,   # 是否重复，true/false
      ])
      |> Enum.map(fn({key, value}) ->
        normalize_args(key, value, "+")
      end)

    normalized_args_origin =
      opts
      |> Keyword.take([
        :"-append",
        :"+append",
        :"+noise",    # Gaussian（高斯）,Impulse（兴起）, Laplacian（拉普拉斯）,
                      # Multiplicative（相乘）,Poisson（泊松）, Random（随机）,Uniform（统一）
        :"-noise",
      ])
      |> Enum.map(fn({key, value}) ->
        normalize_args(key, value, "")
      end)

    normalized_args_origin =
      if args_draw = Keyword.get(opts, :draw) do
        normalized_args_origin ++ ["-draw", args_draw]
      else
        normalized_args_origin
      end

    normalized_args_origin = normalized_args_origin ++ Keyword.get(opts, :origins, [])

    dist =
      if dist_format = Keyword.get(opts, :dist_format, nil) do
        "#{dist_format}:#{Keyword.get(opts, :dist, nil)}"
      else
        "#{Keyword.get(opts, :dist, nil)}"
      end

    args =
      (args ++ normalized_args ++ normalized_args_add ++ normalized_args_origin)
      |> List.insert_at(-1, dist)
      |> List.flatten

    system_cmd("convert", args, stderr_to_stdout: true)
  end

  def system_cmd(command, args, opts \\ []) do
    args = args |> Enum.map(fn(arg) -> "#{arg}" end)
    start_at = Timex.now
    log_string = [command, Enum.join(args, " ")] |> Enum.join(" ")

    ["start: #{log_string} with options: #{inspect(opts)}"]
    |> normalize_logger_args
    |> ImageLib.log_debug(pretty: false)

    result = System.cmd(command, args, opts)

    ["finish: #{log_string} with options: #{inspect(opts)} in #{Timex.diff(Timex.now, start_at) / 1000}ms"]
    |> normalize_logger_args
    |> ImageLib.log_debug(pretty: false)

    result
  end

  defp normalize_logger_args(args) do
    args
  end

  defp normalize_args(key, value, flag) do
    cond do
      !value -> []
      is_boolean(value) ->
        ["#{flag}#{key}"]
      true ->
        ["#{flag}#{key}", "#{value}"]
    end
 end
end
