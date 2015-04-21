# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule SNMPMIBTest do  
  use ExUnit.Case, async: true

  test "list_oid_to_string returns correct string" do
    assert SNMPMIB.list_oid_to_string([1,3,6,0,9,20,1]) == "1.3.6.0.9.20.1"
  end

  test "string_oid_to_list returns correct list" do
    assert SNMPMIB.string_oid_to_list("1.3.6.0.9.20.1") == [1,3,6,0,9,20,1]
  end
  test "string_oid_to_list returns correct list from OID with leading dot" do
    assert SNMPMIB.string_oid_to_list(".1.3.6.0.9.20.1") == [1,3,6,0,9,20,1]
  end
  test "string_oid_to_list returns correct list from OID with trailing dot" do
    assert SNMPMIB.string_oid_to_list("1.3.6.0.9.20.1.") == [1,3,6,0,9,20,1]
  end
  test "string_oid_to_list returns correct list from OID with leading/trailing dots" do
    assert SNMPMIB.string_oid_to_list(".1.3.6.0.9.20.1.") == [1,3,6,0,9,20,1]
  end

  test "object returns correct SNMP.Object with integer" do
    assert SNMPMIB.object("1.3.6.0.9.20.1", :integer, 1) ==
      %SNMPMIB.Object{
        oid: [1,3,6,0,9,20,1],
        type: 2,
        value: 1
      }
  end
  test "object returns correct SNMP.Object with octet_string" do
    assert SNMPMIB.object("1.3.6.0.9.20.1", :octet_string, "") ==
      %SNMPMIB.Object{
        oid: [1,3,6,0,9,20,1],
        type: 4,
        value: ""
      }
  end
  test "object fails for invalid type" do
    assert_raise KeyError, fn ->
      SNMPMIB.object("1.3.6.0.9.20.1", :blarg, 1)
    end
  end

  test "to_string returns correct string for Object of type integer" do
    assert to_string(SNMPMIB.object("1.3.6.0.9.20.1", :integer, 1))
      == "1.3.6.0.9.20.1 i 1"
  end
  test "to_string returns correct string for Object of type octet string" do
    assert to_string(SNMPMIB.object("1.3.6.0.9.20.1", :octet_string, 1))
      == "1.3.6.0.9.20.1 s 1"
  end
end
