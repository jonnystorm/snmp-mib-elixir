# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule SNMPMIB do
  @type asn1_tag :: 0 | 1..6 | 9..10
  @type asn1_type :: :any|:boolean|:integer|:bit_string|:octet_string|:string|:null|:object_identifier|:real|:enumerated

  defmodule Object do
    defstruct oid: nil, type: nil, value: nil

    @type t :: %Object{
      oid: [non_neg_integer],
      type: SNMPMIB.asn1_tag,
      value: String.t | number
    }
    
    def oid(object) do
      object.oid
    end

    def oid(object, new_value) when is_list new_value do
      %Object{object|oid: new_value}
    end

    def type(object) do
      object.type
    end

    def type(object, new_type) when is_atom new_type do
      %Object{object|type: new_type}
    end
    
    def value(object) do
      object.value
    end

    def value(object, new_value)
        when is_number(new_value) or is_binary(new_value) do

      %Object{object | value: new_value}
    end
  end

  @spec object(String.t, asn1_type, String.t | number) :: Object.t
  def object(oid, type, value) when is_binary(value) and type == :integer do
    object oid, type, String.to_integer(value)
  end
  def object(oid, type, value) when is_binary oid do
    object string_oid_to_list(oid), type, value
  end
  def object(oid, type, value) when is_atom type do
    object oid, type_to_asn1_tag(type), value
  end
  def object(oid, type, value) do
    %Object{oid: oid, type: type, value: value}
  end

  @spec index(Object.t, pos_integer) :: Object.t
  def index(object, index) when is_integer index do
    indexed_oid = Object.oid(object) ++ [index]

    Object.oid object, indexed_oid
  end

  def list_oid_to_string(list_oid) do
    list_oid |> Enum.join(".")
  end

  def string_oid_to_list(string_oid) do
    string_oid
      |> String.strip(?.)
      |> :binary.split(".", [:global])
      |> Enum.map(&String.to_integer(&1))
  end

  def asn1_tag_to_type_char(type) do
    %{0 => "=",
      1 => "i",
      2 => "i",
      3 => "s",
      4 => "s",
      5 => "=",
      6 => "o",
      9 => "d",
      10 => "i"
    } |> Map.fetch!(type)
  end

  def type_to_asn1_tag(type) do
    %{any: 0,
      boolean: 1,
      integer: 2, counter: 2, counter32: 2, counter64: 2, gauge32: 2, gauge64: 2,
      bit_string: 3,
      octet_string: 4, string: 4, timeticks: 4,
      ipaddress: 4,  # IpAddress type obsoleted by RFC2851
      null: 5,
      object_identifier: 6, oid: 6,
      real: 9,
      enumerated: 10
    } |> Map.fetch!(type)
  end
end

defimpl String.Chars, for: SNMPMIB.Object do
  import Kernel, except: [to_string: 1]

  def to_string(object) do
    [ object |> SNMPMIB.Object.oid |> SNMPMIB.list_oid_to_string,
      object |> SNMPMIB.Object.type |> SNMPMIB.asn1_tag_to_type_char,
      object |> SNMPMIB.Object.value
    ] |> Enum.join " "
  end
end
