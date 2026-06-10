--------------------------------------------------------------------------------
--    PCIE2FPGA is a FPGA design that aims to demonstrate PCIe Gen2 x8
--    communication by implementing a DMA engine
--    
--    Copyright (C) 2014 HEIG-VD / REDS
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

package ilog_pkg is

  -- integer logarithm (rounded up) [MR version]
  function ilogup (x : natural; base : natural := 2) return natural;

  -- integer logarithm (rounded down) [MR version]
  function ilog (x : natural; base : natural := 2) return natural;
  
end package ilog_pkg; 
package body ilog_pkg is


  -- integer logarithm (rounded up) [MR version]
  function ilogup (x : natural; base : natural := 2) return natural is
    variable y : natural := 1;
  begin
    y:= 1;  --Mod EMI 26.03.2009
    while x > base ** y loop
      y := y + 1;
    end loop;
    return y;
  end ilogup;
  
  
  -- integer logarithm (rounded down) [MR version]
  function ilog (x : natural; base : natural := 2) return natural is
    variable y : natural := 1;
  begin
    y:= 1;  --Mod EMI 26.03.2009
    while x > base ** y loop
      y := y + 1;
    end loop;
    if x<base**y then
    	y:=y-1;
    end if;
    return y;
  end ilog;
  
end package body ilog_pkg;
