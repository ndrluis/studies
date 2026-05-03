defmodule ParquetReader do
  def read(path) do
    {:ok, file} = File.open(path, [:read])

    size = file_size(path)

    offset = max(size - 64, 0)

    {:ok, tail_binary} = :file.pread(file, offset, 64)

    {:ok, footer_length} = parquet?(tail_binary)

    # 4 bytes for the footer length
    # 4 bytes for the PAR1
    footer_start = size - 8 - footer_length

    {:ok, footer} = :file.pread(file, footer_start, footer_length)
    footer
  end

  def file_size(path) do
    {:ok, %File.Stat{size: size}} = File.stat(path)

    size
  end

  def parquet?(tail_binary) when byte_size(tail_binary) < 8 do
    {:error, :too_small}
  end

  def parquet?(tail_binary) do
    prefix_size = byte_size(tail_binary) - 8

    case tail_binary do
      <<_::binary-size(prefix_size), footer_length::little-32, "PAR1">> -> {:ok, footer_length}
      _ -> {:error, :not_parquet}
    end
  end
end
