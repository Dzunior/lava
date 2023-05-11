--------------------------------------------------------------------------------
--  File Name: m28w320cb.vhd
--------------------------------------------------------------------------------
--  Copyright (C) 2002, 2003 Free Model Foundry; http://www.FreeModelFoundry.com
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License version 2 as
--  published by the Free Software Foundation.
--
--  MODIFICATION HISTORY:
--
--  version: |  author:       | mod date: | changes made:
--    V1.0    M. Marinkovic    02 NOV 02   Initial release
--    V1.1    R. Munden        03 FEB 15   Changed type of some _nwv signals to
--                                         satisfy ncvhdl
--------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Library:    FLASH MEMORY
--  Technology: CMOS
--  Part:       m28w320cb
--
--  Description: 32 Mbit (2Mb x16, Boot Block) Flash Memory
--
--------------------------------------------------------------------------------

LIBRARY IEEE;   USE IEEE.std_logic_1164.ALL;
                USE IEEE.VITAL_timing.ALL;
                USE IEEE.VITAL_primitives.ALL;
                USE STD.textio.ALL;
LIBRARY FMF;    USE FMF.gen_utils.ALL;
                USE FMF.conversions.ALL;

--------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------
ENTITY m28w320cb IS
    GENERIC (
        -- tipd delays: interconnect path delays
        tipd_A0                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A1                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A2                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A3                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A4                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A5                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A6                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A7                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A8                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A9                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A10                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A11                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A12                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A13                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A14                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A15                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A16                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A17                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A18                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A19                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A20                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_D0                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D1                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D2                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D3                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D4                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D5                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D6                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D7                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D8                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D9                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_D10                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_D11                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_D12                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_D13                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_D14                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_D15                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_CENeg               : VitalDelayType01 := VitalZeroDelay01;
        tipd_OENeg               : VitalDelayType01 := VitalZeroDelay01;
        tipd_WENeg               : VitalDelayType01 := VitalZeroDelay01;
        tipd_RPNeg               : VitalDelayType01 := VitalZeroDelay01;
        tipd_WPNeg               : VitalDelayType01 := VitalZeroDelay01;
        tipd_VPP                 : VitalDelayType01 := VitalZeroDelay01;
        -- tpd delays
        tpd_A0_D0                : VitalDelayType01 := UnitDelay01;
        tpd_CENeg_D0             : VitalDelayType01Z := UnitDelay01Z;
        tpd_OENeg_D0             : VitalDelayType01Z := UnitDelay01Z;
        tpd_RPNeg_D0             : VitalDelayType01Z := UnitDelay01Z;
        -- tpw values: pulse widths
        tpw_WENeg_negedge        : VitalDelayType := UnitDelay;
        tpw_WENeg_posedge        : VitalDelayType := UnitDelay;
        tpw_RPNeg                : VitalDelayType := UnitDelay;
        -- tsetup values
        tsetup_CENeg_WENeg       : VitalDelayType := UnitDelay; --low
        tsetup_D0_WENeg          : VitalDelayType := UnitDelay; --high
        tsetup_A0_WENeg          : VitalDelayType := UnitDelay; --high
        tsetup_VPP_WENeg         : VitalDelayType := UnitDelay; --high
        tsetup_WPNeg_WENeg       : VitalDelayType := UnitDelay; --high
        -- thold values
        thold_CENeg_WENeg        : VitalDelayType := UnitDelay; -- high
        thold_D0_WENeg           : VitalDelayType := UnitDelay; -- high
        thold_A0_WENeg           : VitalDelayType := UnitDelay; -- high
        -- trecovery values          WRITE
        trecovery_RPNeg_WENeg    : VitalDelayType := UnitDelay;
        trecovery_WENeg_OENeg    : VitalDelayType := UnitDelay;

        -- generic control parameters
        InstancePath        : STRING    := DefaultInstancePath;
        TimingChecksOn      : BOOLEAN   := DefaultTimingChecks;
        MsgOn               : BOOLEAN   := DefaultMsgOn;
        XOn                 : BOOLEAN   := DefaultXon;
        -- memory file to be loaded
        mem_file_name       : STRING    := "none";       
        -- For FMF SDF technology file usage
        TimingModel         : STRING    := DefaultTimingModel
    );
    PORT (
        A20             : IN    std_logic := 'L';
        A19             : IN    std_logic := 'L';
        A18             : IN    std_logic := 'L';
        A17             : IN    std_logic := 'L';
        A16             : IN    std_logic := 'L';
        A15             : IN    std_logic := 'L';
        A14             : IN    std_logic := 'L';
        A13             : IN    std_logic := 'L';
        A12             : IN    std_logic := 'L';
        A11             : IN    std_logic := 'L';
        A10             : IN    std_logic := 'L';
        A9              : IN    std_logic := 'L';
        A8              : IN    std_logic := 'L';
        A7              : IN    std_logic := 'L';
        A6              : IN    std_logic := 'L';
        A5              : IN    std_logic := 'L';
        A4              : IN    std_logic := 'L';
        A3              : IN    std_logic := 'L';
        A2              : IN    std_logic := 'L';
        A1              : IN    std_logic := 'L';
        A0              : IN    std_logic := 'L';

        D15             : INOUT std_logic := 'L';
        D14             : INOUT std_logic := 'L';
        D13             : INOUT std_logic := 'L';
        D12             : INOUT std_logic := 'L';
        D11             : INOUT std_logic := 'L';
        D10             : INOUT std_logic := 'L';
        D9              : INOUT std_logic := 'L';
        D8              : INOUT std_logic := 'L';
        D7              : INOUT std_logic := 'L';
        D6              : INOUT std_logic := 'L';
        D5              : INOUT std_logic := 'L';
        D4              : INOUT std_logic := 'L';
        D3              : INOUT std_logic := 'L';
        D2              : INOUT std_logic := 'L';
        D1              : INOUT std_logic := 'L';
        D0              : INOUT std_logic := 'L';

        CENeg           : IN    std_logic := 'H';
        OENeg           : IN    std_logic := 'H';
        WENeg           : IN    std_logic := 'H';
        RPNeg          : IN    std_logic := 'H';
        WPNeg           : IN    std_logic := 'H';
        VPP             : IN    std_logic := 'H'
    );
    ATTRIBUTE VITAL_LEVEL0 of m28w320cb : ENTITY IS TRUE;
END m28w320cb;

--------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
--------------------------------------------------------------------------------
ARCHITECTURE vhdl_behavioral of m28w320cb IS
    ATTRIBUTE VITAL_LEVEL0 of vhdl_behavioral : ARCHITECTURE IS TRUE;

    CONSTANT PartID         : STRING := "m28w320cb";
    CONSTANT MaxData        : NATURAL := 16#FFFF#; --65536;
    CONSTANT MemSize        : NATURAL := 16#1FFFFF#;

-- ipd
    SIGNAL A20_ipd         : std_ulogic := 'U';
    SIGNAL A19_ipd         : std_ulogic := 'U';
    SIGNAL A18_ipd         : std_ulogic := 'U';
    SIGNAL A17_ipd         : std_ulogic := 'U';
    SIGNAL A16_ipd         : std_ulogic := 'U';
    SIGNAL A15_ipd         : std_ulogic := 'U';
    SIGNAL A14_ipd         : std_ulogic := 'U';
    SIGNAL A13_ipd         : std_ulogic := 'U';
    SIGNAL A12_ipd         : std_ulogic := 'U';
    SIGNAL A11_ipd         : std_ulogic := 'U';
    SIGNAL A10_ipd         : std_ulogic := 'U';
    SIGNAL A9_ipd          : std_ulogic := 'U';
    SIGNAL A8_ipd          : std_ulogic := 'U';
    SIGNAL A7_ipd          : std_ulogic := 'U';
    SIGNAL A6_ipd          : std_ulogic := 'U';
    SIGNAL A5_ipd          : std_ulogic := 'U';
    SIGNAL A4_ipd          : std_ulogic := 'U';
    SIGNAL A3_ipd          : std_ulogic := 'U';
    SIGNAL A2_ipd          : std_ulogic := 'U';
    SIGNAL A1_ipd          : std_ulogic := 'U';
    SIGNAL A0_ipd          : std_ulogic := 'U';

    SIGNAL D15_ipd         : std_ulogic := 'U';
    SIGNAL D14_ipd         : std_ulogic := 'U';
    SIGNAL D13_ipd         : std_ulogic := 'U';
    SIGNAL D12_ipd         : std_ulogic := 'U';
    SIGNAL D11_ipd         : std_ulogic := 'U';
    SIGNAL D10_ipd         : std_ulogic := 'U';
    SIGNAL D9_ipd          : std_ulogic := 'U';
    SIGNAL D8_ipd          : std_ulogic := 'U';
    SIGNAL D7_ipd          : std_ulogic := 'U';
    SIGNAL D6_ipd          : std_ulogic := 'U';
    SIGNAL D5_ipd          : std_ulogic := 'U';
    SIGNAL D4_ipd          : std_ulogic := 'U';
    SIGNAL D3_ipd          : std_ulogic := 'U';
    SIGNAL D2_ipd          : std_ulogic := 'U';
    SIGNAL D1_ipd          : std_ulogic := 'U';
    SIGNAL D0_ipd          : std_ulogic := 'U';

    SIGNAL CENeg_ipd       : std_ulogic := 'U';
    SIGNAL OENeg_ipd       : std_ulogic := 'U';
    SIGNAL WENeg_ipd       : std_ulogic := 'U';
    SIGNAL RPNeg_ipd       : std_ulogic := 'U';
    SIGNAL WPNeg_ipd       : std_ulogic := 'U';
    SIGNAL VPP_ipd         : std_ulogic := 'U';
