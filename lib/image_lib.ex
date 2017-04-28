defmodule ImageLib do
  @moduledoc """
  Documentation for ImageLib.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ImageLib.hello
      :world

  """
  def hello do
    :world
  end

  @logger Application.get_env(:image_lib, :logger, ImageLib.Util.Logger)

  defdelegate log_debug(info \\ nil, opts \\ []), to: @logger
  defdelegate log_info(info \\ nil, opts \\ []), to: @logger
  defdelegate log_warn(info \\ nil, opts \\ []), to: @logger
  defdelegate log_error(info \\ nil, opts \\ []), to: @logger
  defdelegate log_inspect(info \\ nil, opts \\ []), to: @logger
  def log(info \\ nil, opts \\ []) do
    case Logger.level do
      :debug -> log_debug(info, opts)
      :info  -> log_info(info, opts)
      :warn  -> log_warn(info, opts)
      :error -> log_error(info, opts)
      _ -> log_debug(info, opts)
    end
  end
end
