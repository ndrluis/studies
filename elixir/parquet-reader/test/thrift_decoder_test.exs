defmodule ThriftDecoderTest do
  use ExUnit.Case
  doctest ThriftDecoder

  test "read field header" do
    assert ThriftDecoder.read_field_header(<<>>, 0) ==
             {:error, :empty_header}

    assert ThriftDecoder.read_field_header(<<0x00>>, 0) ==
             {:ok, :stop, <<>>}

    assert ThriftDecoder.read_field_header(<<0x00, 1, 2, 3>>, 0) ==
             {:ok, :stop, <<1, 2, 3>>}

    assert ThriftDecoder.read_field_header(<<0x15, 1, 2, 3>>, 0) ==
             {:ok, 1, :i32, <<1, 2, 3>>}

    assert ThriftDecoder.read_field_header(<<0x18, 1, 2, 3>>, 0) ==
             {:ok, 1, :binary, <<1, 2, 3>>}

    assert ThriftDecoder.read_field_header(<<0x1D>>, 0) ==
             {:error, {:unsupported_type, 13}}

    assert ThriftDecoder.read_field_header(<<0x05>>, 0) ==
             {:error, :long_form_not_supported}
  end
end