-- nwv
    SIGNAL A20_nwv         : UX01 := 'U';
    SIGNAL A19_nwv         : UX01 := 'U';
    SIGNAL A18_nwv         : UX01 := 'U';
    SIGNAL A17_nwv         : UX01 := 'U';
    SIGNAL A16_nwv         : UX01 := 'U';
    SIGNAL A15_nwv         : UX01 := 'U';
    SIGNAL A14_nwv         : UX01 := 'U';
    SIGNAL A13_nwv         : UX01 := 'U';
    SIGNAL A12_nwv         : UX01 := 'U';
    SIGNAL A11_nwv         : UX01 := 'U';
    SIGNAL A10_nwv         : UX01 := 'U';
    SIGNAL A9_nwv          : UX01 := 'U';
    SIGNAL A8_nwv          : UX01 := 'U';
    SIGNAL A7_nwv          : UX01 := 'U';
    SIGNAL A6_nwv          : UX01 := 'U';
    SIGNAL A5_nwv          : UX01 := 'U';
    SIGNAL A4_nwv          : UX01 := 'U';
    SIGNAL A3_nwv          : UX01 := 'U';
    SIGNAL A2_nwv          : UX01 := 'U';
    SIGNAL A1_nwv          : UX01 := 'U';
    SIGNAL A0_nwv          : UX01 := 'U';

    SIGNAL D15_nwv         : UX01 := 'U';
    SIGNAL D14_nwv         : UX01 := 'U';
    SIGNAL D13_nwv         : UX01 := 'U';
    SIGNAL D12_nwv         : UX01 := 'U';
    SIGNAL D11_nwv         : UX01 := 'U';
    SIGNAL D10_nwv         : UX01 := 'U';
    SIGNAL D9_nwv          : UX01 := 'U';
    SIGNAL D8_nwv          : UX01 := 'U';
    SIGNAL D7_nwv          : UX01 := 'U';
    SIGNAL D6_nwv          : UX01 := 'U';
    SIGNAL D5_nwv          : UX01 := 'U';
    SIGNAL D4_nwv          : UX01 := 'U';
    SIGNAL D3_nwv          : UX01 := 'U';
    SIGNAL D2_nwv          : UX01 := 'U';
    SIGNAL D1_nwv          : UX01 := 'U';
    SIGNAL D0_nwv          : UX01 := 'U';

    SIGNAL CENeg_nwv       : std_ulogic := 'U';
    SIGNAL OENeg_nwv       : std_ulogic := 'U';
    SIGNAL WENeg_nwv       : std_ulogic := 'U';
    SIGNAL RPNeg_nwv       : std_ulogic := 'U';
    SIGNAL WPNeg_nwv       : std_ulogic := 'U';
    SIGNAL VPP_nwv         : std_ulogic := 'U';

