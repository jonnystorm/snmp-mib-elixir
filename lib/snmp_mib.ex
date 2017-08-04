# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule SNMPMIB do
  @moduledoc """
  Provides SNMP object struct and supporting functions.
  """

  @type asn1_tag :: 0 | 1..6 | 9..11
  @type asn1_type
    :: :any
     | :boolean
     | :integer
     | :bit_string
     | :octet_string
     | :string
     | :null
     | :object_identifier
     | :real
     | :enumerated
     # Deprecated type obsoleted by RFC2851; maps to asn1
     # "s" instead of "a" now
     | :ipaddress
     # Backwards compatibility for asn1 "a" (:ipv4address)
     # type used by Brocade Foundry/ICX switches
     | :ipv4address

  @type oid :: [non_neg_integer]

  @type object_value
    :: String.t
     | number
     | nil

  defmodule Object do
    @moduledoc """
    Defines struct and interface for storing and
    manipulating SNMP OID, type, and value data.
    """
    defstruct [:oid, :type, :value]

    @type t :: %Object{
        oid: SNMPMIB.oid,
       type: SNMPMIB.asn1_tag,
      value: SNMPMIB.object_value
    }

    @doc """
    Returns OID of `object`.
    """
    def oid(object) do
      object.oid
    end

    @doc """
    Returns copy of `object` with OID of `new_value`.
    """
    def oid(object, new_value) when is_list new_value do
      %Object{object | oid: new_value}
    end

    @doc """
    Returns type of `object`.
    """
    def type(object) do
      object.type
    end

    @doc """
    Returns copy of `object` with type of `new_type`.
    """
    def type(object, new_type) when is_atom new_type do
      %Object{object | type: new_type}
    end

    @doc """
    Returns value of `object`.
    """
    def value(object) do
      object.value
    end

    @doc """
    Returns copy of `object` with value of `new_value`.
    """
    def value(object, new_value)
        when is_number(new_value)
          or is_binary(new_value)
    do
      %Object{object | value: new_value}
    end
  end

  @doc """
  Constructs new `NetSNMP.Object` struct.
  """
  @spec object(
    oid | String.t,
    asn1_type | asn1_tag,
    object_value
  ) :: Object.t
  def object(oid, type, value)
      when is_binary(value)
       and type == :integer
  do
    object(oid, type, String.to_integer(value))
  end
  def object(oid, type, value) when is_binary oid do
    object(string_oid_to_list(oid), type, value)
  end
  def object(oid, type, value) when is_atom type do
    object(oid, type_to_asn1_tag(type), value)
  end
  def object(oid, type, value) do
    %Object{oid: oid, type: type, value: value}
  end

  @doc """
  Appends `index` to OID of `object`.
  """
  @spec index(Object.t, non_neg_integer)
    :: Object.t
  def index(object, index) when is_integer index do
    indexed_oid = Object.oid(object) ++ [index]

    Object.oid(object, indexed_oid)
  end

  @doc """
  Converts `list_oid` to dot-delimited string.
  """
  @spec list_oid_to_string([non_neg_integer])
    :: String.t
  def list_oid_to_string(list_oid) do
    Enum.join list_oid, "."
  end

  @doc """
  Converts dot-delimited `string_oid` string to list.
  """
  @spec string_oid_to_list(String.t)
    :: [non_neg_integer]
  def string_oid_to_list(string_oid) do
    string_oid
    |> String.trim(".")
    |> :binary.split(".", [:global])
    |> Enum.map(&String.to_integer(&1))
  end

  @doc """
  Converts ASN.1 tag number to Net-SNMP type character.
  """
  def asn1_tag_to_type_char(type) do
    %{ 0 => "=",
       1 => "i",
       2 => "i",
       3 => "s",
       4 => "s",
       5 => "=",
       6 => "o",
       9 => "d",
      10 => "i",
      # Backwards compatibility for asn1 "a" (:ipv4address)
      # type used by Brocade Foundry/ICX switches
      11 => "a",
    } |> Map.fetch!(type)
  end

  @doc """
  Converts Net-SNMP type name to ASN.1 tag number.
  """
  def type_to_asn1_tag(type) do
    %{any:               0,
      boolean:           1,
      integer:           2,
      counter:           2,
      counter32:         2,
      counter64:         2,
      gauge32:           2,
      gauge64:           2,
      timeticks:         2,
      bit_string:        3,
      octet_string:      4,
      string:            4,
      hex_string:        4,
      network_address:   4,
      # IpAddress type obsoleted by RFC2851
      ipaddress:         4,
      null:              5,
      object_identifier: 6,
      oid:               6,
      real:              9,
      enumerated:       10,
      # Backwards compatibility for asn1 "a" (:ipv4address)
      # type used by Brocade Foundry/ICX switches
      ipv4address:      11,
    } |> Map.fetch!(type)
  end
end

defimpl String.Chars, for: SNMPMIB.Object do
  import Kernel, except: [to_string: 1]

  def to_string(object) do
    oid =
      object
      |> SNMPMIB.Object.oid
      |> SNMPMIB.list_oid_to_string

    type =
      object
      |> SNMPMIB.Object.type
      |> SNMPMIB.asn1_tag_to_type_char

    value = SNMPMIB.Object.value object

    "#{oid} #{type} #{value}"
  end
end
