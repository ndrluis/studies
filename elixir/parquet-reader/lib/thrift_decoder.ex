defmodule ThriftDecoder do
  def read_field_header(<<>>, _) do
    {:error, :empty_header}
  end

  def read_field_header(binary, last_field_id) do
    <<header_byte, rest::binary>> = binary
    type_id = Bitwise.band(header_byte, 0x0F)
    field_type = field_type(type_id)
    delta = Bitwise.bsr(header_byte, 4)

    case {field_type, delta} do
      {:stop, _} -> {:ok, field_type, rest}
      {:unsupported_type, _} -> {:error, {:unsupported_type, type_id}}
      {_, 0} -> {:error, :long_form_not_supported}
      {_, _} -> {:ok, last_field_id + delta, field_type, rest}
    end
  end

  def field_type(field_id) do
    case field_id do
      0 -> :stop
      1 -> :bool_true
      2 -> :bool_false
      3 -> :byte
      4 -> :i16
      5 -> :i32
      6 -> :i64
      7 -> :double
      8 -> :binary
      9 -> :list
      10 -> :set
      11 -> :map
      12 -> :struct
      _ -> :unsupported_type
    end
  end
end