BEGIN

    ----------------------------------------------------------------------------
    -- Wire Delays
    ----------------------------------------------------------------------------
    WireDelay : BLOCK
    BEGIN
        w_2  : VitalWireDelay (A20_ipd, A20, tipd_A20);
        w_3  : VitalWireDelay (A19_ipd, A19, tipd_A19);
        w_4  : VitalWireDelay (A18_ipd, A18, tipd_A18);
        w_5  : VitalWireDelay (A17_ipd, A17, tipd_A17);
        w_6  : VitalWireDelay (A16_ipd, A16, tipd_A16);
        w_7  : VitalWireDelay (A15_ipd, A15, tipd_A15);
        w_8  : VitalWireDelay (A14_ipd, A14, tipd_A14);
        w_9  : VitalWireDelay (A13_ipd, A13, tipd_A13);
        w_10 : VitalWireDelay (A12_ipd, A12, tipd_A12);
        w_11 : VitalWireDelay (A11_ipd, A11, tipd_A11);
        w_12 : VitalWireDelay (A10_ipd, A10, tipd_A10);
        w_13 : VitalWireDelay (A9_ipd, A9, tipd_A9);
        w_14 : VitalWireDelay (A8_ipd, A8, tipd_A8);
        w_15 : VitalWireDelay (A7_ipd, A7, tipd_A7);
        w_16 : VitalWireDelay (A6_ipd, A6, tipd_A6);
        w_17 : VitalWireDelay (A5_ipd, A5, tipd_A5);
        w_18 : VitalWireDelay (A4_ipd, A4, tipd_A4);
        w_19 : VitalWireDelay (A3_ipd, A3, tipd_A3);
        w_20 : VitalWireDelay (A2_ipd, A2, tipd_A2);
        w_21 : VitalWireDelay (A1_ipd, A1, tipd_A1);
        w_22 : VitalWireDelay (A0_ipd, A0, tipd_A0);

        w_33 : VitalWireDelay (D15_ipd, D15, tipd_D15);
        w_34 : VitalWireDelay (D14_ipd, D14, tipd_D14);
        w_35 : VitalWireDelay (D13_ipd, D13, tipd_D13);
        w_36 : VitalWireDelay (D12_ipd, D12, tipd_D12);
        w_37 : VitalWireDelay (D11_ipd, D11, tipd_D11);
        w_38 : VitalWireDelay (D10_ipd, D10, tipd_D10);
        w_39 : VitalWireDelay (D9_ipd, D9, tipd_D9);
        w_40 : VitalWireDelay (D8_ipd, D8, tipd_D8);
        w_41 : VitalWireDelay (D7_ipd, D7, tipd_D7);
        w_42 : VitalWireDelay (D6_ipd, D6, tipd_D6);
        w_43 : VitalWireDelay (D5_ipd, D5, tipd_D5);
        w_44 : VitalWireDelay (D4_ipd, D4, tipd_D4);
        w_45 : VitalWireDelay (D3_ipd, D3, tipd_D3);
        w_46 : VitalWireDelay (D2_ipd, D2, tipd_D2);
        w_47 : VitalWireDelay (D1_ipd, D1, tipd_D1);
        w_48 : VitalWireDelay (D0_ipd, D0, tipd_D0);
        w_50 : VitalWireDelay (OENeg_ipd, OENeg, tipd_OENeg);
        w_51 : VitalWireDelay (WENeg_ipd, WENeg, tipd_WENeg);
        w_52 : VitalWireDelay (RPNeg_ipd, RPNeg, tipd_RPNeg);
        w_53 : VitalWireDelay (WPNeg_ipd, WPNeg, tipd_WPNeg);
        w_55 : VitalWireDelay (VPP_ipd, VPP, tipd_VPP);
        w_57 : VitalWireDelay (CENeg_ipd, CENeg, tipd_CENeg);

    END BLOCK;
 -- sig_nwv <= To_UX01(sig_ipd);
    A20_nwv         <= To_UX01(A20_ipd);
    A19_nwv         <= To_UX01(A19_ipd);
    A18_nwv         <= To_UX01(A18_ipd);
    A17_nwv         <= To_UX01(A17_ipd);
    A16_nwv         <= To_UX01(A16_ipd);
    A15_nwv         <= To_UX01(A15_ipd);
    A14_nwv         <= To_UX01(A14_ipd);
    A13_nwv         <= To_UX01(A13_ipd);
    A12_nwv         <= To_UX01(A12_ipd);
    A11_nwv         <= To_UX01(A11_ipd);
    A10_nwv         <= To_UX01(A10_ipd);
    A9_nwv          <= To_UX01(A9_ipd);
    A8_nwv          <= To_UX01(A8_ipd);
    A7_nwv          <= To_UX01(A7_ipd);
    A6_nwv          <= To_UX01(A6_ipd);
    A5_nwv          <= To_UX01(A5_ipd);
    A4_nwv          <= To_UX01(A4_ipd);
    A3_nwv          <= To_UX01(A3_ipd);
    A2_nwv          <= To_UX01(A2_ipd);
    A1_nwv          <= To_UX01(A1_ipd);
    A0_nwv          <= To_UX01(A0_ipd);

    D15_nwv         <= To_UX01(D15_ipd);
    D14_nwv         <= To_UX01(D14_ipd);
    D13_nwv         <= To_UX01(D13_ipd);
    D12_nwv         <= To_UX01(D12_ipd);
    D11_nwv         <= To_UX01(D11_ipd);
    D10_nwv         <= To_UX01(D10_ipd);
    D9_nwv          <= To_UX01(D9_ipd);
    D8_nwv          <= To_UX01(D8_ipd);
    D7_nwv          <= To_UX01(D7_ipd);
    D6_nwv          <= To_UX01(D6_ipd);
    D5_nwv          <= To_UX01(D5_ipd);
    D4_nwv          <= To_UX01(D4_ipd);
    D3_nwv          <= To_UX01(D3_ipd);
    D2_nwv          <= To_UX01(D2_ipd);
    D1_nwv          <= To_UX01(D1_ipd);
    D0_nwv          <= To_UX01(D0_ipd);

    CENeg_nwv       <= To_UX01(CENeg_ipd);
    OENeg_nwv       <= To_UX01(OENeg_ipd);
    WENeg_nwv       <= To_UX01(WENeg_ipd);
    RPNeg_nwv       <= To_UX01(RPNeg_ipd);
    WPNeg_nwv       <= To_UX01(WPNeg_ipd);
    VPP_nwv         <= To_UX01(VPP_ipd);

    ----------------------------------------------------------------------------
    -- Main Behavior Block
    ----------------------------------------------------------------------------
    Behavior: BLOCK

        PORT (
            A              : IN    std_logic_vector(20 downto 0) :=
                                               (OTHERS => 'U');
            DIn            : IN    std_logic_vector(15 downto 0) :=
                                               (OTHERS => 'U');
            DOut           : OUT   std_logic_vector(15 downto 0) :=
                                               (OTHERS => 'Z');
            CENeg          : IN    std_ulogic := 'U';
            OENeg          : IN    std_ulogic := 'U';
            WENeg          : IN    std_ulogic := 'U';
            RPNeg          : IN    std_ulogic := 'U';
            WPNeg          : IN    std_ulogic := 'U';
            VPP            : IN    std_ulogic := 'U'
        );
        PORT MAP (
             A(20) => A20_nwv,
             A(19) => A19_nwv,
             A(18) => A18_nwv,
             A(17) => A17_nwv,
             A(16) => A16_nwv,
             A(15) => A15_nwv,
             A(14) => A14_nwv,
             A(13) => A13_nwv,
             A(12) => A12_nwv,
             A(11) => A11_nwv,
             A(10) => A10_nwv,
             A(9) => A9_nwv,
             A(8) => A8_nwv,
             A(7) => A7_nwv,
             A(6) => A6_nwv,
             A(5) => A5_nwv,
             A(4) => A4_nwv,
             A(3) => A3_nwv,
             A(2) => A2_nwv,
             A(1) => A1_nwv,
             A(0) => A0_nwv,

             DIn(15) => D15_nwv,
             DIn(14) => D14_nwv,
             DIn(13) => D13_nwv,
             DIn(12) => D12_nwv,
             DIn(11) => D11_nwv,
             DIn(10) => D10_nwv,
             DIn(9) => D9_nwv,
             DIn(8) => D8_nwv,
             DIn(7) => D7_nwv,
             DIn(6) => D6_nwv,
             DIn(5) => D5_nwv,
             DIn(4) => D4_nwv,
             DIn(3) => D3_nwv,
             DIn(2) => D2_nwv,
             DIn(1) => D1_nwv,
             DIn(0) => D0_nwv,

             DOut(15) => D15,
             DOut(14) => D14,
             DOut(13) => D13,
             DOut(12) => D12,
             DOut(11) => D11,
             DOut(10) => D10,
             DOut(9) => D9,
             DOut(8) => D8,
             DOut(7) => D7,
             DOut(6) => D6,
             DOut(5) => D5,
             DOut(4) => D4,
             DOut(3) => D3,
             DOut(2) => D2,
             DOut(1) => D1,
             DOut(0) => D0,

             CENeg   => CENeg_nwv,
             OENeg   => OENeg_nwv,
             WENeg   => WENeg_nwv,
             RPNeg   => RPNeg_nwv,
             WPNeg   => WPNeg_nwv,
             VPP     => VPP_nwv
        );

        -- State Machine : State_Type
        TYPE state_type IS (
                        READ_ARRAY,--
                        READ_STATUS,--
                        READ_CONFIG,--
                        READ_QUERY,--
                        LOCK_SETUP,--
                        BOTCH_LOCK,--
                        BOTCH_LOCK_ERS_SUSP,--
                        LOCK_DONE,
                        LOCK_SETUP_ERS_SUSP,--
                        LOCK_DONE_ERS_SUSP,
                        PROT_PROG_SETUP,--
                        PROT_PROG_BUSY,--
                        PROT_PROG_DONE,--
                        PROG_SETUP,--
                        DOUBLE_WORD,
                        DOUBLE_WORD_ERS_SUSP,
                        PROG_SETUP_ERS_SUSP,--
                        PROG_BUSY,--
                        PROG_BUSY_ERS_SUSP,--
                        READ_STATUS_PROG_SUSP,--
                        READ_ARRAY_PROG_SUSP,--
                        READ_CONFIG_PROG_SUSP,--
                        READ_QUERY_PROG_SUSP,--
                        PROGRAM_DONE,--
                        PROGRAM_DONE_ERS_SUSP,--
                        ERASE_SETUP,--
                        BOTCH_ERS,--
                        ERASE_BUSY,--
                        READ_STATUS_ERS_SUSP,--
                        READ_ARRAY_ERS_SUSP,--
                        READ_CONFIG_ERS_SUSP,--
                        READ_QUERY_ERS_SUSP,--
                        ERASE_DONE--
                             );
        -- states
        SIGNAL current_state    : state_type;  --
        SIGNAL next_state       : state_type;  --

        --zero delay signals
        SIGNAL DOut_zd          : std_logic_vector(15 downto 0):=(OTHERS=>'Z');

        -- Status Register
        SIGNAL S_Reg            : std_logic_vector(7 downto 0) :=
                                                "10000000";-- 0x80
              --Block Lock Status
        SIGNAL Lock_Down        : std_logic_vector (71 downto 0) :=
                                                 (OTHERS => '0');

        SIGNAL Block_Lock       : std_logic_vector (71 downto 0) :=
                                                 (OTHERS => '1');

        SIGNAL WDone            : boolean := FALSE;

        SIGNAL EDone            : boolean := FALSE;

        SIGNAL ECount           : integer RANGE 0 TO 31 :=0;

        SIGNAL DWord_cycle      : boolean := false;
        SIGNAL DWord_addr       : std_logic_vector(20 downto 0);

        -- timing check violation
        SIGNAL Viol             : X01 := '0';


    BEGIN

    -- clocked process for reset and FSM state transition
    -- on RSTNeg='0' device is in reset
    -- on CENeg='1' device is in standby mode

PROCESS(RPNeg, CENeg, next_state)
    BEGIN
        IF RPNeg='0' OR CENeg='1' THEN
            current_state<=READ_ARRAY;      -- reset
        ELSE
            current_state <= next_state;
        END IF;

