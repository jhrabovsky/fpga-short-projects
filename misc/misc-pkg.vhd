library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

package misc_pkg is

    function log2c (N : integer) return integer; 

end misc_pkg;

package body misc_pkg is

    function log2c (N : integer) return integer is
        variable m, p : integer;
    begin
        m := 0;
        p := 1;
        
        while p < N loop
            m := m + 1;
            p := p * 2;
        end loop;
        
        return m;
    end log2c; 

end package body;
