defmodule ImageLib.Magick.Image do

  @type path        :: binary
  @type size        :: integer
  @type ext         :: binary
  @type format      :: binary
  @type mime_type   :: mime_type
  @type width       :: integer
  @type height      :: integer
  @type animated    :: boolean
  @type frame_count :: integer
  @type operations  :: Keyword.t
  @type dirty       :: %{atom => any}

  @type t :: %__MODULE__{
    size:        size,
    path:        path,
    ext:         ext,
    format:      format,
    mime_type:   mime_type,
    width:       width,
    height:      height,
    animated:    animated,
    frame_count: frame_count,
    operations:  operations,
    dirty:       dirty
  }

  defstruct path: nil,
    size:         nil,
    ext:          nil,
    format:       nil,
    mime_type: nil,
    width:        nil,
    height:       nil,
    animated:     false,
    frame_count:  1,
    operations:   [],
    dirty:        %{}

end