END PROCESS;


    ----------------------------------------------------------------------------
    -- Main Behavior Process
    -- combinational process for next state generation
    ----------------------------------------------------------------------------
    VITALBehaviour: PROCESS(A, Din, CENeg, OENeg, WENeg, RPNeg, WPNeg,
                        VPP,WDone, S_Reg,EDone, ECount, DWord_cycle,DWord_addr)
         -- Timing Check Variables
        VARIABLE Tviol_CENeg_WENeg : X01 := '0';
        VARIABLE TD_CENeg_WENeg    : VitalTimingDataType;

        VARIABLE Tviol_D0_WENeg    : X01 := '0';
        VARIABLE TD_D0_WENeg       : VitalTimingDataType;

        VARIABLE Tviol_A0_WENeg    : X01 := '0';
        VARIABLE TD_A0_WENeg       : VitalTimingDataType;

        VARIABLE Tviol_VPP_WENeg  : X01 := '0';
        VARIABLE TD_VPP_WENeg     : VitalTimingDataType;

        VARIABLE Tviol_WPNeg_WENeg : X01 := '0';
        VARIABLE TD_WPNeg_WENeg    : VitalTimingDataType;

        VARIABLE Tviol_WENeg_CENeg : X01 := '0';
        VARIABLE TD_WENeg_CENeg    : VitalTimingDataType;

        VARIABLE Tviol_D0_CENeg    : X01 := '0';
        VARIABLE TD_D0_CENeg       : VitalTimingDataType;

        VARIABLE Tviol_A0_CENeg    : X01 := '0';
        VARIABLE TD_A0_CENeg       : VitalTimingDataType;

        VARIABLE Tviol_VPP_CENeg  : X01 := '0';
        VARIABLE TD_VPP_CENeg     : VitalTimingDataType;

        VARIABLE Tviol_WPNeg_CENeg : X01 := '0';
        VARIABLE TD_WPNeg_CENeg    : VitalTimingDataType;

        VARIABLE Pviol_WENeg       : X01 := '0';
        VARIABLE PD_WENeg          : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Pviol_RPNeg       : X01 := '0';
        VARIABLE PD_RPNeg          : VitalPeriodDataType := VitalPeriodDataInit;

        VARIABLE Violation         : X01 := '0';


        VARIABLE data              : integer RANGE -1 TO MaxData;
        VARIABLE OTP_Addr          : boolean := FALSE;
        VARIABLE ActBlock          : integer RANGE 0 TO 255;
    BEGIN

    ----------------------------------------------------------------------------
    -- Timing Check Section
    ----------------------------------------------------------------------------
    IF (TimingChecksOn) THEN
        -- Setup/Hold Check between A0 and WENeg/CENeg
        VitalSetupHoldCheck (
            TestSignal      => A0,
            TestSignalName  => "A0",
            RefSignal       => WENeg,
            RefSignalName   => "WENeg",
            SetupLow        => tsetup_A0_WENeg,
            HoldHigh        => thold_A0_WENeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_A0_WENeg,
            Violation       => Tviol_A0_WENeg
        );
        VitalSetupHoldCheck (
            TestSignal      => A0,
            TestSignalName  => "A0",
            RefSignal       => CENeg,
            RefSignalName   => "CENeg",
            SetupLow        => tsetup_A0_WENeg,
            HoldHigh        => thold_A0_WENeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_A0_CENeg,
            Violation       => Tviol_A0_CENeg
        );

        -- Setup/Hold Check between D0 and WENeg/CENeg
        VitalSetupHoldCheck (
            TestSignal      => D0,
            TestSignalName  => "D0",
            RefSignal       => WENeg,
            RefSignalName   => "WENeg",
            SetupLow        => tsetup_D0_WENeg,
            HoldHigh        => thold_D0_WENeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_D0_WENeg,
            Violation       => Tviol_D0_WENeg
        );
        VitalSetupHoldCheck (
            TestSignal      => D0,
            TestSignalName  => "D0",
            RefSignal       => CENeg,
            RefSignalName   => "CENeg",
            SetupLow        => tsetup_D0_WENeg,
            HoldHigh        => thold_D0_WENeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_D0_CENeg,
            Violation       => Tviol_D0_CENeg
        );
        
        -- Hold Check between CENeg and WENeg
        VitalSetupHoldCheck (
            TestSignal      => CENeg,
            TestSignalName  => "CENeg",
            RefSignal       => WENeg,
            RefSignalName   => "WENeg",
            SetupLow        => tsetup_CENeg_WENeg,
            HoldHigh        => thold_CENeg_WENeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_CENeg_WENeg,
            Violation       => Tviol_CENeg_WENeg
        );
        VitalSetupHoldCheck (
            TestSignal      => WENeg,
            TestSignalName  => "WENeg",
            RefSignal       => CENeg,
            RefSignalName   => "CENeg",
            SetupLow        => tsetup_CENeg_WENeg,
            HoldHigh        => thold_CENeg_WENeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WENeg_CENeg,
            Violation       => Tviol_WENeg_CENeg
        );


        VitalSetupHoldCheck (
            TestSignal      => VPP,
            TestSignalName  => "VPP",
            RefSignal       => WENeg,
            RefSignalName   => "WENeg",
            SetupLow        => tsetup_VPP_WENeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_VPP_WENeg,
            Violation       => Tviol_VPP_WENeg
        );        

        VitalSetupHoldCheck (
            TestSignal      => WPNeg,
            TestSignalName  => "WPNeg",
            RefSignal       => WENeg,
            RefSignalName   => "WENeg",
            SetupLow        => tsetup_WPNeg_WENeg,
            CheckEnabled    => TRUE,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WPNeg_WENeg,
            Violation       => Tviol_WPNeg_WENeg
        );

        VitalPeriodPulseCheck (
            TestSignal        => WENeg,
            TestSignalName    => "WENeg",
            PulseWidthHigh    => tpw_WENeg_posedge,
            PulseWidthLow     => tpw_WENeg_negedge,
            CheckEnabled      => TRUE,
            HeaderMsg         => InstancePath & PartID,
            PeriodData        => PD_WENeg,
            Violation         => Pviol_WENeg
        );

        VitalPeriodPulseCheck (
            TestSignal        => RPNeg,
            TestSignalName    => "RPNeg",
            PulseWidthLow     => tpw_RPNeg,
            CheckEnabled      => TRUE,
            HeaderMsg         => InstancePath & PartID,
            PeriodData        => PD_RPNeg,
            Violation         => Pviol_RPNeg
        );




        Violation := Tviol_CENeg_WENeg OR Tviol_D0_WENeg OR
                     Tviol_A0_WENeg OR Tviol_VPP_WENeg OR
                     Tviol_WPNeg_WENeg OR Tviol_WENeg_CENeg OR
                     Tviol_D0_CENeg OR Tviol_A0_CENeg OR
                     Tviol_VPP_CENeg OR Tviol_WPNeg_CENeg OR
                     Pviol_WENeg OR Pviol_RPNeg;



        ASSERT Violation = '0'
            REPORT InstancePath & partID & ": simulation may be" &
                    " inaccurate due to timing violations"
            SEVERITY WARNING;
    END IF;

    ----------------------------------------------------------------------------
    -- Functionality Section
    ----------------------------------------------------------------------------

    -- FSM
    IF rising_edge(WENeg) THEN
        data:=to_nat(DIn);
        OTP_Addr:= (to_nat(A)>=16#80# AND to_nat(A)<=16#88#) ;
        
        ActBlock := to_nat(A(20 downto 15)); -- active Block
        IF ActBlock = 0 THEN
            ActBlock := to_nat(A(14 downto 12));
        ELSE
            ActBlock := ActBlock + 7;
        END IF;
    END IF;


    CASE current_state IS
         
         WHEN DOUBLE_WORD =>
            IF rising_edge(WENeg) THEN
                IF  not DWord_cycle THEN
                    next_state <= DOUBLE_WORD;
                ELSE
                    next_state <= PROG_BUSY;
                END IF;
            END IF;

         WHEN DOUBLE_WORD_ERS_SUSP =>
            IF rising_edge(WENeg) THEN
                IF  not DWord_cycle THEN
                    next_state <= DOUBLE_WORD_ERS_SUSP;
                ELSE
                    IF DWord_addr(20 downto 1)=a(20 downto 1) THEN
                        next_state <= PROG_BUSY_ERS_SUSP;
                    ELSE
                        next_state <= READ_ARRAY_ERS_SUSP;
                    END IF;
                END IF;
            END IF;

         WHEN  READ_ARRAY | READ_STATUS | READ_CONFIG | READ_QUERY   =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD;
                    WHEN 16#10# | 16#40# => next_state <= PROG_SETUP;
                    WHEN 16#20# => next_state <= ERASE_SETUP;
                    WHEN 16#70# => next_state <= READ_STATUS;
                    WHEN 16#90# => next_state <= READ_CONFIG;
                    WHEN 16#98# => next_state <= READ_QUERY;
                    WHEN 16#60# => next_state <= LOCK_SETUP;
                    WHEN 16#C0# => next_state <= PROT_PROG_SETUP;
                    WHEN OTHERS => next_state <= READ_ARRAY;
                END CASE;
            END IF;


         WHEN LOCK_SETUP  =>
            IF rising_edge(WENeg) THEN
            -- SECOND CYCLE CHECK
                IF data=16#D0# OR data=16#01# OR data=16#2F# THEN
                    next_state<=READ_ARRAY;
                ELSE
                    next_state <= BOTCH_LOCK;
                END IF;
            END IF;

        WHEN LOCK_SETUP_ERS_SUSP   =>
            IF rising_edge(WENeg) THEN
                IF data=16#D0# OR data=16#01# OR data=16#2F# THEN
                    next_state<=READ_ARRAY_ERS_SUSP;
                ELSE
                    next_state <= BOTCH_LOCK_ERS_SUSP;
                END IF;
            END IF;


         WHEN LOCK_DONE                  =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD;
                    WHEN 16#10# | 16#40# => next_state <= PROG_SETUP;
                    WHEN 16#20# => next_state <= ERASE_SETUP;
                    WHEN 16#70# => next_state <= READ_STATUS;
                    WHEN 16#90# => next_state <= READ_CONFIG;
                    WHEN 16#98# => next_state <= READ_QUERY;
                    WHEN 16#60# => next_state <= LOCK_SETUP;
                    WHEN 16#C0# =>  next_state <= PROT_PROG_SETUP;
                    WHEN OTHERS => next_state <= READ_ARRAY;
                END CASE;
            END IF;

         WHEN LOCK_DONE_ERS_SUSP                  =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD_ERS_SUSP;
                    WHEN 16#10# | 16#40# => next_state <= PROG_SETUP_ERS_SUSP;
                    WHEN 16#70# => next_state <= READ_STATUS_ERS_SUSP;
                    WHEN 16#90# => next_state <= READ_CONFIG_ERS_SUSP;
                    WHEN 16#98# => next_state <= READ_QUERY_ERS_SUSP;
                    WHEN 16#60# => next_state <= LOCK_SETUP_ERS_SUSP;
                    WHEN 16#D0# => next_state <= ERASE_BUSY;
                    WHEN OTHERS => next_state <= READ_ARRAY_ERS_SUSP;
                END CASE;
            END IF;

         WHEN BOTCH_LOCK                  =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD;
                    WHEN 16#10# | 16#40# => next_state <= PROG_SETUP;
                    WHEN 16#20# => next_state <= ERASE_SETUP;
                    WHEN 16#70# => next_state <= READ_STATUS;
                    WHEN 16#90# => next_state <= READ_CONFIG;
                    WHEN 16#98# => next_state <= READ_QUERY;
                    WHEN 16#60# => next_state <= LOCK_SETUP;
                    WHEN 16#C0# =>  next_state <= PROT_PROG_SETUP;
                    WHEN OTHERS => next_state <= READ_ARRAY;
                END CASE;
            END IF;

         WHEN BOTCH_LOCK_ERS_SUSP                  =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD_ERS_SUSP;
                    WHEN 16#10# | 16#40# =>
                        next_state <= PROG_SETUP_ERS_SUSP;
                    WHEN 16#70# => next_state <= READ_STATUS_ERS_SUSP;
                    WHEN 16#90# => next_state <= READ_CONFIG_ERS_SUSP;
                    WHEN 16#98# => next_state <= READ_QUERY_ERS_SUSP;
                    WHEN 16#60# => next_state <= LOCK_SETUP_ERS_SUSP;
                    WHEN OTHERS => next_state <= READ_ARRAY_ERS_SUSP;
                END CASE;
            END IF;


         WHEN BOTCH_ERS           =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD_ERS_SUSP;
                    WHEN 16#10# | 16#40# =>
                        next_state <= PROG_SETUP;
                    WHEN 16#20# => next_state <=ERASE_SETUP;
                    WHEN 16#70# => next_state <= READ_STATUS;
                    WHEN 16#90# => next_state <= READ_CONFIG;
                    WHEN 16#98# => next_state <= READ_QUERY;
                    WHEN 16#60# => next_state <= LOCK_SETUP;
                    WHEN 16#C0# => next_state <= PROT_PROG_SETUP;
                    WHEN OTHERS => next_state <= READ_ARRAY;
                END CASE;
            END IF;


        WHEN PROT_PROG_SETUP             =>
            IF rising_edge(WENeg) THEN
                next_state <= PROT_PROG_BUSY;
            END IF;

        WHEN PROT_PROG_BUSY              =>
            IF S_Reg(7)='1' THEN
                next_state <= PROT_PROG_DONE;
            ELSE
                next_state <= PROT_PROG_BUSY;
            END IF;

        WHEN PROT_PROG_DONE              =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD;
                    WHEN 16#10# | 16#40# => next_state <= PROG_SETUP;
                    WHEN 16#20# => next_state <= ERASE_SETUP;
                    WHEN 16#70# => next_state <= READ_STATUS;
                    WHEN 16#90# => next_state <= READ_CONFIG;
                    WHEN 16#98# => next_state <= READ_QUERY;
                    WHEN 16#60# => next_state <= LOCK_SETUP;
                    WHEN 16#C0# =>  next_state <= PROT_PROG_SETUP;
                    WHEN OTHERS => next_state <= READ_ARRAY;
                END CASE;
            END IF;

         WHEN PROG_SETUP                      =>
            IF rising_edge(WENeg) THEN
                next_state <= PROG_BUSY;
            END IF;

         WHEN PROG_SETUP_ERS_SUSP             =>
            IF rising_edge(WENeg) THEN
                next_state <= PROG_BUSY_ERS_SUSP;
            END IF;

         WHEN PROG_BUSY                    =>
            IF WDone THEN
                next_state<=PROGRAM_DONE;
            ELSIF rising_edge(WENeg) THEN
                IF data= 16#B0# THEN
                    next_state <= READ_STATUS_PROG_SUSP;
                ELSE
                    next_state <= PROG_BUSY;
                END IF;
            END IF;

         WHEN PROG_BUSY_ERS_SUSP           =>
            IF WDone THEN
                next_state<=PROGRAM_DONE_ERS_SUSP;
            ELSIF rising_edge(WENeg) THEN
                next_state <= PROG_BUSY_ERS_SUSP;
            END IF;

         WHEN  READ_STATUS_PROG_SUSP | READ_ARRAY_PROG_SUSP |
               READ_CONFIG_PROG_SUSP | READ_QUERY_PROG_SUSP  =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    --WHEN 16#D0# => next_state <= READ_ARRAY_PROG_SUSP;
                    WHEN 16#D0# => next_state <= PROG_BUSY;
                    WHEN 16#B0# | 16#70# => next_state <= READ_STATUS_PROG_SUSP;
                    WHEN 16#90# => next_state <= READ_CONFIG_PROG_SUSP;
                    WHEN 16#98# => next_state <= READ_QUERY_PROG_SUSP;
                    WHEN OTHERS => next_state <= READ_ARRAY_PROG_SUSP;
                END CASE;
            END IF;

         WHEN PROGRAM_DONE                    =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD;
                    WHEN 16#10# | 16#40# => next_state <= PROG_SETUP;
                    WHEN 16#20# => next_state <= ERASE_SETUP;
                    WHEN 16#70# => next_state <= READ_STATUS;
                    WHEN 16#90# => next_state <= READ_CONFIG;
                    WHEN 16#98# => next_state <= READ_QUERY;
                    WHEN 16#60# => next_state <= LOCK_SETUP;
                    WHEN 16#C0# => next_state <= PROT_PROG_SETUP;
                    WHEN OTHERS => next_state <= READ_ARRAY;
                END CASE;
            END IF;

         WHEN PROGRAM_DONE_ERS_SUSP          =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD_ERS_SUSP;
                    WHEN 16#10# | 16#40# => next_state <= PROG_SETUP_ERS_SUSP;
                    WHEN 16#B0# | 16#70# => next_state <= READ_STATUS_ERS_SUSP;
                    WHEN 16#D0# => next_state <= ERASE_BUSY;
                    WHEN 16#90# => next_state <= READ_CONFIG_ERS_SUSP;
                    WHEN 16#98# => next_state <= READ_QUERY_ERS_SUSP;
                    WHEN 16#60# => next_state <= LOCK_SETUP_ERS_SUSP;
                    WHEN OTHERS => next_state <= READ_ARRAY_ERS_SUSP;
                END CASE;
            END IF;

         WHEN ERASE_SETUP                     =>
            IF rising_edge(WENeg) THEN
                IF data=16#D0#  AND Block_Lock(ActBlock)/='1' THEN
                    next_state<= ERASE_BUSY;
                ELSE
                    next_state<=BOTCH_ERS;
                END IF;
            END IF;

         WHEN ERASE_BUSY                      =>
            IF rising_edge(WENeg) AND data= 16#B0# THEN
                    next_state <= READ_STATUS_ERS_SUSP;
            ELSIF EDone AND ECount=31 THEN
                next_state<=ERASE_DONE;
            ELSE
                next_state <= ERASE_BUSY;
            END IF;

         WHEN READ_STATUS_ERS_SUSP | READ_ARRAY_ERS_SUSP |
              READ_CONFIG_ERS_SUSP | READ_QUERY_ERS_SUSP   =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD_ERS_SUSP;
                    WHEN 16#10# | 16#40# => next_state <=PROG_SETUP_ERS_SUSP;
                    WHEN 16#B0# | 16#70# | 16#80# =>
                                    next_state<= READ_STATUS_ERS_SUSP;
                    WHEN 16#D0# => next_state <= ERASE_BUSY;
                    WHEN 16#90# => next_state <= READ_CONFIG_ERS_SUSP;
                    WHEN 16#98# => next_state <= READ_QUERY_ERS_SUSP;
                    WHEN 16#60# => next_state <= LOCK_SETUP_ERS_SUSP;
                    WHEN OTHERS => next_state <= READ_ARRAY_ERS_SUSP;
                END CASE;
            END IF;

         WHEN ERASE_DONE                      =>
            IF rising_edge(WENeg) THEN
                CASE data IS
                    WHEN 16#30# => next_state <= DOUBLE_WORD;
                    WHEN 16#10# | 16#40# => next_state <= PROG_SETUP;
                    WHEN 16#20# => next_state <= ERASE_SETUP;
                    WHEN 16#70# => next_state <= READ_STATUS;
                    WHEN 16#90# => next_state <= READ_CONFIG;
                    WHEN 16#98# => next_state <= READ_QUERY;
                    WHEN 16#60# => next_state <= LOCK_SETUP;
                    WHEN 16#C0# => next_state <= PROT_PROG_SETUP;
                    WHEN OTHERS => next_state <= READ_ARRAY;
                END CASE;
            END IF;

   END CASE;
END PROCESS;



    ---------------------------------------------------------------------------
   -- combinatorial output generation  (Mealy machine)
    ---------------------------------------------------------------------------
output: PROCESS(current_state, A, Din, CENeg, OENeg, WENeg, RPNeg, WPNeg,
                VPP,  WDone, S_Reg, EDone, ECount, DWord_cycle,DWord_addr)

        -- Functionality Results Variables
        VARIABLE Data               : INTEGER RANGE -1 TO MaxData:=0;
        VARIABLE WData              : INTEGER RANGE -1 TO MaxData:=0;

        VARIABLE ActBlock           : integer RANGE 0 to 71      :=0;
        VARIABLE ActB_tmp           : integer RANGE 0 to 71      :=0;
        VARIABLE EBlock             : integer RANGE 0 to 71      :=0;
        VARIABLE Ecnt               : integer RANGE 0 TO 65536   :=0;
        VARIABLE Addr               : integer RANGE 0 to MemSize :=0;
        VARIABLE WAddr              : integer RANGE 0 to MemSize :=0;
        VARIABLE EBlockLock         : boolean := FALSE;
        VARIABLE EBlock_Addr        : integer RANGE 0 to MemSize :=0;

        --Protection registers
        TYPE PR_type IS ARRAY(16#80# TO 16#88#) OF INTEGER
                            RANGE 0 TO MaxData;
        VARIABLE PR                 : PR_type       := (OTHERS =>16#FFFF#);
        VARIABLE PR_Addr            : std_logic_vector(15 DOWNTO 0)
                                                    :=(OTHERS=>'0');

        VARIABLE Ident_Addr         : integer RANGE 0 TO 16#88#:=0;

        -- Common Flash Interface
        TYPE CFI_type IS ARRAY(16#10# TO 16#47#) OF INTEGER
                            RANGE 0 TO 16#FF#;
        VARIABLE CFI                : CFI_type      := (OTHERS => 0);
        VARIABLE cycle              : boolean :=false;
        -- Memory array declaration
        TYPE MemStore IS ARRAY (0 to MemSize) OF INTEGER
                            RANGE  -1 TO MaxData;
        
        VARIABLE MemData            : MemStore      := (OTHERS =>16#FFFF#);

        --double word write
        VARIABLE second             : INTEGER RANGE -1 TO MaxData;
        VARIABLE DWord              : boolean := false;
        
        VARIABLE tmp                : std_logic_vector(15 downto 0);
        
        -- text file input variables
            FILE mem_file       : text  is  mem_file_name;

            VARIABLE ind        : NATURAL := 0;
            VARIABLE buf        : line;

BEGIN

    IF rising_edge(WENeg) OR falling_edge(OENeg) THEN
        Addr  := to_nat(A);
        ActBlock := to_nat(A(20 downto 15)); -- active Block

        ActBlock := to_nat(A(20 downto 15)); -- active Block
        IF ActBlock = 0 THEN
            ActBlock := to_nat(A(14 downto 12));
        ELSE
            ActBlock := ActBlock + 7;
        END IF;
    END IF;

    IF rising_edge(WENeg)  THEN
        Data     := to_nat(DIn);
    END IF;

     CASE current_state IS
        
        WHEN DOUBLE_WORD =>
           S_Reg(7)<='0';
           IF rising_edge(WENeg) THEN
                IF Block_Lock(ActBlock) = '0' THEN
                    IF VPP = '1' THEN
                        IF  not DWord_cycle THEN
                            WAddr := Addr;
                            WData := Data;
                            DWord_cycle <=true;
                            DWord_addr <= A;
                        ELSE
                            IF DWord_addr(20 downto 1)=A(20 downto 1) THEN
                                DWord := true;
                                second := Data;
                                DWord_addr<=A;
                            ELSE
                                DWord := false;
                            END IF;
                            DWord_cycle <= false;
                        END IF;
                        -- Program time should be 100 us
                        WDone <= FALSE, TRUE AFTER 100 us;

                    ELSE
                        S_Reg(3) <= '1';
                        S_Reg(4) <= '1';
                    END IF;
                ELSE
                    S_Reg(1) <= '1';    -- Block is Locked
                    S_Reg(4) <= '1';    -- Programming Failure
                END IF;
            END IF;
        
        WHEN DOUBLE_WORD_ERS_SUSP =>
           S_Reg(7)<='0';
           IF rising_edge(WENeg) THEN
                IF Block_Lock(ActBlock)='0' AND ActBlock/=EBlock THEN
                    IF VPP = '1' THEN
                        IF  not DWord_cycle THEN
                            WAddr := Addr;
                            WData := Data;
                            DWord_cycle <=true;
                            DWord_addr <= A;
                        ELSE
                            IF DWord_addr(20 downto 1)=A(20 downto 1) THEN
                                DWord := true;
                                second := Data;
                                DWord_addr<=A;
                            ELSE
                                DWord := false;
                            END IF;
                            DWord_cycle <= false;
                        END IF;
                        -- Program time should be 100 us
                        WDone <= FALSE, TRUE AFTER 100 us;

                    ELSE
                        S_Reg(3) <= '1';
                        S_Reg(4) <= '1';
                    END IF;
                ELSE
                    S_Reg(1) <= '1';    -- Block is Locked
                    S_Reg(4) <= '1';    -- Programming Failure
                END IF;
            END IF;

        WHEN  READ_ARRAY =>
            IF falling_edge(OENeg) THEN
                Dout_zd <= to_slv(MemData(Addr),16);
            END IF;

            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10000000";
            END IF;


        WHEN   READ_STATUS   =>
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;
            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10000000";
            END IF;


        WHEN READ_CONFIG  =>
            IF falling_edge(OENeg) THEN
                DOut_zd <= (OTHERS=>'0');
                IF Addr= 0 THEN
                    DOut_zd<=to_slv(16#89#,16);

                ELSIF Addr=1 THEN
                        DOut_zd <=to_slv(16#88BA#,16);

                ELSIF Addr>=16#80# AND Addr<=16#88# THEN
                        DOut_zd <=to_slv(PR(Addr),16);

                ELSIF A(11 DOWNTO 0)= "000000000010" THEN
                    DOut_zd(0)<=Block_Lock(ActBlock);
                    DOut_zd(1)<=Lock_Down(ActBlock);
                END IF;
            END IF;

            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10000000";
            END IF;


        WHEN  READ_QUERY   =>
            IF falling_edge(OENeg) THEN
                DOut_zd<=(OTHERS=>'0');
                IF Addr= 0 THEN
                    DOut_zd <=to_slv(16#89#,16);

                ELSIF Addr=1 THEN
                    IF cycle=false THEN
                        DOut_zd(7 downto 0) <=to_slv(16#BB#,8);
                        cycle:=true;
                    ELSE
                        DOut_zd(7 downto 0) <=to_slv(16#88#,8);
                        cycle:=false;
                    END IF;
                ELSIF A(11 DOWNTO 0)= "000000000010" THEN
                    DOut_zd(0)<=Block_Lock(ActBlock);
                    DOut_zd(1)<=Lock_Down(ActBlock);

                ELSIF Addr>=16#10# AND Addr<=16#47# THEN
                    DOut_zd(7 downto 0)<=to_slv(CFI(Addr),8);

                ELSE
                -- RESERVED OR Address out of range
                    DOut_zd<=(OTHERS=>'0');

                END IF;
            END IF;
            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10000000";
            END IF;


        WHEN LOCK_SETUP  =>
            IF rising_edge(WENeg) THEN
            -- SECOND CYCLE CHECK
                IF Data=16#01# THEN -- Lock Block
                    Block_Lock(ActBlock) <='1';
                ELSIF Data=16#D0# THEN -- UnLock Block
                    IF NOT(WPNeg='0' AND Lock_Down(ActBlock)='1') THEN
                        Block_Lock(ActBlock) <='0';
                    END IF;
                ELSIF Data=16#2F# THEN -- Lock Down Block
                   Lock_Down(ActBlock) <='1';
                   Block_Lock(ActBlock) <='1';
                END IF;
            END IF;
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


        WHEN LOCK_SETUP_ERS_SUSP   =>
            IF rising_edge(WENeg) THEN
            -- SECOND CYCLE CHECK
                IF Data=16#01# THEN -- Lock Block
                    Block_Lock(ActBlock) <='1';
                    IF ActBlock=EBlock THEN
                        EBlockLock:=FALSE;
                    END IF;
                ELSIF Data=16#D0# THEN -- UnLock Block
                    IF NOT(WPNeg='0' AND Lock_Down(ActBlock)='1') THEN
                        Block_Lock(ActBlock) <='0';
                    END IF;
                ELSIF Data=16#2F# THEN -- Lock Down Block
                    Lock_Down(ActBlock) <='1';
                    Block_Lock(ActBlock) <='1';
                END IF;
            END IF;
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


         WHEN BOTCH_LOCK |  LOCK_DONE             =>
            S_Reg(7)<='1';
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;
            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10000000";
            END IF;

         WHEN BOTCH_LOCK_ERS_SUSP |LOCK_DONE_ERS_SUSP   =>
            S_Reg(7)<='1';
            S_Reg(5)<='1';
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;
            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10100000";
            END IF;

        WHEN BOTCH_ERS             =>
            S_Reg(7)<='1';
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;
            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10000000";
            END IF;


        WHEN PROT_PROG_SETUP             =>
            --S_Reg(7)<='0';
            IF rising_edge(WENeg) THEN
                IF Addr=16#80# THEN
                    IF Data>=16#FFFB# AND Data<=16#FFFD# THEN
                        PR(Addr):=Data;
                        --program time should be 100 us
                        S_Reg(7)<='0', '1' AFTER 100 us;
                    ELSE
                        S_Reg(7)<='1';
                    END IF;

                ELSIF Addr>=16#81# AND Addr<=16#84# THEN --PR0
                    --Intel Factory Programmed
                    --
                    S_Reg(7)<='1';
                    S_Reg(4)<='1';
                    S_Reg(1)<='1';

                ELSIF Addr>=16#85# AND Addr<=16#88# THEN
                    IF PR(16#80#)=16#FFFE# AND PR(Addr)=16#FFFF# THEN
                    --PR0 user segment NOT locked
                    --  and NOT programmed
                        PR(Addr):=Data;
                        --program time should be 100 us
                        S_Reg(7)<='0', '1' AFTER 100 us;
                    ELSE
                    --PR0 user segment NOT available
                        S_Reg(7)<='1';
                        S_Reg(4)<='1';
                        S_Reg(1)<='1';

                    END IF;

                ELSE
                    S_Reg(7)<='1';
                END IF;

            END IF;
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


        WHEN PROT_PROG_BUSY              =>
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


        WHEN PROT_PROG_DONE              =>
            S_Reg(7)<='1';
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;
            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10000000";
            END IF;



        WHEN PROG_SETUP                      =>
            S_Reg(7)<='0';
            IF rising_edge(WENeg) THEN
                WDone<=TRUE;
                IF Block_Lock(ActBlock) = '0' THEN
                    IF VPP = '1' THEN
                        WAddr := Addr;
                        WData := Data;
                        -- Program time should be 100 us
                        WDone <= FALSE, TRUE AFTER 100 us;
                    ELSE
                        S_Reg(3) <= '1';
                        S_Reg(4) <= '1';
                    END IF;
                ELSE
                    S_Reg(1) <= '1';    -- Block is Locked
                    S_Reg(4) <= '1';    -- Programming Failure
                END IF;

            END IF;
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


        WHEN PROG_SETUP_ERS_SUSP             =>
            S_Reg(7)<='0';
            IF rising_edge(WENeg) THEN
                WDone<=TRUE;
                IF Block_Lock(ActBlock) = '0' THEN
                    IF VPP = '1' THEN
                        WAddr := Addr;
                        WData := Data;
                            -- Program time should be 100 us ...
                        WDone <= FALSE, TRUE AFTER 100 us;
                    ELSE
                        S_Reg(3) <= '1';
                        S_Reg(4) <= '1';
                    END IF;
                ELSE
                    S_Reg(1) <= '1';    -- Block is Locked
                    S_Reg(4) <= '1';    -- Programming Failure
                END IF;

            END IF;
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


        WHEN PROG_BUSY                    =>

            IF WDone THEN
                IF Viol = '0' AND S_Reg(4)/='1' THEN
                    MemData(WAddr) := WData; --OK
                    IF DWord THEN
                        MemData(to_nat(DWord_addr)):=second;
                        DWord := false;
                    END IF;
                ELSIF Viol /= '0' THEN
                    MemData(WAddr) := -1; -- invalid entry !
                    IF DWord THEN
                        MemData(to_nat(DWord_addr)):=-1;
                        DWord := false;
                    END IF;
                    S_Reg(4) <= '1';    -- Programming Failure
                END IF;
                S_Reg(7)<='1';
            END IF;

            IF rising_edge(WENeg)AND Data= 16#B0# THEN
                S_Reg(2)<='1'; --program suspend
            END IF;

            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


        WHEN PROG_BUSY_ERS_SUSP           =>

            IF WDone THEN
                IF Viol = '0' AND S_Reg(4)/='1' THEN
                    MemData(WAddr) := WData; --OK
                    IF DWord THEN
                        MemData(to_nat(DWord_addr)):=second;
                        DWord := not DWord;
                    END IF;
                ELSIF Viol /= '0' THEN
                    MemData(WAddr) := -1; -- invalid entry !
                    IF DWord THEN
                        MemData(to_nat(DWord_addr)):=-1;
                        DWord := not DWord;
                    END IF;
                    S_Reg(4) <= '1';    -- Programming Failure
                END IF;
                S_Reg(7)<='1';
            END IF;

            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


        WHEN  READ_STATUS_PROG_SUSP =>
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;
            IF rising_edge(WENeg) THEN
                IF data=16#50# THEN
                    S_Reg<="10000100";
                ELSIF data=16#D0# THEN
                    S_Reg(2)<='0'; -- Program NOT suspended
                END IF;
            END IF;


        WHEN  READ_ARRAY_PROG_SUSP =>

            IF falling_edge(OENeg) THEN
                IF NOT(Addr=WAddr)THEN
                    Dout_zd <= to_slv(MemData(Addr),16);
                ELSE
                    ASSERT FALSE
                        REPORT "accessed memory is suspended"
                        SEVERITY WARNING;
                END IF;
            END IF;

            IF rising_edge(WENeg) THEN
                IF data=16#50# THEN
                    S_Reg<="10000100";
                ELSIF data=16#D0# THEN
                    S_Reg(2)<='0'; -- Program NOT suspended
                END IF;
            END IF;



         WHEN  READ_CONFIG_PROG_SUSP =>
            -- if identifier data has more than 1 byte then
            -- low byte is read first
            IF falling_edge(OENeg) THEN
                IF Addr= 0 THEN
                    DOut_zd <=to_slv(16#89#,16);

                ELSIF Addr=1 THEN
                    DOut_zd <=to_slv(16#88BA#,16);

                ELSIF Addr>=16#80# AND Addr<=16#88# THEN
                    DOut_zd<=to_slv(PR(Addr),16);

                ELSIF A(11 DOWNTO 0)= "000000000010" THEN
                    DOut_zd(0)<=Block_Lock(ActBlock);
                    DOut_zd(1)<=Lock_Down(ActBlock);
                    DOut_zd(15 DOWNTO 2)<= (OTHERS=>'0');
                END IF;
            END IF;

            IF rising_edge(WENeg) THEN
                IF data=16#50# THEN
                    S_Reg<="10000100";
                ELSIF data=16#D0# THEN
                    S_Reg(2)<='0'; -- Program NOT suspended
                END IF;
            END IF;



        WHEN  READ_QUERY_PROG_SUSP  =>
            IF falling_edge(OENeg) THEN
                DOut_zd<= (OTHERS=>'0');
                IF Addr= 0 THEN
                    DOut_zd(7 downto 0) <=to_slv(16#89#,8);

                ELSIF Addr=1 THEN
                    IF cycle=false THEN
                        DOut_zd(7 downto 0) <=to_slv(16#BB#,8);
                        cycle:=true;
                    ELSE
                        DOut_zd(7 downto 0) <=to_slv(16#88#,8);
                        cycle:=false;
                    END IF;

                ELSIF A(11 DOWNTO 0)= "000000000010" THEN
                    DOut_zd(0)<=Block_Lock(ActBlock);
                    DOut_zd(1)<=Lock_Down(ActBlock);

                ELSIF Addr>=16#10# AND Addr<=16#51# THEN
                    DOut_zd(7 downto 0)<=to_slv(CFI(Addr),8);

                ELSE
                -- RESERVED OR Address out of range
                    DOut_zd<=(OTHERS=>'0');

                END IF;
            END IF;
            IF rising_edge(WENeg) THEN
                IF data=16#50# THEN
                    S_Reg<="10000100";
                ELSIF data=16#D0# THEN
                    S_Reg(2)<='0'; -- Program NOT suspended
                END IF;
            END IF;



         WHEN PROGRAM_DONE                    =>
            WDone<=FALSE;
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;
            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10000000";
            END IF;


        WHEN PROGRAM_DONE_ERS_SUSP           =>
            WDone<=FALSE;
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
             END IF;
            IF rising_edge(WENeg) THEN
                IF data=16#50# THEN
                    S_Reg<="11000000";
                ELSIF data=16#D0# THEN
                    S_Reg(6)<='0'; -- Erase NOT suspended
                END IF;
            END IF;


        WHEN ERASE_SETUP                     =>
            IF rising_edge(WENeg) THEN
                IF Data=16#D0# THEN
                    S_Reg(7)<='0';
                    IF Block_Lock(ActBlock) = '0' THEN
                        IF VPP = '1' THEN
                            --Block should be unlocked after erase
                            EBlock:=ActBlock;
                            EBlockLock:=TRUE;
                            IF EBlock>7 THEN
                                ECount<=0;
                                EBlock_Addr:=Addr-to_nat(A(14 DOWNTO 0));
                            --Block Erase time should be 1 s
                                EDone <= FALSE, TRUE AFTER 5 ms;

                            ELSE
                                ECount<=28;
                                EBlock_Addr:=Addr-to_nat(A(11 DOWNTO 0));
                        --Block Erase time should be 0.5 s
                                EDone <= FALSE, TRUE AFTER 20 ms;
                            END IF;
                            Ecnt:=0;
                        ELSE
                            S_Reg(3) <= '1';
                            S_Reg(5) <= '1';

                        END IF;
                    ELSE
                        S_Reg(1) <= '1';    -- Block is Locked
                        S_Reg(5) <= '1';    -- Erase Failure
                    END IF;

                END IF;
            END IF;
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


        WHEN ERASE_BUSY                      =>

            IF EDone AND ECount<=31 THEN
                FOR i IN 0 TO 127 LOOP
                    Memdata(EBlock_Addr+ECnt):=16#FFFF#;
                    EXIT WHEN Ecnt=1023;
                    Ecnt:=Ecnt+1;
                END LOOP;

                IF ECount=31 THEN
                    S_Reg(7)<='1';
                ELSE
                   IF EBlock>7 THEN
                    --4 ms per 128 word group
                        EDone <= FALSE, TRUE AFTER 5 ms;
                    ELSE
                    --16 ms per 128 word group
                        EDone <= FALSE, TRUE AFTER 20 ms;
                    END IF;
                    IF Ecnt=1023 THEN
                        Ecnt:=0;
                        ECount<=ECount+1;
                    END IF;

                END IF;            
            
            END IF;

            IF rising_edge(WENeg)AND Data=16#B0#  THEN
                S_Reg(6)<='1'; --erase suspend
            ELSE
                S_Reg(6)<='0'; -- erase NOT suspend
            END IF;

            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;


        WHEN READ_STATUS_ERS_SUSP =>
            S_Reg(6)<='1'; --erase suspend
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;
            IF rising_edge(WENeg) THEN
                IF data=16#50# THEN
                    S_Reg<="11000000";
                ELSIF data=16#D0# THEN
                    S_Reg(6)<='0'; -- ERASE NOT suspended
                END IF;
            END IF;

        WHEN READ_ARRAY_ERS_SUSP =>

            IF falling_edge(OENeg) THEN
                IF ActBlock/=EBlock THEN
                    Dout_zd <= to_slv(MemData(Addr),16);
                ELSE
                    ASSERT FALSE
                        REPORT "accessed memory is suspended"
                        SEVERITY WARNING;

                END IF;
            END IF;

            IF rising_edge(WENeg) THEN
                IF data=16#50# THEN
                    S_Reg<="11000000";
                ELSIF data=16#D0# THEN
                    S_Reg(6)<='0'; -- ERASE NOT suspended
                END IF;
            END IF;


        WHEN READ_CONFIG_ERS_SUSP =>
            -- if identifier data has more than 1 byte then
            -- low byte is read first
            IF falling_edge(OENeg) THEN
                IF Addr= 0 THEN
                    DOut_zd <=to_slv(16#89#,16);

                ELSIF Addr=1 THEN
                    DOut_zd <=to_slv(16#88BB#,16);

                ELSIF Addr>=16#80# AND Addr<=16#88# THEN
                    DOut_zd <=to_slv(PR(Addr),16);

                ELSIF A(11 DOWNTO 0)= "000000000010" THEN
                    DOut_zd(0)<=Block_Lock(ActBlock);
                    DOut_zd(1)<=Lock_Down(ActBlock);
                    DOut_zd(15 DOWNTO 2)<= (OTHERS=>'0');
                END IF;
            END IF;

            IF rising_edge(WENeg) THEN
                IF data=16#50# THEN
                    S_Reg<="11000000";
                ELSIF data=16#D0# THEN
                    S_Reg(6)<='0'; -- ERASE NOT suspended
                END IF;
            END IF;


        WHEN READ_QUERY_ERS_SUSP   =>
            IF falling_edge(OENeg) THEN
                DOut_zd<= (OTHERS=>'0');
                IF Addr= 0 THEN
                    DOut_zd(7 downto 0) <=to_slv(16#89#,8);

                ELSIF Addr=1 THEN
                    IF cycle=false THEN
                        DOut_zd(7 downto 0) <=to_slv(16#BB#,8);
                        cycle:=true;
                    ELSE
                        DOut_zd(7 downto 0) <=to_slv(16#88#,8);
                        cycle:=false;
                    END IF;

                ELSIF A(11 DOWNTO 0)= "000000000010" THEN
                    DOut_zd(0)<=Block_Lock(ActBlock);
                    DOut_zd(1)<=Lock_Down(ActBlock);

                ELSIF Addr>=16#10# AND Addr<=16#51# THEN
                    DOut_zd(7 downto 0)<=to_slv(CFI(Addr),8);

                ELSE
                -- RESERVED OR Address out of range
                    DOut_zd<=(OTHERS=>'0');

                END IF;
            END IF;
            IF rising_edge(WENeg) THEN
                IF data=16#50# THEN
                    S_Reg<="11000000";
                ELSIF data=16#D0# THEN
                    S_Reg(6)<='0'; -- ERASE NOT suspended
                END IF;
            END IF;


        WHEN ERASE_DONE                      =>
            EDone<=FALSE;
            IF EBlockLock THEN
                Block_Lock(EBlock)<='0';
            END IF;
            IF falling_edge(OENeg) THEN
                DOut_zd(15 downto 8) <= (OTHERS => '0');
                DOut_zd(7 downto 0) <= S_Reg;
            END IF;
            IF rising_edge(WENeg) AND data=16#50# THEN
               S_Reg<="10000000";
            END IF;

        END CASE;    
    --this section is common to all command states
    --**
    
    tmp:=to_slv(PR(16#80#),16);
    IF not (tmp(2)='1') THEN
        Lock_Down(0)<='1';
        Block_Lock(0)<='1';
    END IF;

    IF rising_edge(OENeg) OR rising_edge(CENeg) OR falling_edge(RPNeg) THEN
    -- data lines should be HiZ when bus cycle is Output Disable, Standby
    -- or reset whatever the command state is
         DOut_zd<= (OTHERS => 'Z');
    END IF;

    -- Register data to default value
    IF rising_edge(RPNeg) THEN
        S_Reg       <="10000000";
        Block_Lock  <=(OTHERS=>'1');
        Lock_Down   <=(OTHERS=>'0');
        WDone       <= FALSE;
        EDone       <= FALSE;
        ECount      <=0;
        PR(16#80#)  :=16#FFFE#; -- PR0 Lock Register
        -- CFI Indentification
        CFI(16#10#):=16#51#;
        CFI(16#11#):=16#52#;
        CFI(16#12#):=16#59#;
        CFI(16#13#):=16#03#;
        CFI(16#14#):=16#00#;
        CFI(16#15#):=16#35#;
        CFI(16#16#):=16#00#;
        CFI(16#17#):=16#00#;
        CFI(16#18#):=16#00#;
        CFI(16#19#):=16#00#;
        CFI(16#1A#):=16#00#;
        -- System Interface Information
        CFI(16#1B#):=16#27#;
        CFI(16#1C#):=16#36#;
        CFI(16#1D#):=16#B4#;
        CFI(16#1E#):=16#C6#;
        CFI(16#1F#):=16#05#;
        CFI(16#20#):=16#00#;
        CFI(16#21#):=16#0A#;
        CFI(16#22#):=16#00#;
        CFI(16#23#):=16#04#;
        CFI(16#24#):=16#00#;
        CFI(16#25#):=16#03#;
        CFI(16#26#):=16#00#;
        -- Device Geometry definition
        CFI(16#27#):=16#16#;
        CFI(16#28#):=16#01#;
        CFI(16#29#):=16#00#;
        CFI(16#2A#):=16#00#;
        CFI(16#2B#):=16#00#;
        CFI(16#2C#):=16#02#;
        CFI(16#2D#):=16#3E#;
        CFI(16#2E#):=16#00#;
        CFI(16#2F#):=16#20#;
        CFI(16#30#):=16#00#;
        CFI(16#31#):=16#07#;
        CFI(16#32#):=16#00#;
        CFI(16#33#):=16#00#;
        CFI(16#34#):=16#01#;
        --primary-vendor specific extended query
        CFI(16#35#):=16#50#;
        CFI(16#36#):=16#52#;
        CFI(16#37#):=16#49#;
        CFI(16#38#):=16#31#;
        CFI(16#39#):=16#30#;
        CFI(16#3A#):=16#66#;
        CFI(16#3B#):=16#00#;
        CFI(16#3C#):=16#00#;
        CFI(16#3D#):=16#00#;
        CFI(16#3E#):=16#01#;
        CFI(16#3F#):=16#03#;
        CFI(16#40#):=16#00#;
        CFI(16#41#):=16#33#;
        CFI(16#42#):=16#C0#;
        --protection register information
        CFI(16#43#):=16#01#;
        CFI(16#44#):=16#80#;
        CFI(16#45#):=16#00#;
        CFI(16#46#):=16#03#;
        CFI(16#47#):=16#03#;

    --------------------------------------------------------------------
    -- File Read Section
    --------------------------------------------------------------------
    IF (mem_file_name /= "none") THEN
        ind := 0;
        WHILE (not ENDFILE (mem_file)) LOOP
            READLINE (mem_file, buf);
            IF buf(1) = '#' THEN
                NEXT;
            ELSIF buf(1) = '@' THEN
                ind := h(buf(2 to 2));
            ELSE
                MemData(ind) := h(buf(1 to 4));
                ind := ind + 1;
            END IF;
        END LOOP;
    END IF;



    END IF;


       END PROCESS;


    ----------------------------------------------------------------------------
    -- Path Delay Section for DOut signal
    ----------------------------------------------------------------------------
    D_Out_PathDelay_Gen : FOR i IN Dout_zd'RANGE GENERATE
        PROCESS(DOut_zd(i))
        VARIABLE D0_GlitchData     : VitalGlitchDataType;

        BEGIN
            VitalPathDelay01Z(
                   OutSignal     => DOut(i),
                   OutSignalName => "DOut",
                   OutTemp       => DOut_zd(i),
                   GlitchData    => D0_GlitchData,
                   Paths         => (
                   0 => (InputChangeTime   => CENeg'LAST_EVENT,
                         PathDelay         => tpd_CENeg_D0,
                         PathCondition     => CENeg = '1'),
                   1 => (InputChangeTime   => OENeg'LAST_EVENT,
                         PathDelay         => tpd_OENeg_D0,
                         PathCondition     => OENeg'EVENT),
                   2 => (InputChangeTime   => RPNeg'LAST_EVENT,
                         PathDelay         => tpd_RPNeg_D0,
                         PathCondition     => RPNeg = '0'),
                   3 => (InputChangeTime   => A0'LAST_EVENT,
                         PathDelay         => VitalExtendToFillDelay(tpd_A0_D0),
                         PathCondition     => TRUE)
                   )
               );
        END PROCESS;
   END GENERATE D_Out_PathDelay_Gen;


    END BLOCK behavior;
END vhdl_behavioral;
